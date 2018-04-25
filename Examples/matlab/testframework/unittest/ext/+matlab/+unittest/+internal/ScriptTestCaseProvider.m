classdef ScriptTestCaseProvider < matlab.unittest.internal.TestCaseProvider
    % ScriptTestCaseProvider is a TestCaseProvider that turns a script into
    % a test suite, with each cell in the script its own independent test.
    
    %  Copyright 2013-2017 The MathWorks, Inc.
    
    properties(SetAccess=immutable)
        TestName
        TestParentName
    end
    
    properties(Dependent, SetAccess=immutable)
        TestClass
    end
    
    properties(Transient, SetAccess=immutable)
        TestMethodName = 'test';
    end
    
    properties (SetAccess=private)
        Parameterization = matlab.unittest.parameters.EmptyParameter.empty;
        SharedTestFixtures = matlab.unittest.fixtures.EmptyFixture.empty;
        Tags = cell(1,0);
    end
    
    properties(Access=private)
        TestExecutionCode
        SharedVariableExecutionCode
    end
        
    properties(GetAccess=private, SetAccess=immutable)
        %ScriptValidationFcn validates that the script has not been changed
        %between suite creation time and suite run time.
        ScriptValidationFcn = @() true;
        
        %TestCode and SharedVariableCode are only needed for backward
        %compatibility when loading suites from R2016a or earlier and to
        %fill ScriptContentsDiagnostic.
        TestCode
        SharedVariableCode = ''; %Need to have default '' to support R2014b
    end
    
    methods
        function provider = ScriptTestCaseProvider(testScriptModel)
            if nargin==0
                % Allow pre-allocation
                return
            end
            
            scriptName = testScriptModel.ScriptName;
            
            % Preallocate
            testNames = testScriptModel.TestSectionNameList;
            numTests = numel(testNames);
            provider(numTests) = matlab.unittest.internal.ScriptTestCaseProvider;
            
            % Assign properties
            [provider.TestParentName] = deal(scriptName);
            [provider.TestName] = testNames{:};
            [provider.TestExecutionCode] = testScriptModel.TestSectionExecutionCodeList{:};
            [provider.SharedVariableExecutionCode] = deal(testScriptModel.SharedVariableSectionExecutionCode);
            
            [provider.ScriptValidationFcn] = deal(testScriptModel.ScriptValidationFcn);
            
            %TestCode and SharedVariableCode are only needed to fill
            %ScriptContentsDiagnostic.
            [provider.TestCode] = testScriptModel.TestSectionCodeList{:};
            [provider.SharedVariableCode] = deal(testScriptModel.SharedVariableSectionCode);
        end
        
        function class = get.TestClass(provider)
            class = provider.getDefaultTestClass;
        end
        
        function code = get.TestExecutionCode(provider)
            code = provider.TestExecutionCode;
            if ~ischar(code)
                code = provider.TestCode;
            end
        end
        
        function code = get.SharedVariableExecutionCode(provider)
            code = provider.SharedVariableExecutionCode;
            if ~ischar(code)
                code = provider.SharedVariableCode;
            end
        end
        
        function testCase = provideClassTestCase(provider)
            testCase = provider.constructTestCase;
        end
        
        function testCase = createTestCaseFromClassPrototype(provider, prototype) 
          testCase = prototype.copyFor(@(testCase) provider.runTestSection(testCase));
        end
    end
    
    methods(Hidden,Static)
        function savedProvider = loadobj(savedProvider)
            % To allow loading of R2016b and R2017a files (when 'caller' meant 'current')
            replaceBuiltinWithInternal = @(code) regexprep(code,['^' regexptranslate(...
                'escape','builtin(''_ExecuteCodeBlockInternal'',''caller'',')],...
                'matlab.unittest.internal.executeCodeBlock(');
            savedProvider.TestExecutionCode = replaceBuiltinWithInternal(...
                savedProvider.TestExecutionCode);
            savedProvider.SharedVariableExecutionCode = replaceBuiltinWithInternal(...
                savedProvider.SharedVariableExecutionCode);
        end
    end
    
    methods (Access=private)
        function testCase = constructTestCase(provider)
            import matlab.unittest.FunctionTestCase;
            
            testCase = FunctionTestCase.fromFunction( ...
                @(testCase) provider.runTestSection(testCase), ...
                'SetupOnceFcn', @(testCase) provider.runSharedVariableSection(testCase));
        end
        
        function runSharedVariableSection(provider, testCase)
            provider.prepareToRunSharedVariableSection(testCase);
            testCase.TestData = provider.createSharedVariables;
        end
        
        function runTestSection(provider, testCase)
            import matlab.unittest.internal.LabelEventData;
            provider.prepareToRunTestSection(testCase);
            provider.evaluateTestSection(testCase);
            testCase.notify('MeasurementStopped',LabelEventData('_noLabel'));
        end
        
        function evaluateTestSection(provider, testCase__)
            import matlab.unittest.internal.LabelEventData;
            eval(['matlab.unittest.internal.assignSharedVariables(testCase__.TestData);', ...
                'clearvars -except ' strjoin([fieldnames(testCase__.TestData); 'testCase__']) ';', ...
                'testCase__.notify(''MeasurementStarted'',LabelEventData(''_noLabel'')); clear testCase__;', ...
                provider.TestExecutionCode]);
        end
        
        function sharedVariables = createSharedVariables(provider)
            % Evaluate the shared variables section and take a snapshot of the
            % workspace. Be careful of overlapping variables of the created shared
            % variables and the current workspace. Think twice before adding any
            % variables between the two evals in this function. Each new variable
            % requires special handling with an "if exist(...)" statement & inclusion
            % in the setdiff call below. Be wary of any = sign you see in this
            % function.
            
            eval(['clearvars;' provider.SharedVariableExecutionCode]);
            
            if exist('sharedVariables','var')
                sharedVariables = struct('sharedVariables', eval('sharedVariables'));
            else
                sharedVariables = struct;
            end
            
            if exist('variableNames','var')
                sharedVariables.variableNames = eval('variableNames');
            end
            if exist('idx','var')
                sharedVariables.idx = eval('idx');
            end
            
            variableNames = setdiff(who, {'sharedVariables', 'variableNames', 'idx'});
            
            for idx = 1:numel(variableNames)
                sharedVariables.(variableNames{idx}) = eval(variableNames{idx});
            end
        end
        
        function prepareToRunSharedVariableSection(provider, testCase)
            provider.ScriptValidationFcn();
            prepareToRunSection(testCase, provider.SharedVariableCode);
        end
    
        function prepareToRunTestSection(provider, testCase)
            prepareToRunSection(testCase, provider.TestCode);
        end
    end
end

function prepareToRunSection(testCase, content)
import matlab.unittest.Verbosity;
import matlab.unittest.internal.diagnostics.ScriptContentsDiagnostic;
testCase.log(Verbosity.Verbose, ScriptContentsDiagnostic(content));
end

% LocalWords:  evals