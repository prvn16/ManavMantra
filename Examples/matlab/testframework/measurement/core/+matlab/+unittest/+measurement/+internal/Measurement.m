classdef Measurement <matlab.unittest.measurement.internal.MeasurementInterface
    % This class is undocumented and subject to change in a future release
    
    % Copyright 2015-2017 The MathWorks, Inc.      
    
    properties (SetAccess = immutable)
        Value
        Timestamp
    end
    
    methods
        function measurement = Measurement(value, timestamp)
            if nargin < 1
                return % Allow preallocation
            end
            measurement.Value = value;
            measurement.Timestamp = timestamp;
        end
        
        function t = getTaredValue(measurement,tare)
            t = [measurement.Value] - tare;
        end
    end
    
    methods(Hidden)
        function tf = isOutsidePrecision(measurement,tare,threshold)
            if nargin < 3
                threshold = 5;
            end
            tf = measurement.getTaredValue(tare) > threshold * tare;
        end
    end
            
end