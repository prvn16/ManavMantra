classdef Unused < matlab.unittest.measurement.internal.states.MeterState
    % This class is undocumented and subject to change in a future release
    
    % Copyright 2016 The MathWorks, Inc.
    
    methods
        
        function state = start(~)
            import matlab.unittest.measurement.internal.states.Running;
            state = Running;
        end
        
        function state = stop(~)
            import matlab.unittest.measurement.internal.states.Sink;
            state = Sink;
        end
        
        function state = log(~)
            import matlab.unittest.measurement.internal.states.Sink;
            state = Sink;
        end
        
    end
    
end