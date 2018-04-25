classdef LeafFormattableString < matlab.unittest.internal.diagnostics.FormattableString
    % LeafFormattableString - A FormattableString that does not hold onto other FormattableStrings.
    
    % Copyright 2016 The MathWorks, Inc.
    
    methods
        function str = enrich(str)
        end
        
        function str = wrap(str, ~)
        end
    end
    
    methods (Access=protected)
        function str = applyIndention(str, ~)
        end
    end
end

% LocalWords:  Formattable
