classdef ClassBasedTest < matlab.unittest.TestCase & matlab.unittest.measurement.internal.Measurable
    % This class is undocumented and subject to change in a future release
    
    % Copyright 2015 The MathWorks, Inc.
    
        
    methods(Test)
        function selfMeasured(testCase)
            testCase.startMeasuring;
            testCase.stopMeasuring;
        end
    end
    
end
%#ok<*MANU>
%#ok<*INUSD>