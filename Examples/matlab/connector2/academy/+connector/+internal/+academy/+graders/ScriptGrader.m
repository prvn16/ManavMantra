classdef ScriptGrader < connector.internal.academy.graders.Grader
    
    properties (Access=private)   
        submissionFile
        submissionCode
        submissionName
        
        solutionFile
        solutionCode
        solutionName
        
        results
        syntaxErrorFlag
        
        runner
        graderPlugin
        diagnosticsPlugin
        
        warningState
        autogenerateHint = false;
    end
    
    methods (Static)
        
        function result = gradeSubmission(submissionFile,solutionFile,testFolder)
            grader = connector.internal.academy.graders.ScriptGrader(submissionFile,solutionFile,testFolder);
            grade(grader);
            result = getResultsInJson(grader);
            resetWarningState(grader);
        end
        
    end
    
    methods
        
        function obj = ScriptGrader(submissionFile,solutionFile,testFolder)
            import connector.internal.academy.graders.*;

            isLiveScript = contains(submissionFile, '.mlx');

            obj.warningState = warning;
            warning('off');

            if (isLiveScript)
                obj.submissionFile = submissionFile;
                obj.submissionCode = '';
                obj.submissionName = '';
                obj.solutionFile = solutionFile;
                obj.solutionCode = '';
                obj.solutionName = '';
                obj.autogenerateHint = false;
            else
                obj.submissionFile = submissionFile;
                obj.submissionCode = fileread(which(submissionFile));
                obj.submissionName = submissionFile(1:end-2);
                obj.solutionFile = solutionFile;
                obj.solutionCode = fileread(which(solutionFile));
                obj.solutionName = solutionFile(1:end-2);
            end
            warning('off');
            
            if (nargin >= 3)
                obj.testFolder = testFolder;
            end

            if isLiveScript
                obj.syntaxErrorFlag = false;
            else
                obj.syntaxErrorFlag = GraderUtils.containsSyntaxError(obj.submissionCode);
            end
            
            obj.runner = matlab.unittest.TestRunner.withNoPlugins;
            obj.graderPlugin = connector.internal.academy.plugins.GraderPlugin(obj.submissionCode,obj.solutionCode);
            obj.diagnosticsPlugin = connector.internal.academy.plugins.DiagnosticsPlugin;
            obj.runner.addPlugin(obj.graderPlugin);
            obj.runner.addPlugin(obj.diagnosticsPlugin);            
        end
                
        function resultStr = getResultsInJson(obj)
            o = struct;
            %Ensure results and assessments are arrays in the JSON
            o.tests = num2cell(obj.results);
            for i = 1:numel(o.tests)
                o.tests{i}.assessments = num2cell(o.tests{i}.assessments);
            end
            o.correct = obj.getCorrectness;
            o.hint = obj.results(1).hint;
            o.submissionCode = obj.submissionCode;  
            o.syntaxErrorFlag = obj.syntaxErrorFlag;
            resultStr = obj.getTrimmedResultString(mls.internal.toJSON(o));
        end
        
        function resetWarningState(obj)
           warning(obj.warningState);
        end
        
        function grade(obj)            
            testFiles = dir([obj.testFolder filesep 'test_exercise_*']);
            obj.results = obj.createEmptyResultsStruct;
            for i = 1:numel(testFiles)
                obj.results(i) = obj.runExercise(fullfile(obj.testFolder,testFiles(i).name));
            end       
            
            obj.setCorrectness(all([obj.results.correct]));
        end        
    end
    
    methods (Access=private)
        
        %There is a certain maximum size of output that can be sent from
        %the worker to the client. MO says it's 44000, and the command
        %window will only display 25000 in traditional MATLAB. Our output
        %string typically only inflates this big if there is a large amount
        %of command window output. To reduce the size, we don't want to
        %just truncate the string, as that would result in invalid JSON.
        %Instead, we truncate just the command window output from the
        %exercises here. This requires a bit of back and forth conversions
        %to get the character sizes right, since JSON strings are typically
        %longer than MATLAB strings due to the escape characters (\n, \t,
        %etc.)
        function trimmedResultStr = getTrimmedResultString(obj,resultStr)   
            trimmedResultStr = resultStr;
            numChars = numel(trimmedResultStr);
            delta = numChars - obj.MAX_JSON_RESULTS_SIZE;
            if (delta > 0)
                o = mls.internal.fromJSON(trimmedResultStr);
                for i = 1:numel(o.tests)
                    stringBefore = mls.internal.toJSON(o.tests(i).codeOutput);
                    sizeBefore = numel(stringBefore);
                    stringAfter = ['"' stringBefore((1+delta):(end-1)) '"'];
                    o.tests(i).codeOutput = mls.internal.fromJSON(stringAfter);
                    sizeAfter = numel(stringAfter);
                    change = sizeBefore - sizeAfter;
                    delta = delta - change;
                    if (delta <= 0)
                        break;
                    end
                end
                %Ensure results and assessments are arrays in the JSON
                o.tests = num2cell(o.tests);
                for i = 1:numel(o.tests)
                    o.tests{i}.assessments = num2cell(o.tests{i}.assessments);
                end
                trimmedResultStr = mls.internal.toJSON(o);
            end
        end
        
        function s = createEmptyResultsStruct(~)
            s = struct('assessments',[],'hint','','diagnostics',[],...
                'runTimeErrorFlag',[],'errorObject',[],'errorMessage',[],...
                'correct',[],'codeOutput','','exerciseCode','');
        end
        
        function s = createEmptyAssessmentStruct(~)
            s = struct('Name',[],'Passed',[],'Failed',[],...
                'Incomplete',[],'Duration',[],'ScriptCode','','Diagnostics','');
        end
        
        function [testResults,t] = runTestsInProperContext(obj,tests)
            %Generally, the unit test framework does a nice job of
            %isolating the code from other workspace variables. However,
            %many other things in MATLAB (figures, random number seed,
            %etc.) are more "global". Here, we try to emulate true
            %isolation by resetting each of those items before we
            %run the test.
            tic;
            rng(0);
            close all;
            fclose all;
            resetWarningState(obj);               
            testResults = obj.runner.run(tests);
            warning('off');               
            t = toc;
        end
        
        function results = runExercise(obj,testFile)
            %Todo - use figure manager to suppress and capture figures from
            %this call
            if (obj.autogenerateHint)
                solutionWorkspace = obj.getSolutionWorkspaceForExercise(testFile);
            end
            
            results = obj.createEmptyResultsStruct;
            [~,testFileName] = fileparts(testFile);
            testModel = connector.internal.academy.testmodels.CodyTestScriptModel.fromString(fileread(testFile), testFileName);
            tests = matlab.unittest.Test.fromProvider(connector.internal.academy.providers.AcademyScriptTestCaseProvider(testModel,false));
            [testResults,testDuration] = obj.runTestsInProperContext(tests);
            diagnosticResults = obj.diagnosticsPlugin.Details;
            
            assessmentStruct = obj.createEmptyAssessmentStruct;
            for i = 1:numel(testResults)
                assessmentStruct(i).Name = testResults(i).Name;
                assessmentStruct(i).Passed = testResults(i).Passed;
                assessmentStruct(i).Failed = testResults(i).Failed;
                assessmentStruct(i).Incomplete = testResults(i).Incomplete;
                assessmentStruct(i).Duration = testResults(i).Duration;
                assessmentStruct(i).ScriptCode = diagnosticResults(i).ScriptCode;
                assessmentStruct(i).Diagnostics = strtrim(diagnosticResults(i).Diagnostics);
            end            
            
            results.assessments = assessmentStruct;
            results.runTimeErrorFlag = ((numel(obj.graderPlugin.exceptionObject.stack) > 0)...
                || (~strcmp(obj.graderPlugin.exceptionObject.message,''))) || (obj.syntaxErrorFlag);          
            results.correct = all([testResults.Passed]);
            results.codeOutput = obj.graderPlugin.codeOutput;
            results.exerciseCode = testModel.ImplicitCellContent;
            
            %G1351353 - warning message not being displayed due to
            %backspace characters
            results.codeOutput = strrep(results.codeOutput,char(8),'');
            
            if results.runTimeErrorFlag || obj.syntaxErrorFlag                    
                results.errorObject = obj.graderPlugin.exceptionObject;                
                if (numel(results.errorObject.stack) > 0)
                    results.errorMessage = results.errorObject.getReport;
                else
                    results.errorMessage = results.errorObject.message;
                end

                % Add markup to replace \n by <br\>
                %results.errorMessage = strrep(results.errorMessage,char(10),'<br/>');
            end
            
            if results.correct
                results.hint = 'Correct';
            else
                % There is some error - It could be syntax error, run time
                % error or error in the logic
                
                % If  there is a syntax or runtime error, we create a separate message
                if results.runTimeErrorFlag || obj.syntaxErrorFlag
                    
                    if obj.syntaxErrorFlag
                        results.hint = ['Your code has a syntax error.'...
                            '<br/>See the Command Window for more details.'];
                    else
                        results.hint = ['Running your code generated an error.'...
                            '<br/>See the Command Window for more details.'];
                    end
                else
                    try
                        if obj.autogenerateHint && (testDuration < 2)
                            if ~isempty(obj.graderPlugin.hint)
                                results.hint = obj.graderPlugin.hint;
                            else
                                submissionWorkspace = obj.graderPlugin.postExerciseVariables;
                                testSuiteCode = cat(2,results.assessments.ScriptCode);
                                results.hint = obj.createAutomaticHint(solutionWorkspace,...
                                submissionWorkspace,testSuiteCode);
                            end
                        else 
                            results.hint = 'One or more tests did not pass.';
                        end
                    catch MExc
                        results.hint = 'One or more tests did not pass.';
                    end
                    if strcmp(results.hint,'')
                        results.hint = 'One or more tests did not pass.';
                    end
                end
            end
        end
        
        function solutionWorkspace = getSolutionWorkspaceForExercise(obj,testFile)
            %import matlab.internal.editor.FigureManager;
            orig = fileread(testFile);
            modified = strrep(orig,obj.submissionName,obj.solutionName);            
            testModel = connector.internal.academy.testmodels.CodyTestScriptModel.fromString(modified, 'solutionTest');
            tests = matlab.unittest.Test.fromProvider(connector.internal.academy.providers.AcademyScriptTestCaseProvider(testModel,false));
            %FigureManager.enableCaptureFigures('solutionExecution');
            try
                obj.runTestsInProperContext(tests);
            catch MExc
                %FigureManager.clearFigures('solutionExecution');
                %FigureManager.disableCaptureFigures('solutionExecution');
                rethrow(MExc);
            end
            %FigureManager.clearFigures('solutionExecution');
            %FigureManager.disableCaptureFigures('solutionExecution');
            solutionWorkspace = obj.graderPlugin.postExerciseVariables;
        end
        
        function hint = createAutomaticHint(obj,solutionWorkspace,submissionWorkspace,testSuiteCode)
            hint = '';
            
            % Find the variables of interest using the grader code and the solution workspace
            % Variables that are 'not assigned' in the grader code.
            varsOfInterest = obj.findVariablesOfInterest(testSuiteCode,solutionWorkspace);
            
            % Find incorrect variables
            incorrectVars = obj.findIncorrectVars(solutionWorkspace, submissionWorkspace, varsOfInterest);
            if isempty(incorrectVars)
                hint = 'One or more tests did not pass.';
                return;
            end
            
            % Order Variables
            % If more than one variable is inaccurate in the student's submission, how
            % do we determine the variable which should be reported? We do that by
            % looking at the order in which the variables were assigned.
            varOrder = obj.variableOrder(obj.solutionCode, varsOfInterest);
            
            % Compare the incorrect variable having the highest priority
            % Determine the variable with the highest priority
            varPriority = cellfun(@(x)find(strcmp(x,varOrder)),incorrectVars);
            [~,varToReportIdx] = min(varPriority);
            varToReport = incorrectVars{varToReportIdx};
            
            % Step 6 - Compare the variable in the student and the submission workspace
            if isfield(solutionWorkspace,varToReport)
                solVar = solutionWorkspace.(varToReport);
            else
                solVar = '_does_not_exist';
            end
            
            if isfield(submissionWorkspace,varToReport)
                submissionVar = submissionWorkspace.(varToReport);
            else
                submissionVar = '_does_not_exist';
            end

            comparisonObj = connector.internal.academy.comparisons.compareVariables(solVar,submissionVar,varToReport);
            
            % Step 7 - Generate Feedback
            
            for k=1:length(comparisonObj)
                if strcmp(class(comparisonObj{k}),'ExistenceComparison')
                    hint = [hint generateFeedback(comparisonObj{k},submissionWorkspace)];
                else
                    hint = [hint generateFeedback(comparisonObj{k})];
                end
            end
            % If comparisonObj is empty, the above loop will not generate 
            % a hint. In that case, we assume that comparisonObj is empty
            % not because the variables are equal but because we couldn't
            % find a suitable comparison object and generate a generic
            % hint.
            if isempty(hint)                
                hint = {'One or more tests did not pass.'};
            end
        end
        
        
        function varsOfInterest = findVariablesOfInterest(obj,graderCode,solVars)
            % Find the variables that should be checked
            % graderCode - grading suite
            % solVars - a structure containing the solution's workspace variables
            %
            % Solution code:
            % x = sin(-pi:pi/8:pi);
            % y = x(abs(x)>0.5);
            %
            % So, solution workspace file contains the variables x and y
            %
            % Grader Code:
            % tTest = sin(pi:pi/8:pi);
            % yTest = tTest(abs(tTest)>0.5);
            % assert(isequaln(yTest,y));
            %
            % In the above example, y is the variable of interest. This function finds
            % that by looking at the grader code and finding all the variables in the
            % grader code that are not 'assigned'.
            
            t = mtree(graderCode);
            
            varsOfInterest = {};
            
            % Find ids which are variables - We do this by looking at all the identifiers
            % in the grader code mtree.
            % Also, we don't want to include any temporary variables. So, exclude all the
            % variables which are 'assigned' in the grading suite
            
            % Find all identifiers
            ids = mtfind(t,'Kind','ID');
            
            % Find the temporary variables or grader specific variables - Variables
            % that are assigned in the grading code.
            tempVars = asgvars(t);
            
            for j=indices(ids)
                idString = string(t.select(j));
                % Check that this identifier is not assigned to anything
                if isempty(mtfind(tempVars,'SameID',t.select(j)))
                    % Make sure that this id is a variable and not a function
                    % Checking if the id is a variable name in the solution workspace
                    allSolVars = fieldnames(solVars);
                    if (any(strcmp(allSolVars,idString)))
                        varsOfInterest{end+1} = idString; %#ok<AGROW>
                    end
                end
            end
            varsOfInterest = unique(varsOfInterest);
        end
        
        function varOrder = variableOrder(obj,solutionCode,varsOfInterest)
            % This function is used to find the order in whcih the variables were
            % assigned in the solution code. This wil help in deciding which variables
            % to report on. For example, the following code, if both t and y are wrong,
            % we will choose to report on t because it was assigned first.
            %
            % t = sin(-pi:pi/10:pi);
            % y = cos(t);
            %
            
            varOrder = {};
            
            % Check inputs:
            
            % The student's code and the submission code is assumed to be syntactically
            % correct
            
            % If there are no variables of interest, return
            if isempty(varsOfInterest)
                return;
            end
            
            studentTree = mtree(solutionCode);
            
            % Get all the nodes that represent assignment
            allVarAssignNodes = asgvars(studentTree);
            
            % find the node number of the last assignment for each variable
            varLastAssignmentNode = zeros(1,length(varsOfInterest));
            for i=1:length(varsOfInterest)
                lastNodeIndex = indices(mtfind(allVarAssignNodes,'String',varsOfInterest{i}));
                if isempty(lastNodeIndex)
                    varLastAssignmentNode(i) = inf;
                else
                    varLastAssignmentNode(i) = max(lastNodeIndex);
                end
            end
            
            % Sort the variables based in the node numbers
            [~,varOrderIdx] = sort(varLastAssignmentNode);
            varOrder = varsOfInterest(varOrderIdx);
        end
        
        function invorrectVars = findIncorrectVars(obj,solWS,studentWS,varsOfInterest)
            % Finds the variables that have wrong value or the ones that do not
            % exist. The output is a cell array containins variable names that have
            % incorrect values.
            
            % Initialize the output
            invorrectVars = {};
            
            % Check inputs:
            
            % If there are no variables of interest, return
            if isempty(varsOfInterest)
                return;
            end
            
            % Compare
            studentVarNames = fieldnames(studentWS);
            
            for i = 1:numel(varsOfInterest)
                varName = varsOfInterest{i};
                existence = ismember(varsOfInterest(i),studentVarNames);
                if ~existence
                    invorrectVars{end+1} = varName; %#ok<AGROW>
                else
                    % Compare Value
                    expectedValue = solWS.(varName);
                    actualValue = studentWS.(varName);
                    valueMatch = isequaln(expectedValue,actualValue);
                    if ~valueMatch
                        invorrectVars{end+1} = varName; %#ok<AGROW>
                    end
                end
            end
        end
    end
end

