classdef BehaviorRole < matlab.mock.internal.Role
    % This class is undocumented and may change in a future release.
    
    % Copyright 2016 The MathWorks, Inc.
    
    methods
        function role = BehaviorRole(varargin)
            role = role@matlab.mock.internal.Role(varargin{:});
        end
        
        function bool = describes(behaviorRole, otherRole)
            bool = otherRole.describedByBehavior(behaviorRole);
        end
    end
end

