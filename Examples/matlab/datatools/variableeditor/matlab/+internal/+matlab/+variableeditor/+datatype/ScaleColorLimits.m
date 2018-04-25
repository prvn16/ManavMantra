classdef ScaleColorLimits
    % This class is unsupported and might change or be removed without
    % notice in a future version.
    
    % Copyright 2017 The MathWorks, Inc.

    properties(Access = private)
        Limits;
    end
    
    methods
        function this = ScaleColorLimits(v)
            this.Limits = v;
        end
        
        function v = getLimits(this)
            v = this.Limits;
        end
    end
end
