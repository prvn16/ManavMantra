classdef Completed < matlab.unittest.measurement.internal.states.MeterState
    % This class is undocumented and subject to change in a future release
    
    % Copyright 2016 The MathWorks, Inc.
    
    methods
        
        function B = start(~)
            import matlab.unittest.measurement.internal.states.Sink;
            B = Sink;
        end
        
        function B = stop(~)
            import matlab.unittest.measurement.internal.states.Sink;
            B = Sink;
        end
        
        function B = log(~)
            import matlab.unittest.measurement.internal.states.Sink;
            B = Sink;
        end
        
    end
    
end