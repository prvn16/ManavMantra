classdef AcademyScriptTestCaseProvider < matlab.unittest.internal.TestCaseProvider
    %This is similar to ScriptTestCaseProvider, but has Academy-specific functionality,
    % like the ability to inject base workspace context

    % ScriptTestCaseProvider is a TestCaseProvider that turns a script into
    % a test suite, with each cell in the script its own independent test.

    %  Copyright 2013-2014 The MathWorks, Inc.


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

    properties(GetAccess=private, SetAccess=immutable)
        TestCode = '';
        SharedVariableCode = '';
    end

    properties(Access=private)
        SharedVariableCodeRunsInBaseWorkspaceContext = false;
    end

    properties(SetAccess=private)
        Parameterization = matlab.unittest.parameters.EmptyParameter.empty;
        SharedTestFixtures = matlab.unittest.fixtures.EmptyFixture.empty;
        Tags = cell(1,0);
    end



    methods
        function provider = AcademyScriptTestCaseProvider(scriptFileModel,useBaseWorkspaceContext)

            if ~nargin
                % Allow pre-allocation
                return
            end

            scriptName = scriptFileModel.ScriptName;
            testNames = scriptFileModel.TestCellNames;
            testCellContent = scriptFileModel.TestCellContent;
            implicitCellContent = scriptFileModel.ImplicitCellContent;

            % Preallocate
            numTests = numel(testNames);
            provider(numTests) = connector.internal.academy.providers.AcademyScriptTestCaseProvider;

            % Assign properties
            [provider.TestParentName] = deal(scriptName);
            [provider.TestName] = testNames{:};
            [provider.TestCode] = testCellContent{:};
            [provider.SharedVariableCode] = deal(implicitCellContent);
            [provider.SharedVariableCodeRunsInBaseWorkspaceContext] = deal(useBaseWorkspaceContext);

        end

        function class = get.TestClass(~)
            class = ?matlab.unittest.FunctionTestCase;
        end

        function testCase = provideClassTestCase(provider)
            testCase = provider.constructTestCase;
        end

        function testCase = createTestCaseFromClassPrototype(provider, prototype)
            testCase = provider.constructTestCase;
            testCase.TestData = prototype.TestData;
        end

    end

    methods (Access=private)
        function testCase = constructTestCase(provider)
            import matlab.unittest.FunctionTestCase;

            % Create a copy to remove interactive listeners.
            testCase = copy(FunctionTestCase.fromFunction( ...
                @(testCase) runTest(testCase, provider.TestCode), ...
                'SetupOnceFcn', @(testCase) runSharedVariableSection(testCase, provider.SharedVariableCode, provider.SharedVariableCodeRunsInBaseWorkspaceContext)));
        end
    end
end

function runSharedVariableSection(testCase, implicitCell, useBaseWorkspaceContext)
cl = prepareToRunTestContent(testCase, implicitCell);  %#ok<NASGU>
testCase.TestData.sharedVariables = struct;
testCase.TestData.codeOutput = '';
testCase.TestData.exceptionObject = MException('','');
try
    [testCase.TestData.sharedVariables,testCase.TestData.codeOutput,testCase.TestData.exceptionObject] = ...
        createSharedVariables(implicitCell, useBaseWorkspaceContext);
catch MExc
    testCase.TestData.exceptionObject = MExc;
end
assignVariablesToBase(testCase.TestData.sharedVariables);
end


function runTest(testCase, codeSection)
cl = prepareToRunTestContent(testCase, codeSection);  %#ok<NASGU>
evaluateTestSection(codeSection, testCase.TestData.sharedVariables);
end

function cleaner = prepareToRunTestContent(testCase, content)
import matlab.unittest.Verbosity;
import matlab.unittest.internal.diagnostics.ScriptContentsDiagnostic;

testCase.log(Verbosity.Verbose, ScriptContentsDiagnostic(content));

warningState = warning('backtrace', 'off');
cleaner = onCleanup(@() warning(warningState));
end

function evaluateTestSection(codeSection, sharedVariables)
% Evaluate the code in a try catch and rethrow the error in order to
% prevent the eval from showing in the error report.
try
    %MOD #1 - SEPARATE EVALS
    eval('assignVariables(sharedVariables);');
    evalc(['clearvars -except ' strjoin(fieldnames(sharedVariables)) ';' codeSection]);
catch e
    throw(connector.internal.academy.providers.AcademyTrimmedException(e));
end
end

function assignVariables(sharedVariables) %#ok<DEFNU>
% Assign the variables in the sharedVariables struct into the calling
% workspace

names = fieldnames(sharedVariables);
for idx=1:numel(names)
    assignin('caller', names{idx}, sharedVariables.(names{idx}));
end
    
end


function assignVariablesToBase(sharedVariables) %#ok<DEFNU>
% Assign the variables in the sharedVariables struct into the calling
% workspace

evalin('base','clear');
names = fieldnames(sharedVariables);
for idx=1:numel(names)
    assignin('base', names{idx}, sharedVariables.(names{idx}));
end
    
end

function [sharedVariables,codeOutput__,exceptionObject__] = createSharedVariables(codeSection__, useBaseWorkspace__)
% Evaluate the shared variables section and take a snapshot of the
% workspace. Be careful of overlapping variables of the created shared
% variables and the current workspace. Think twice before adding any
% variables between the two evals in this function. Each new variable
% requires special handling with an "if exist(...)" statement & inclusion
% in the setdiff call below. Be wary of any = sign you see in this
% function.

if (useBaseWorkspace__)
    eval('connector.internal.academy.graders.GraderUtils.bringBaseWorkspaceIntoCallingScope');
end
try
    codeOutput__ = evalc(['clearvars codeSection__ useBaseWorkspace__; ' char(10) 'try' char(10) codeSection__ char(10) ...
        'catch exceptionObject__' char(10) 'exceptionObject__ = connector.internal.academy.providers.SharedVariableTrimmedException(exceptionObject__);' char(10) 'end']);
catch exceptionObject__
    exceptionObject__ = connector.internal.academy.providers.SharedVariableTrimmedException(exceptionObject__);
end
eval('clearvars codeSection__ useBaseWorkspace__');

if ~exist('codeOutput__','var')    
    codeOutput__ = '';
end

if ~exist('exceptionObject__','var')    
    exceptionObject__ = MException('','');
end

if exist('sharedVariables','var')
    sharedVariables = struct('sharedVariables', sharedVariables); %#ok<NODEF>
else
    sharedVariables = struct;
end

if exist('variableNames','var')
    sharedVariables.variableNames = variableNames; %#ok<NODEF>
end
if exist('idx','var')
    sharedVariables.idx = idx; %#ok<NODEF>
end

variableNames = setdiff(who, {'sharedVariables', 'variableNames', 'idx', 'codeOutput__', 'exceptionObject__'});

for idx = 1:numel(variableNames)
    sharedVariables.(variableNames{idx}) = eval(variableNames{idx});
end
end
