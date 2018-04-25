classdef MeasurementEventData < event.EventData
    % This class is undocumented and subject to change in a future release
    
    % Copyright 2015-2016 The MathWorks, Inc.
    
    properties (SetAccess = immutable)
        Value
        Index
    end
    
    methods
        
        function eventData = MeasurementEventData(value,index)
            eventData.Value = value;
            eventData.Index = index;
        end
        
    end
    
end