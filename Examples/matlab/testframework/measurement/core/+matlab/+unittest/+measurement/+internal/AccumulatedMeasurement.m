classdef AccumulatedMeasurement < matlab.unittest.measurement.internal.MeasurementInterface
    
    % Copyright 2017 The MathWorks, Inc.
    
    properties(SetAccess = private)
        Measurements matlab.unittest.measurement.internal.Measurement;
    end
    
    properties(Dependent, SetAccess = immutable)
        Value
        Timestamp
    end
    
    methods
        function measurement = AccumulatedMeasurement(measurements)
            measurement.Measurements = measurements;
        end
        
        function measurement = addMeasurement(measurement,newmeasurement)
            measurement.Measurements = [measurement.Measurements, newmeasurement];
        end
        
        function measurement = removeLastMeasurement(measurement)
            if ~isempty(measurement.Measurements)
                measurement.Measurements = measurement.Measurements(1:end-1);
            end
        end
        
        function value = get.Value(measurement)
            value = sum([measurement.Measurements.Value]);
        end
        
        function value = get.Timestamp(measurement)
            if ~isempty(measurement.Measurements)
                value = measurement.Measurements(end).Timestamp;
            else
                value = NaT;
            end
        end
        
        function t = getTaredValue(measurement,tare)
            % Using for loop instead of arrayfun because for loop is faster
            t = 0;
            for i = 1:length(measurement.Measurements)
                t = t + measurement.Measurements(i).getTaredValue(tare);
            end
        end
    end
    
    methods(Hidden)
        function tf = isOutsidePrecision(measurement,tare,threshold)
            if nargin < 3
                threshold = 5;
            end
            
            tf = all(arrayfun(@(m)m.isOutsidePrecision(tare,threshold),...
                measurement.Measurements));
        end
    end
end