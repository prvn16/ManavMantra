classdef ScaleColors
    % This class is unsupported and might change or be removed without
    % notice in a future version.
    
    % Copyright 2017 The MathWorks, Inc.

    properties(Access = private)
        Colors;
    end
    
    methods
        function this = ScaleColors(v)
            this.Colors = v;
        end
        
        function v = getColors(this)
            v = this.Colors;
        end
    end
end
