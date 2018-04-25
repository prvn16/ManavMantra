function checkInteraction(interactionFile, contentFolder, logFolder)
    %We need the content folder passed in addition to the interaction file 
    % because our interaction json files assume that the app knows it, and 
    % specify paths like "Applications/Project 1/data.csv", which must 
    % be resolved to "<contentfolder>/Applications/Project 1/data.csv"

    %Work is used as the current directory for the tests, and testFolder 
    % holds the actual tests
    workFolder = fullfile(tempdir,'work');
    testFolder = fullfile(tempdir,'tests');

    %Read data
    FID = fopen(interactionFile,'rb','n','UTF-8');
    Str = fscanf(FID,'%c',Inf);
    
    % Delete the byte order marker if it exists.
    if(double(Str(1)) == 65279)
        Str(1) = [];
    end
    
    interactionData = mls.internal.fromJSON(Str);

    %Extract elements of interest
    initCode = interactionData.matlabInteraction.initializationCode;
    
    if isfield(interactionData.matlabInteraction,'filesToAdd')
        filesToAdd = ensureCellArray(interactionData.matlabInteraction.filesToAdd);
    else
        filesToAdd = [];
    end
    questions = ensureCellArray(interactionData.matlabInteraction.questions);

    %Loop through questions (tasks) and format data as required
    tasks = struct('solution',[],'type',[],'exercises',[],'template',[]);
    for i = 1:numel(questions)
        correctnessAssessment = strjoin(questions{i}.correctnessAssessment,char(10));
        task = struct;
        task.type = questions{i}.type;
        task.solution = questions{i}.solution;
        task.exercises = extractExercisesFromCorrectnessAssessment(correctnessAssessment);
        if ~isequal(task.type,'commandLine')        
            task.template = questions{i}.template;
        else 
            task.template = [];
        end
        tasks(i) = task;
    end
    
    %Start the actual test    
    doLog('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~', logFolder);
    doLog(interactionFile, logFolder);
    
    %Clean up
    connector.internal.academy.state.cleanMATLABState;    
    prepareFolder(workFolder);
    cd(workFolder);
    
    %Add supporting files
    addFiles(filesToAdd, workFolder, contentFolder, getLessonPath(interactionFile, contentFolder));
    
    %Run initialization code
    if iscell(initCode)        
        evalin('base',strjoin(initCode,char(10)))
    end
    
    %Save state
    connector.internal.academy.state.saveMATLABState('startOfQuestion');

    %Leave if it's an ungraded interaction
    if isempty(tasks(1).type)
        %Ungraded interaction
        return;
    end
    warning('off');
    %For each task, check "no-op" submission and the solution as submission
    for i = 1:numel(tasks)
        taskNumber = num2str(i);
        doLog(['  Task ' taskNumber], logFolder);
        if isequal(tasks(i).type,'commandLine')        
            %No-op submission
            prepareFolder(testFolder);
            submission = '%bogus submission';
            fillTestFolderWithSubmission(testFolder, submission, tasks(i));
            result = connector.internal.academy.graders.CommandLineGrader.gradeSubmission(submission,tasks(i).solution,testFolder);
            result = mls.internal.fromJSON(result);
            if ~result.correct
                doLog('    PASS: Test suite failed bad submission', logFolder);
            else 
                doLog('    FAIL: Test suite passed bad submission', logFolder);
                doErrorLog(interactionFile, logFolder, '    FAIL: Test suite passed bad submission', taskNumber);                                
            end

            connector.internal.academy.state.restoreMATLABState('startOfQuestion');

            %Solution as submission
            prepareFolder(testFolder);
            submission = tasks(i).solution;
            fillTestFolderWithSubmission(testFolder, submission, tasks(i));
            result = connector.internal.academy.graders.CommandLineGrader.gradeSubmission(submission, tasks(i).solution, testFolder);   
            result = mls.internal.fromJSON(result);            
            if result.correct
                doLog('    PASS: Test suite passed solution as submission', logFolder);
            else 
                doLog('    FAIL: Test suite failed solution as submission', logFolder);
                doErrorLog(interactionFile, logFolder, '    FAIL: Test suite passed bad submission', taskNumber); 
            end
        end
        
        if isequal(tasks(i).type,'script') || isequal(tasks(i).type,'function')
            %No-op submission
            prepareFolder(testFolder);
            submission = strrep(tasks(i).template,'.m','');
            clear(submission);
            fillTestFolderWithSubmission(testFolder, submission, tasks(i));
            result = connector.internal.academy.graders.ScriptGrader.gradeSubmission(submission,tasks(i).solution,testFolder);
            result = mls.internal.fromJSON(result);
            if ~result.correct
                doLog('    PASS: Test suite failed bad submission', logFolder);
            else 
                doLog('    FAIL: Test suite passed bad submission', logFolder);
                doErrorLog(interactionFile, logFolder, '    FAIL: Test suite passed bad submission', taskNumber); 
            end

            connector.internal.academy.state.restoreMATLABState('startOfQuestion');

            %Solution as submission
            prepareFolder(testFolder);
            copyfile(tasks(i).solution, tasks(i).template, 'f');
            submission = strrep(tasks(i).template,'.m','');
            clear(submission);
            fillTestFolderWithSubmission(testFolder, submission, tasks(i));
            result = connector.internal.academy.graders.ScriptGrader.gradeSubmission(submission, tasks(i).solution, testFolder);
            result = mls.internal.fromJSON(result);
            if result.correct
                doLog('    PASS: Test suite passed solution as submission', logFolder);          
            else 
                doLog('    FAIL: Test suite failed solution as submission', logFolder);
                doErrorLog(interactionFile, logFolder, '    FAIL: Test suite passed bad submission', taskNumber); 
            end
        end
        
        if isequal(tasks(i).type,'liveeditor')
            %No-op submission
            prepareFolder(testFolder);         
            submission = strrep(tasks(i).template,'.mlx','');
            clear(submission);
            fillTestFolderWithSubmission(testFolder, submission, tasks(i));
            result = connector.internal.academy.graders.ScriptGrader.gradeSubmission(submission,tasks(i).solution,testFolder);
            result = mls.internal.fromJSON(result);
            if ~result.correct
                doLog('    PASS: Test suite failed bad submission', logFolder);
            else 
                doLog('    FAIL: Test suite passed bad submission', logFolder);
                doErrorLog(interactionFile, logFolder, '    FAIL: Test suite passed bad submission', taskNumber); 
            end

            connector.internal.academy.state.restoreMATLABState('startOfQuestion');

            %Solution as submission
            prepareFolder(testFolder);
            copyfile(tasks(i).solution, tasks(i).template, 'f');
            submission = strrep(tasks(i).template,'.mlx','');
            clear(submission);
            fillTestFolderWithSubmission(testFolder, submission, tasks(i));
            result = connector.internal.academy.graders.ScriptGrader.gradeSubmission(submission, tasks(i).solution, testFolder);
            result = mls.internal.fromJSON(result);
            if result.correct
                doLog('    PASS: Test suite passed solution as submission', logFolder);          
            else 
                doLog('    FAIL: Test suite failed solution as submission', logFolder);
                doErrorLog(interactionFile, logFolder, '    FAIL: Test suite passed bad submission', taskNumber); 
            end
        end

        connector.internal.academy.state.saveMATLABState('startOfQuestion');
    end

