classdef CompositeFormattableString < matlab.unittest.internal.diagnostics.FormattableString
    % CompositeFormattableString - A FormattableString that holds onto other FormattableStrings.
    
    % Copyright 2016 The MathWorks, Inc.
    
    properties (SetAccess=private)
        ComposedString matlab.unittest.internal.diagnostics.FormattableString;
    end
    
    properties (Dependent, SetAccess=private)
        ComposedText string;
    end
    
    methods
        function composite = CompositeFormattableString(composedString)
            composite.ComposedString = composedString;
        end
        
        function str = get.ComposedText(composite)
            str = [string.empty, composite.ComposedString.Text];
        end
    end
    
    methods (Sealed)
        function str = enrich(str)
            for idx = 1:numel(str.ComposedString)
                str.ComposedString(idx) = enrich(str.ComposedString(idx));
            end
        end
        
        function str = wrap(str, width)
            for idx = 1:numel(str.ComposedString)
                str.ComposedString(idx) = wrap(str.ComposedString(idx), width);
            end
        end
    end
    
    methods (Sealed, Access=protected)
        function str = applyIndention(str, indentionAmount)
            for idx = 1:numel(str.ComposedString)
                str.ComposedString(idx) = applyIndention(str.ComposedString(idx), indentionAmount);
            end
        end
    end
end

% LocalWords:  Formattable
