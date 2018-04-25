classdef ActionEventData < event.EventData
    
    % EventData class used to send events when properties change on the
    % Action.
    
    % Copyright 2017 The MathWorks, Inc.
    properties
        Action;
        Property;
        OldValue;
        NewValue;
        src;
    end
end
