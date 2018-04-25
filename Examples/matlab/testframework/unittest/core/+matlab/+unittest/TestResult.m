classdef TestResult < matlab.unittest.internal.BaseTestResult
    % TestResult - Result of running a test suite
    %
    %   The matlab.unittest.TestResult class holds the information describing
    %   the result of running a test suite using the matlab.unittest.TestRunner.
    %   It contains information describing whether the test passed, failed,
    %   or ran to completion as well as the duration of the tests.
    %
    %   TestResult arrays are created and returned by the test runner, and are
    %   of the same size as the suite which was run.
    %
    %   TestResult properties:
    %       Name       - The name of the TestSuite for this result
    %       Passed     - Logical value showing if the test passed
    %       Failed     - Logical value showing if the test failed
    %       Incomplete - Logical value showing if test did not run to completion
    %       Duration   - Time elapsed running test
    %       Details    - Structure containing custom data for this result
    %
    %   Examples:
    %
    %       >> import matlab.unittest.TestSuite;
    %       >> % Result display method provides a summary of the results
    %       >> suite = TestSuite.fromClass(?SomeTestClass)
    %       >> results = run(suite)
    %
    %       results =
    %
    %         1x16 TestResult array with properties:
    %
    %           Name
    %           Passed
    %           Failed
    %           Incomplete
    %           Duration
    %           Details
    %
    %         Totals:
    %           12 Passed, 4 Failed, 0 Incomplete.
    %           5.5091 seconds testing time.
    %       >>
    %       >> % Re-run only the failed tests
    %       >> failedTests = suite([results.Failed]);
    %       >> failedResults = run(failedTests)
    %
    %       failedResults =
    %
    %         1x4 TestResult array with properties:
    %
    %           Name
    %           Passed
    %           Failed
    %           Incomplete
    %           Duration
    %           Details
    %
    %         Test Suite Summary:
    %           0 Passed, 4 Failed, 0 Incomplete.
    %           1.2894 seconds testing time.
    %
    %       >> % Make the fix
    %       >> newResults = run(failedTests)
    %
    %       newResults =
    %
    %         1x4 TestResult array with properties:
    %
    %           Name
    %           Passed
    %           Failed
    %           Incomplete
    %           Duration
    %           Details
    %
    %         Test Suite Summary:
    %           4 Passed, 0 Failed, 0 Incomplete.
    %           1.1607 seconds testing time.
    %
    %   See also: TestSuite, TestRunner
    %
    
    % Copyright 2012-2017 The MathWorks, Inc.
    
    properties (SetAccess = {?matlab.unittest.TestResult, ?matlab.unittest.internal.TestRunData})
        % Duration - Time elapsed running test
        %
        %   The Duration property indicates the amount of time taken to run a
        %   particular test, including the time taken setting up and tearing
        %   down any test fixtures.
        %
        %   Fixture setup time is accounted for in duration of the first
        %   test suite array element that uses the fixture. Fixture
        %   teardown time is accounted for in the duration of the last test
        %   suite array element that uses the fixture.
        %
        %   The total runtime for a suite of tests will exceed the sum of the
        %   durations for all the elements of the suite because the Duration
        %   property does not include all the overhead of the TestRunner
        %   nor any of the time consumed by test runner plugins.
        %
        Duration = 0;
    end
    
    properties (Hidden, SetAccess = {?matlab.unittest.internal.BaseTestResult, ?matlab.unittest.TestRunner})
        Started = false;
        VerificationFailed = false;
        AssumptionFailed = false;
        AssertionFailed = false;
        Errored = false;
        FatalAssertionFailed = false;
    end

    properties (Hidden,Transient, SetAccess = {?matlab.unittest.internal.TestRunData,?matlab.unittest.internal.TestRunnerExtension})
        TestElement matlab.unittest.Test;
        ResultIdentifier string = "";
        TestRunner matlab.unittest.TestRunner;
    end

    properties(SetAccess=protected)
        % Details - Structure containing custom data for this result
        Details = struct;
    end
    
    methods(Hidden)
        function result = TestResult
        end
    end
    
    methods (Hidden, Access={?matlab.unittest.internal.BaseTestResult, ...
            ?matlab.unittest.internal.TestRunData})
        function obj = appendDetailsProperty(obj, propertyName, value, ~)
            for idx = 1:numel(obj)
                if isfield(obj(idx).Details, propertyName)
                    obj(idx).Details.(propertyName) = [obj(idx).Details.(propertyName) value];
                else
                    obj(idx).Details.(propertyName) = value;
                end
            end
        end
    end
    
    methods(Hidden, Access=protected)
        function groups = getPropertyGroups(~)
            import matlab.mixin.util.PropertyGroup;
            
            propList = {'Name','Passed','Failed','Incomplete','Duration', 'Details'};
            groups = PropertyGroup(propList);
        end
        
        function text = getRerunHyperlink(result,outputVarName)
            import matlab.unittest.internal.richFormattingSupported;
            failedTestsMask = [result.Failed];
            
            % Early return if hyperlinking is not necessary
            if ~any(failedTestsMask) || ~richFormattingSupported || any(strlength([result.ResultIdentifier])==0)
                text = char.empty;
                return; 
            end
            allFailureIdentifiers = join(sort(['', result.ResultIdentifier]),",");
            key = matlab.unittest.internal.str2key(allFailureIdentifiers);
            
            text = [' (' sprintf('<a href ="matlab:matlab.unittest.internal.rerunFailedTests(''%s'',''%s'')">%s</a>', outputVarName,key,...
                 getString(message(sprintf('MATLAB:unittest:TestResult:Rerun')))) ,')'];
        end
    end
    
    methods
        function t = table(result)
            t = table@matlab.unittest.internal.BaseTestResult(result);
            t.Details = {result.Details}.';
        end
    end
end

