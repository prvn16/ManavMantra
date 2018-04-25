classdef ListEntry < handle
    % This class is undocumented and may change in a future release.
    
    % Copyright 2015-2017 The MathWorks, Inc.
    
    properties
        Value;
    end
    
    properties (SetAccess=immutable)
        ID (1,1) uint64;
    end
    
    methods
        function entry = ListEntry(value, id)
            entry.Value = value;
            if nargin > 1
                entry.ID = id;
            end
        end
    end
end

