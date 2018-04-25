classdef PropertyChangeEventData < event.EventData & JavaVisible
    % This class is unsupported and might change or be removed without
    % notice in a future version.
    
    % Event Data Class used when sending data events from either the
    % DataModel or the ViewModel for property changes
    
    % Copyright 2015 The MathWorks, Inc.
    properties
        Properties % The properties which changed
        Values % The new data values
    end
end
