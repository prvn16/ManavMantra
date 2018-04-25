classdef (Hidden) WarningHistory
    % This class is undocumented and may change in a future release.
    
    % Copyright 2015 The MathWorks, Inc.
    
    properties (Hidden, SetAccess=immutable, GetAccess=?matlab.unittest.internal.plugins.IsWarningFree)
        Name;
        Warnings;
    end
    
    methods
        function history = WarningHistory(name, warnings)
            history.Name = name;
            history.Warnings = warnings;
        end
    end
end

