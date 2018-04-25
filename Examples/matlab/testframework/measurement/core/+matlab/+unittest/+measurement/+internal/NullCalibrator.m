classdef NullCalibrator < matlab.unittest.measurement.internal.Calibrator
    % This class is undocumented and subject to change in a future release
    
    % Copyright 2016-2017 The MathWorks, Inc.
    
    methods
        
        function calibrate(calibrator,meter,suite) %#ok<INUSD>
            % no-op
        end
        
        function measResult = getCalibrationResults(calibrator,suiteIdx,measResult,meter) %#ok<INUSL,INUSD>
            measResult.CalibrationValue = 0;
        end
        
    end
    
end