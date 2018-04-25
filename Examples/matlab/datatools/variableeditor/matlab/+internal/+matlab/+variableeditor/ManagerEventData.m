classdef ManagerEventData < event.EventData & JavaVisible
    % Event Data Class used when sending manager events from the Manager
    % Factory
    properties
        Manager % The indicies of the changed data
    end
end
