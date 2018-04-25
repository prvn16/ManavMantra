classdef MetaDataChangeEventData < event.EventData & JavaVisible
    % Event Data Class used when sending data events from either the
    % DataModel or the ViewModel
    properties
        Property % The Meta Data Property that Changed
        IsTypeChange % True if this is a datatype change
        OldValue % The old data values
        NewValue % The new data values
    end
end
