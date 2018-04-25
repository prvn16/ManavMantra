classdef DataChangeEventData < event.EventData & JavaVisible
    % Event Data Class used when sending data events from either the
    % DataModel or the ViewModel
    properties
        Range % The indicies of the changed data
        Values % The new data values
        DimensionsChanged % size of data changed
    end
end
