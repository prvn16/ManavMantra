classdef (Hidden) TicTocMeter < matlab.unittest.measurement.internal.Meter
    % This class is undocumented and subject to change in a future release
    
    
    % Copyright 2015-2017 The MathWorks, Inc.
    
    properties(Access=private)
        TimerValue = uint64(0);
    end
    
    methods
        
        function start(meter,~)
            meter.State = start(meter.State);
            meter.TimerValue = tic; % Always should be last
        end
        
        function stop(meter,label)
            import matlab.unittest.measurement.internal.Measurement;
            
            timingResult = toc(meter.TimerValue); % Always should be first
            
            meter.State = stop(meter.State);
            measurement = Measurement(timingResult,datetime);
            meter.addMeasurement(measurement,label);
        end
        
    end
    
    methods(Access=protected)
        function m = createEmptyMeasurement(~)
            import matlab.unittest.measurement.internal.AccumulatedMeasurement;
            import matlab.unittest.measurement.internal.Measurement;
            m = AccumulatedMeasurement(Measurement.empty);
        end
    end
    
    methods (Hidden)
        
        function logTimeMeasurement(meter,measurement,label)
            
            meter.State = log(meter.State);
            meter.addMeasurement(measurement,label);

        end
        
    end
    
end