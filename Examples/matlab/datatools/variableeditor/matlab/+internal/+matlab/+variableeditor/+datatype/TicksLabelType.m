classdef TicksLabelType
    % This class is unsupported and might change or be removed without
    % notice in a future version.
    
    % Used as a property type for the TickLabel property 
    
    % Copyright 2017 The MathWorks, Inc.

    properties(Access = private)
        Val;
    end
    
    methods
        function this = TicksLabelType(v)
            this.Val = v;
        end
        
        function v = getText(this)
            v = this.Val;
        end
    end
end