end

function c = ensureCellArray(o)
    if isstruct(o)
        c = {};
        for i = 1:numel(o)
            c{i} = o(i);
        end
    else
        c = o;
    end
end

function addFiles(filesToAdd, folder, contentFolder, lessonpath)
    for i = 1:numel(filesToAdd)
        fileToAdd = filesToAdd{i};
        if isstruct(fileToAdd)
            %Name and contents (embedded file)
            filename = fullfile(folder, fileToAdd.name);
            contents = strjoin(fileToAdd.contents,char(10));
            fid = fopen(filename,'wt');
            fprintf(fid,'%s',contents);
            fclose(fid);
        else
            %Non-embedded file
            srcFile = fullfile(contentFolder, strrep(fileToAdd, '${lessonpath}', lessonpath));
            [~,srcFileName,ext] = fileparts(srcFile);
            filename = fullfile(folder, [srcFileName ext]);
            
            copyfile(srcFile, filename, 'f');
            
            %{            
            contents = fileread(srcFile);
            fid = fopen(filename,'wt');
            fprintf(fid,'%s',contents);
            fclose(fid);
            %}
        end    
    end
end

function lessonpath = getLessonPath(interactionFile, contentFolder)
    folder = fileparts(interactionFile);
    lessonpath = '';
    while isempty(lessonpath)
        d = dir(fullfile(folder, 'contentUnit.json'));
        if isempty(d)
            folder = fileparts(folder);
        else
            n = numel(contentFolder);
            lessonpath = folder(n+1:end);
        end
        if isempty(strfind(folder,contentFolder))
            break;
        end
    end
