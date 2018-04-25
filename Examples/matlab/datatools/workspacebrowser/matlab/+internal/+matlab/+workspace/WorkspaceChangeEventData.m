classdef WorkspaceChangeEventData < event.EventData & JavaVisible
    % Event Data Class used when sending data events from either the
    % DataModel or the ViewModel
    properties
        Variables
    end
end
