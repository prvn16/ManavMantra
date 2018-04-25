classdef MultilineText
    % This class is unsupported and might change or be removed without
    % notice in a future version.
    
    % Used as a property type for multiline text
    
    % Copyright 2017 The MathWorks, Inc.

    properties(Access = private)
        Lines;
    end
    
    methods
        function this = MultilineText(v)
            this.Lines = v;
        end
        
        function v = getLines(this)
            v = this.Lines;
        end
    end
end
