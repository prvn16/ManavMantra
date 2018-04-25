classdef Role < matlab.mixin.internal.Scalar
    % This class is undocumented and may change in a future release.
    
    % Copyright 2016-2017 The MathWorks, Inc.
    
    properties (SetAccess=immutable)
        Marker;
        InteractionCatalog (1,1) matlab.mock.internal.InteractionCatalog;
    end
    
    methods
        function role = Role(marker, catalog)
            role.Marker = marker;
            role.InteractionCatalog = catalog;
        end
    end
    
    methods (Abstract)
        bool = describes(role, otherRole);
    end
    
    methods (Access=protected)
        function bool = describedByBehavior(~, ~)
            bool = false;
        end
    end
end

