classdef DragToRearrangeEventData < event.EventData
    
    %   Copyright 2017 The MathWorks, Inc.
    
    properties (SetAccess = ?matlab.graphics.chart.internal.heatmap.DragToRearrange)
        Axis
        Item
        StartIndex
        EndIndex
        DragOccurred
        HitObject
    end
end
