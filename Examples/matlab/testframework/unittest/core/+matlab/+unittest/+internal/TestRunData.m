classdef TestRunData < handle
    % This class is undocumented.
    
    % Copyright 2013-2017 The MathWorks, Inc.
    
    properties (Abstract)
        TestResult;
        CurrentIndex;
        CurrentResult;
    end
    
    properties (Abstract, SetAccess=private)
        RepeatIndex;
    end
    
    properties (Abstract, SetAccess=immutable)
        TestSuite;
        RunIdentifier;
    end
    
    properties (Abstract, Constant)
        ShouldEnterRepeatLoopScope logical;
    end
    
    properties (Dependent)
        CurrentSuite;
    end
    
    properties (SetAccess=protected)
        HasCompletedTestRepetitions = true;
    end
    
    methods (Abstract)
        resetRepeatLoop(data);
        beginRepeatLoopIteration(data);
        bool = shouldContinueRepeatLoop(data);
        endRepeatLoop(data);
        
        addDurationToCurrentResult(data, duration);
        appendDetails(data, propertyName, value, index, distributeLoop);
    end
    
    methods
        function suite = get.CurrentSuite(data)
            suite = data.TestSuite(data.CurrentIndex);
        end
    end
end

