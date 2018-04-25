classdef FormattableString < matlab.mixin.Heterogeneous
    
    % Copyright 2016-2017 The MathWorks, Inc.
    
    properties (Abstract, SetAccess=private)
        Text string;
    end
    
    methods (Abstract)
        str = enrich(str);
        str = wrap(str, width);
    end
    
    methods (Abstract, Access=protected)
        str = applyIndention(str, indentionAmount);
    end
    
    methods (Sealed)
        function txt = char(str)
            import matlab.unittest.internal.richFormattingSupported;
            
            if richFormattingSupported
                str = enrich(str);
            end
            
            txt = char(str.Text);
        end
        
        function c = cellstr(str)
            c = arrayfun(@char, str, 'UniformOutput',false);
        end
        
        function formatted = sprintf(format, varargin)
            import matlab.unittest.internal.diagnostics.FormattedString;
            formatted = FormattedString(format, varargin{:});
        end
        
        function replaced = regexprep(str, pattern, replacement)
            import matlab.unittest.internal.diagnostics.ReplacedString;
            replaced = ReplacedString(str, pattern, replacement);
        end
        
        function joined = join(str, varargin)
            import matlab.unittest.internal.diagnostics.JoinedString;
            joined = JoinedString(str, varargin{:});
        end
        
        function indented = indent(str, varargin)
            import matlab.unittest.internal.diagnostics.IndentedString;
            indented = IndentedString(str, varargin{:});
        end
        
        function withNewline = appendNewlineIfNonempty(str)
            import matlab.unittest.internal.diagnostics.StringPlusNewline;
            withNewline = StringPlusNewline(str);
        end
        
        function indented = indentWithArrow(str)
            import matlab.unittest.internal.diagnostics.ArrowIndentedString;
            indented = ArrowIndentedString(str);
        end
        
        function concatenated = plus(str1, str2)
            import matlab.unittest.internal.diagnostics.JoinedString;
            concatenated = JoinedString([str1, str2], '');
        end
    end
    
    methods (Static, Sealed)
        function str = fromCellstr(cellstr)
            import matlab.unittest.internal.diagnostics.PlainString;
            
            str = cellfun(@(c){PlainString(c)}, cellstr);
            str = [cell.empty, str];
            str = [PlainString.empty, str{:}];
        end
    end
    
    methods (Static, Sealed, Access=protected)
        function str = getDefaultScalarElement
            import matlab.unittest.internal.diagnostics.PlainString;
            str = PlainString;
        end
        
        function converted = convertObject(~, toConvert)
            import matlab.unittest.internal.diagnostics.PlainString;
            
            if ischar(toConvert) || (isscalar(toConvert) && isstring(toConvert))
                converted = PlainString(toConvert);
            end
        end
    end
end

% LocalWords:  isstring
