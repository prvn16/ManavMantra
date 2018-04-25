classdef FPTEventData < event.EventData
% FPTEVENTDATA Object to pass information about events in FPT.

% Copyright 2012 MathWorks, Inc

    properties
       SourceObj;
       FPTEventName;
    end
    
    methods
        function this = FPTEventData(source, eventName)
            this.SourceObj = source;
            this.FPTEventName = eventName;
        end
    end
end
