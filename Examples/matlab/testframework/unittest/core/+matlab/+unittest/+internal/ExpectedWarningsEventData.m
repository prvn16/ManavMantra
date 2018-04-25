classdef(Hidden) ExpectedWarningsEventData <  event.EventData
    %This class is undocumented and may change in a future release.
    
    %  Copyright 2013-2016 The MathWorks, Inc.
    properties
        ExpectedWarnings;
    end

    methods
        function evd = ExpectedWarningsEventData(warnings)
            evd.ExpectedWarnings = warnings;
        end
    end
end

