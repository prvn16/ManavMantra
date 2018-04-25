classdef RunRepeatedlyTestRunData < matlab.unittest.internal.TestRunData
    % This class is undocumented.
    
    %  Copyright 2017 The MathWorks, Inc.
    
    properties(Dependent)
        CurrentIndex;
        CurrentResult;
    end
    
    properties
        TestResult;
    end
    
    properties (SetAccess=private)
        RepeatIndex = 1;
    end
    
    properties (SetAccess=immutable)
        TestSuite;
        RunIdentifier;
    end

    properties (Constant)
        ShouldEnterRepeatLoopScope = true;
    end
    
    properties(Access=private)
        NumRepetitions;
        EarlyTerminationFcn;     
        InternalCurrentIndex = 1;
        ResultPrototype;
    end
    
    methods (Static)
        function data = fromSuite(suite, runIdentifier, numRepetitions, earlyTerminationFcn,runner)
            import matlab.unittest.internal.RunRepeatedlyTestRunData;
            
            result = createInitialCompositeTestResult(suite,runner);
            data = RunRepeatedlyTestRunData(suite, result, runIdentifier, numRepetitions, earlyTerminationFcn);
        end
    end
    
    methods (Access=protected)
        function data = RunRepeatedlyTestRunData(suite, result, runIdentifier, numRepetitions, earlyTerminationFcn)
            data.TestSuite = suite;
            data.TestResult = result;
            data.RunIdentifier = runIdentifier;
            data.NumRepetitions = numRepetitions;
            data.EarlyTerminationFcn = earlyTerminationFcn;
        end
    end
    
    methods
        function resetRepeatLoop(data)
            % Use the first child TestResult as the prototype for future
            % repeat loop iterations.
            data.ResultPrototype = data.CurrentResult;
            
            data.HasCompletedTestRepetitions = false;
            data.RepeatIndex = 0;
        end
        
        function beginRepeatLoopIteration(data)
            import matlab.unittest.internal.generateUUID;
            data.RepeatIndex = data.RepeatIndex + 1;
            
            if data.RepeatIndex > 1
                % Initialize current result from the prototype, resetting
                % the duration to zero
                data.CurrentResult = data.ResultPrototype;
                data.CurrentResult.Duration = 0;
                data.CurrentResult.ResultIdentifier = generateUUID();
            end
        end
        
        function bool = shouldContinueRepeatLoop(data)
            bool = ~data.EarlyTerminationFcn(data.CurrentResult, data.InternalCurrentIndex) && ...
                data.RepeatIndex < data.NumRepetitions;
        end
        
        function endRepeatLoop(data)
            data.HasCompletedTestRepetitions = true;
        end
        
        function addDurationToCurrentResult(data, duration)
            data.TestResult(data.InternalCurrentIndex).TestResult(data.RepeatIndex).Duration = ...
                data.TestResult(data.InternalCurrentIndex).TestResult(data.RepeatIndex).Duration + duration;
        end
        
        function appendDetails(data, propertyName, value, index, distributeLoop)
            args = {};
            if ~distributeLoop
                args = {data.RepeatIndex};
            end
            data.TestResult(index) = data.TestResult(index).appendDetailsProperty(propertyName, value, args{:});
        end
        
        function set.CurrentIndex(data, index)
            data.InternalCurrentIndex = index;
            data.RepeatIndex = 1;
        end
        
        function index = get.CurrentIndex(data)
            index = data.InternalCurrentIndex;
        end
        
        function result = get.CurrentResult(data)
            result = data.TestResult(data.InternalCurrentIndex).TestResult(data.RepeatIndex);
        end
        
        function set.CurrentResult(data, result)
            data.TestResult(data.InternalCurrentIndex).TestResult(data.RepeatIndex) = result;
        end
    end
end

function result = createInitialCompositeTestResult(suite,runner)
% Creates an initial CompositeTestResult that is of the same size as the
% suite passed, transferring the suite element name

import matlab.unittest.CompositeTestResult;
import matlab.unittest.TestResult;
import matlab.unittest.internal.generateUUID;

result = CompositeTestResult.empty;
numElements = numel(suite);
% Create the initial test result with right size & shape
if numElements > 0
    result(numElements) = CompositeTestResult;
end
result = reshape(result, size(suite));

uuid = generateUUID(numElements);
for idx = 1:numElements
    s = suite(idx);
    name = s.Name;
    result(idx).Name = name;
    leafResult = TestResult;
    leafResult.Name = name;
    leafResult.TestElement = s;
    leafResult.TestRunner = runner;
    leafResult.ResultIdentifier = uuid(idx);
    result(idx).TestResult = leafResult;
end
end
