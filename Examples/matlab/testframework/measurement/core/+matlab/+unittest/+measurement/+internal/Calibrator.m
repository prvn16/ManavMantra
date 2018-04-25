classdef (Abstract) Calibrator < handle
    % This class is undocumented and subject to change in a future release
    
    % Copyright 2016-2017 The MathWorks, Inc.
    
    methods (Abstract)
        
        calibrate(calibrator,meter,suite)
        
        measResult = getCalibrationResults(calibrator,suiteIdx,measResult,meter)
    end
    
end