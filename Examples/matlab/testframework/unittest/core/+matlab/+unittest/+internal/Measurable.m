classdef(Hidden) Measurable < handle
    % This class is undocumented and may change in a future release.
    
    % Copyright 2015-2017 The MathWorks, Inc.
    
    events(Hidden, NotifyAccess={...
            ?matlab.unittest.internal.Measurable, ...
            ?matlab.unittest.internal.TestCaseProvider, ...
            ?matlab.unittest.TestRunner})
        MeasurementStarted
        MeasurementStopped
    end
    
    events(Hidden, NotifyAccess=protected)
        MeasurementLogged
    end
    
end