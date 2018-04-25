classdef MockObjectRole < matlab.mock.internal.Role
    % This class is undocumented and may change in a future release.
    
    % Copyright 2016 The MathWorks, Inc.
    
    methods
        function role = MockObjectRole(varargin)
            role = role@matlab.mock.internal.Role(varargin{:});
        end
        
        function bool = describes(~, ~)
            bool = false;
        end
    end
    
    methods (Access=protected)
        function bool = describedByBehavior(mockObjectRole, behavior)
            bool = mockObjectRole.Marker == behavior.Marker;
        end
    end
end

