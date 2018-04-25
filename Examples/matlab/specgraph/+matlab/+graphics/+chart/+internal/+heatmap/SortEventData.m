classdef SortEventData < event.EventData
    
    %   Copyright 2017 The MathWorks, Inc.
    
    properties (SetAccess = ?matlab.graphics.chart.internal.heatmap.SortAffordance)
        Axis
        OldState
        NewState
    end
end
