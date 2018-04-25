classdef DefaultMeasurement < matlab.unittest.measurement.internal.MeasurementInterface
    % DefaultMeasurement, placeholder for MeasurementInterface
    % This class is undocumented and subject to change in a future release
    
    % Copyright 2017 The MathWorks, Inc.
    
    properties (SetAccess = immutable)
        Value = NaN;
        Timestamp = NaT;
    end
    
    methods            
        function t = getTaredValue(~,~)
           t = NaN;
        end
    end
    
    methods(Hidden)
        function tf = isOutsidePrecision(~,~,~)
            tf = true;
        end
    end
  
end