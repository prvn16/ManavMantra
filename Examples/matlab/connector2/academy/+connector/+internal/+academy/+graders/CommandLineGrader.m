classdef CommandLineGrader < connector.internal.academy.graders.Grader
    
    properties (SetAccess=private, GetAccess=public)
        submissionCode      %String containing user's submission code
        solutionCode        %String containing solution code
        
        results
        syntaxErrorFlag
        
        runner
        graderPlugin
        diagnosticsPlugin
        
        warningState
    end
    
    methods (Static)
        
        function result = gradeSubmission(submissionCode,solutionCode,testFolder)
            grader = connector.internal.academy.graders.CommandLineGrader(submissionCode,solutionCode,testFolder);
            grade(grader);
            result = getResultsInJson(grader);
            resetWarningState(grader);
        end
        
    end
    
    methods
        
        function obj = CommandLineGrader(submissionCode,solutionCode,testFolder)
            import connector.internal.academy.graders.*;

            obj.submissionCode = submissionCode;
            obj.solutionCode = solutionCode;
            obj.warningState = warning;
            warning('off');
                             
            if (nargin >= 3)
                obj.testFolder = testFolder;
            end
                        
            obj.syntaxErrorFlag = GraderUtils.containsSyntaxError(obj.submissionCode);
            
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
            obj.results = obj.runExercise(fullfile(obj.testFolder,testFiles(1).name));
            obj.setCorrectness(all(obj.results.correct));
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
        
        function results = runExercise(obj,testFile)
            import connector.internal.academy.i18n.FeedbackTemplates;

            results = obj.createEmptyResultsStruct;
            
            if (obj.syntaxErrorFlag)
                results.runTimeErrorFlag = true;
                results.hint = 'Syntax error';
                results.correct = false;
                try
                    evalc(obj.submissionCode);
                catch MExc
                    results.errorMessage = MExc.message;
                end
                return;
            end
            
            [~,testFileName] = fileparts(testFile);
            fileContents = fileread(testFile);
            testModel = connector.internal.academy.testmodels.CodyTestScriptModel.fromString(fileContents, testFileName);
            testProvider = connector.internal.academy.providers.AcademyScriptTestCaseProvider(testModel,true);
            tests = matlab.unittest.Test.fromProvider(testProvider);           
            
            resetWarningState(obj);               
            testResults = obj.runner.run(tests);
            warning('off'); 
            
            diagnosticResults = obj.diagnosticsPlugin.Details;
            
            assessmentStruct = obj.createEmptyAssessmentStruct;
            for i = 1:numel(testResults)
                assessmentStruct(i).Name = testResults(i).Name;
                assessmentStruct(i).Passed = testResults(i).Passed;
                assessmentStruct(i).Failed = testResults(i).Failed;
                assessmentStruct(i).Incomplete = testResults(i).Incomplete;
                assessmentStruct(i).Duration = testResults(i).Duration;
                assessmentStruct(i).ScriptCode = diagnosticResults(i).ScriptCode;
                assessmentStruct(i).Diagnostics = diagnosticResults(i).Diagnostics;
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
                results.hint = FeedbackTemplates.language.templates.correct;
            else
                if isempty(obj.graderPlugin.hint)
                    results.hint = connector.internal.academy.comparisons.compareCommands(obj.submissionCode, obj.solutionCode);
                else 
                    results.hint = obj.graderPlugin.hint;
                end
                if strcmp(results.hint, FeedbackTemplates.language.templates.correct)
                    results.hint = FeedbackTemplates.language.templates.incorrect;
                end
            end
        end
        
    end
    
end

