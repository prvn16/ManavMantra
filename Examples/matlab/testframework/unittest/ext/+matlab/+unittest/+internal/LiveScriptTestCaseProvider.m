classdef LiveScriptTestCaseProvider < matlab.unittest.internal.TestCaseProvider
    % This class is undocumented and is subject to change in a future release.
    
    % LiveScriptTestCaseProvider is a TestCaseProvider that turns a live
    % script into a test suite, with each section in the live script its
    % own independent test.
    
    %  Copyright 2017 The MathWorks, Inc.
    
    properties(SetAccess=immutable)
        TestName
        TestParentName
        
        FileRelease
        ProviderRelease
    end
    
    properties(Dependent, SetAccess=immutable)
        TestClass
    end
    
    properties(Transient, SetAccess=immutable)
        TestMethodName = 'test';
    end
    
    properties(SetAccess=private)
        Parameterization = matlab.unittest.parameters.EmptyParameter.empty;
        SharedTestFixtures = matlab.unittest.fixtures.EmptyFixture.empty;
        Tags = cell(1,0);
    end
    
    properties(GetAccess=private, SetAccess=immutable)
        TestExecutionCode
        SharedVariableExecutionCode
        
        %ScriptValidationFcn validates that the live script has not been changed
        %between suite creation time and suite run time.
        ScriptValidationFcn
    end
    
    methods
        function provider = LiveScriptTestCaseProvider(testScriptMLXFileModel)
            if nargin==0 % Allow array pre-allocation
                return;
            end
            
            % Preallocate
            testNames = testScriptMLXFileModel.TestSectionNameList;
            numTests = numel(testNames);
            provider(numTests) = matlab.unittest.internal.LiveScriptTestCaseProvider();
            
            % Assign properties
            [provider.TestParentName] = deal(testScriptMLXFileModel.ScriptName);
            [provider.TestName] = testNames{:};
            [provider.FileRelease] = deal(testScriptMLXFileModel.FileRelease);
            [provider.ProviderRelease] = deal("R"+version('-release'));
            [provider.TestExecutionCode] = testScriptMLXFileModel.TestSectionExecutionCodeList{:};
            [provider.SharedVariableExecutionCode] = deal(testScriptMLXFileModel.SharedVariableSectionExecutionCode);
            
            [provider.ScriptValidationFcn] = deal(testScriptMLXFileModel.ScriptValidationFcn);
        end
        
        function class = get.TestClass(provider)
            class = provider.getDefaultTestClass;
        end
        
        function testCase = provideClassTestCase(provider)
            testCase = provider.constructTestCase();
        end
        
        function testCase = createTestCaseFromClassPrototype(provider, prototype) 
          testCase = prototype.copyFor(@(testCase) provider.runTestSection(testCase));
        end
    end
    
    methods (Access=private)
        function testCase = constructTestCase(provider)
            testCase = matlab.unittest.FunctionTestCase.fromFunction( ...
                @(testCase) provider.runTestSection(testCase), ...
                'SetupOnceFcn', @(testCase) provider.setupOnceFcn(testCase));
        end
        
        function setupOnceFcn(provider, testCase)
            import matlab.unittest.internal.diagnostics.MessageDiagnostic;
            
            provider.ScriptValidationFcn();
            
            if ~ismember(provider.FileRelease,["R2016a","R2016b","R2017a","R2017b","R2018a"])
                testCase.onFailure(MessageDiagnostic(...
                    'MATLAB:unittest:TestSuite:ScriptFromLaterRelease'));
            end
        end
        
        function runTestSection(provider, testCase)
            import matlab.unittest.internal.LabelEventData;
            provider.evaluateTestSection(testCase);
            testCase.notify('MeasurementStopped',LabelEventData('_noLabel'));
        end
        
        function evaluateTestSection(provider, testCase__) %#ok<INUSD> - eval
            import matlab.unittest.internal.LabelEventData;
            eval(['clearvars -except testCase__;', ...
                'testCase__.notify(''MeasurementStarted'',LabelEventData(''_noLabel'')); clear testCase__;', ...
                provider.TestExecutionCode]);
        end
    end
end