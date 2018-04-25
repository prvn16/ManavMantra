classdef RunOnceTestRunData < matlab.unittest.internal.TestRunData
    % This class is undocumented.
    
    %  Copyright 2017 The MathWorks, Inc.
    
    properties (Dependent)
        CurrentResult;
    end
    
    properties
        TestResult;
        CurrentIndex = 1;
    end
    
    properties (SetAccess=private)
        RepeatIndex = 1;
    end
    
    properties (SetAccess=immutable)
        TestSuite;
        RunIdentifier;
    end
    
    properties (Constant)
        ShouldEnterRepeatLoopScope = false;
    end
    
    methods (Static)
        function data = fromSuite(suite, runIdentifier,runner)
            import matlab.unittest.internal.RunOnceTestRunData;
            
            result = createInitialTestResult(suite,runner);
            data = RunOnceTestRunData(suite, result, runIdentifier);
        end
    end
    
    methods (Access=protected)
        function data = RunOnceTestRunData(suite, result, runIdentifier)
            data.TestSuite = suite;
            data.TestResult = result;
            data.RunIdentifier = runIdentifier;
        end
    end
    
    methods
        function resetRepeatLoop(~)
            % Do nothing
        end
        
        function beginRepeatLoopIteration(~)
            % Do nothing
        end
        
        function bool = shouldContinueRepeatLoop(~)
            bool = false;
        end
        
        function endRepeatLoop(~)
            % Do nothing
        end
        
        function addDurationToCurrentResult(data, duration)
            data.TestResult(data.CurrentIndex).Duration = data.TestResult(data.CurrentIndex).Duration + duration;
        end
        
        function appendDetails(data, propertyName, value, index, ~)
             data.TestResult(index) = data.TestResult(index).appendDetailsProperty(propertyName, value);
        end
        
        function result = get.CurrentResult(data)
            result = data.TestResult(data.CurrentIndex);
        end
        
        function set.CurrentResult(data, result)
            data.TestResult(data.CurrentIndex) = result;
        end
    end
end

function result = createInitialTestResult(suite,runner)
% Create an initial TestResult that is of the same size as the suite passed
% in, transferring the suite element names

import matlab.unittest.internal.generateUUID;
import matlab.unittest.TestResult;

result = TestResult.empty;
numElements = numel(suite);
% Create the initial test result with right size & shape
if numElements > 0
    result(numElements) = TestResult;
end
result = reshape(result, size(suite));

uuid = generateUUID(numElements);
for idx = 1:numElements
    s = suite(idx);
    result(idx).TestElement = s;
    result(idx).Name = s.Name;
    result(idx).TestRunner = runner;
    result(idx).ResultIdentifier = uuid(idx);
end

end
