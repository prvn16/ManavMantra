classdef ModelChangeEventData < event.EventData & JavaVisible
    % Event Data Class used when sending model changed events from the
    % ViewModel
    properties
        Row % Row Number
        Column % Column Number
        Key % The parameter changed
        OldValue % Previous Value
        NewValue % The new data value
    end
end
