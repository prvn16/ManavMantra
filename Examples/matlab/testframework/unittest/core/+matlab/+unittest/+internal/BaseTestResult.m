classdef (Hidden) BaseTestResult < matlab.mixin.CustomDisplay
    % BaseTestResult - Fundamental interface for test result.
        
    % Copyright 2015-2017 The MathWorks, Inc.
    
    properties (SetAccess = {?matlab.unittest.internal.BaseTestResult, ?matlab.unittest.internal.TestRunData})
        % Name - The name of the TestSuite for this result
        %
        %   The Name property is a string that holds the name of the test
        %   corresponding to this result.
        Name char = '';
    end
    
    properties (Dependent, SetAccess = private)
        % Passed - Logical value showing if the test passed
        %
        %   When the Passed property is TRUE, then the test completed as expected
        %   without any failure. When it is FALSE, then the test did not run to
        %   completion and/or encountered a failure condition.
        %
        Passed
        
        % Failed - Logical value showing if the test failed
        %
        %   A TRUE Failed property indicates some form of test failure. When it is
        %   FALSE, then no failing conditions were encountered. A failing result
        %   can occur with a failure condition in either a test or when setting
        %   up and tearing down test fixtures. Failures can occur due to the
        %   following:
        %       - Verification failures
        %       - Assertion failures
        %       - Uncaught MExceptions
        %
        %   Fatal assertions are also failing conditions, but in the
        %   event of a fatal assertion failure the entire framework aborts and a
        %   TestResult is never produced.
        %
        Failed
        
        % Incomplete - Logical value showing if test did not run to completion
        %
        %   A TRUE Incomplete property indicates when a test did not run to
        %   completion. When it is FALSE, then no conditions were encountered that
        %   prevented the test from completing. In other words, when FALSE there
        %   were no stack disruptions out of the running test content. An
        %   incomplete result can occur with a stack disruption in either a test or
        %   when setting up and tearing down test fixtures. Incomplete tests can
        %   occur due to the following:
        %       - Assumption failures
        %       - Assertion failures
        %       - Uncaught MExceptions
        %
        %   Fatal assertions are also conditions that prevent the completion of
        %   tests, but in the event of a fatal assertion failure the entire
        %   framework aborts and a TestResult is never produced.
        %
        Incomplete
    end
    
    properties (Abstract, SetAccess = {?matlab.unittest.TestRunner})
        Duration;
    end
    
    properties (Abstract, Hidden, SetAccess = {?matlab.unittest.internal.BaseTestResult, ?matlab.unittest.TestRunner})
        Started;
        VerificationFailed;
        AssumptionFailed;
        AssertionFailed;
        Errored;
        FatalAssertionFailed;
    end
    
    properties (Hidden, Dependent, SetAccess = private)
        Completed;
    end
    
    methods
        function t = table(result)
            % table - Convert a TestResult to a table
            %
            %   TABLE = table(TESTRESULT) creates a table using the information
            %   contained in TESTRESULT, which is a matlab.unittest.TestResult array.
            %
            %
            %   Examples:
            %
            %       % Run a suite of tests and produce a table of the result
            %       result = runtests('someTestFolder');
            %       resultsTable = table(result);
            %
            %       % Display a summary of the results
            %       summary(resultsTable);
            %
            %       % Sort the results to find long running tests
            %       sorted = sortrows(resultsTable, 'Duration', 'descend');
            %
            %       % Save the results to a CSV file
            %       writetable(resultsTable, 'TestResults.csv');
            %
            %   See also: table
            
            t = table();
            t.Name = {result.Name}';
            t.Passed = [result.Passed]';
            t.Failed = [result.Failed]';
            t.Incomplete = [result.Incomplete]';
            t.Duration = [result.Duration].';
        end
    end
    
    methods(Hidden, Access = protected)
        function footerStr = getFooter(result)
            % getFooter - Override of the matlab.mixin.CustomDisplay hook method
            %   Displays a summary of the test results.
            
            import matlab.unittest.internal.diagnostics.indent;
            
            totals = getString(message('MATLAB:unittest:TestResult:Totals'));
            outputVarName = inputname(1);
            
            passedFailedIncomplete = ...
                getString(message('MATLAB:unittest:TestResult:PassedFailedIncomplete', ...
                nnz([result.Passed]), ...
                nnz([result.Failed]),result.getRerunHyperlink(outputVarName), ...
                nnz([result.Incomplete])));
            
            duration = getString(message('MATLAB:unittest:TestResult:Duration', ...
                num2str(sum([result.Duration]))));
            
            indention = '   ';
            footerStr = sprintf('%s\n%s\n%s\n', totals, ...
                indent(passedFailedIncomplete, indention), ...
                indent(duration, indention));
        end
        
        function groups = getPropertyGroups(~)
            import matlab.mixin.util.PropertyGroup;
            
            propList = {'Name','Passed','Failed','Incomplete','Duration'};
            groups = PropertyGroup(propList);
        end
        
        function text = getRerunHyperlink(~,~)
            % Default returns empty
            text = char.empty;
        end
        
    end
    
    methods(Hidden)
        function result = flatten(result)
            % Return a flat TestResult array. By default just returns the array itself.
        end
    end
    
    methods (Abstract, Hidden, Access={?matlab.unittest.internal.BaseTestResult, ...
            ?matlab.unittest.internal.TestRunData})
        obj = appendDetailsProperty(obj, propertyName, value, childIndex);
    end
    
    methods
        function passed = get.Passed(result)
            passed = ...
                result.Completed && ...
                ~result.Failed;
        end
        
        function failed = get.Failed(result)
            failed = ...
                result.VerificationFailed || ...
                result.AssertionFailed || ...
                result.Errored || ...
                result.FatalAssertionFailed;
        end
        
        function incomplete = get.Incomplete(result)
            incomplete = ...
                result.AssumptionFailed || ...
                result.AssertionFailed || ...
                result.Errored || ...
                result.FatalAssertionFailed;
        end
        
        function completed = get.Completed(result)
            completed = ...
                result.Started && ...
                ~result.Incomplete;
        end
        
    end
    
    
end

% LocalWords:  TESTRESULT plugindata
