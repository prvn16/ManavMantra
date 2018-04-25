classdef LabelEventData < event.EventData
    % This class is undocumented and subject to change in a future release
    
    % Copyright 2017 The MathWorks, Inc.
    
    properties (SetAccess = immutable)
        Label
    end
    
    methods
        function eventData = LabelEventData(label)
            eventData.Label = label;
        end
    end
    
end