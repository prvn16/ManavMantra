classdef Running < matlab.unittest.measurement.internal.states.MeterState
    % This class is undocumented and subject to change in a future release
    
    % Copyright 2016 The MathWorks, Inc.
    
    methods
        
        function state = start(~)
            import matlab.unittest.measurement.internal.states.Started;
            state = Started;
        end
        
        function state = stop(~)
            import matlab.unittest.measurement.internal.states.Completed;
            state = Completed;
        end
        
        function state = log(state)
        end
        
    end
    
end