end

function fillTestFolderWithSubmission(testFolder, submission, task)     
    for i = 1:numel(task.exercises)
        if strfind(task.exercises(i).code,'~execute user submission~')
            str = submission;
        else
            str = task.exercises(i).code;
        end
        str = [str char(10)];
        for j = 1:numel(task.exercises(i).assessments)
            str = [str '%% ' task.exercises(i).assessments(j).title];
            str = [str char(10)];
            str = [str task.exercises(i).assessments(j).code];
            str = [str char(10)];
        end
        filename = fullfile(testFolder, ['test_exercise_' num2str(i) '.m']);
        fid = fopen(filename, 'wt');
        fprintf(fid, '%s', str);
        fclose(fid);
    end    
end

function prepareFolder(folder)
    gotofolder = false;
    if exist(folder,'dir')    
        if isequal(pwd,folder)
            gotofolder = true;
            cd(tempdir);
        end
        try
            rmdir(folder,'s');
        end
    end
    mkdir(folder);
    if gotofolder
        cd(folder);
    end
end


function exercises = extractExercisesFromCorrectnessAssessment(str)
    rExTitle = '(?<title>%%([^\r\n]*))';
    rCode = '(?<code>(.|[\r\n])*?)';
    rAsmnt = '(?<assessment>%%%(?:.|[\r\n])*?';
    rAsmntTrailer = '(?=[\r\n]%%[^%]))';
    rAsmntTitle = '(?<assessmentTitle>%%%([^\r\n]*))';
    rAsmntCodeTrailer = '(?=[\r\n]%%%)';

    ptrn = [rExTitle, rCode, rAsmnt, rAsmntTrailer];
    ptrn2 = [rAsmntTitle, rCode, rAsmntCodeTrailer];

    exercises = struct('title',[],'code',[],'assessments',[]);

    str = [str char(10) '%% '];
    result = regexp(str, ptrn, 'names', 'dotexceptnewline');
    for i = 1:numel(result)
        currentExercise = struct;
        currentExercise.title = strrep(result(i).title,'%%','');
        currentExercise.code = result(i).code;
        assessmentStr = [result(i).assessment char(10) '%%%'];

        currentAssessments = struct('title',[],'code',[]);
        result2 = regexp(assessmentStr, ptrn2, 'names', 'dotexceptnewline');
        for j = 1:numel(result2)
            newAssessment = struct;
            newAssessment.title = strrep(result2(j).assessmentTitle,'%%%','');
            newAssessment.code = result2(j).code;
            currentAssessments(j) = newAssessment;
        end
        currentExercise.assessments = currentAssessments;
        exercises(i) = currentExercise;
    end
end
