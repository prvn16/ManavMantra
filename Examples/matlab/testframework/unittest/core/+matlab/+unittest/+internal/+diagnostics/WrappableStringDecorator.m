classdef WrappableStringDecorator < matlab.unittest.internal.diagnostics.FormattableString
    
    % Copyright 2016 The MathWorks, Inc.
    
    properties (Dependent, SetAccess=private)
        Text string;
    end
    
    properties (SetAccess=private)
        StringToWrap matlab.unittest.internal.diagnostics.LeafFormattableString;
    end
    
    properties (SetAccess=private)
        IndentionAmount double = 0;
    end
    
    methods
        function str = WrappableStringDecorator(stringToWrap)
            str.StringToWrap = stringToWrap;
        end
        
        function txt = get.Text(str)
            txt = str.StringToWrap.Text;
        end
        
        function str = enrich(str)
            str.StringToWrap = enrich(str.StringToWrap);
        end
        
        function str = wrap(str, width)
            import matlab.unittest.internal.diagnostics.WrappedString;
            str = WrappedString(str, width);
        end
    end
    
    methods (Access=protected)
        function str = applyIndention(str, indentionAmount)
            str.IndentionAmount = str.IndentionAmount + indentionAmount;
        end
    end
end

% LocalWords:  Formattable
