classdef DocumentChangeEventData < event.EventData
    % EventData class used when sending document change events from the
    % manager class
    properties
        Name; % The name of the changed variable
        Workspace; % The workspace of the changed variable
        Document; % The document changed if available.
    end
end

