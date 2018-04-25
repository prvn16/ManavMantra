% Copyright 2014 The MathWorks, Inc.

classdef FilterUpdate < handle
    events
        settingsChanged
    end
    
    properties
        currentSelections = [];
    end
    
    methods
        function obj = FilterUpdate
        end
    end
end