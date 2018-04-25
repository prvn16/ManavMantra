classdef ArrowIndentedString < matlab.unittest.internal.diagnostics.CompositeFormattableString
    
    % Copyright 2016 The MathWorks, Inc.
    
    properties (Dependent, SetAccess=private)
        Text string;
    end
    
    properties (Constant, Access=private)
        Arrow string = "--> ";
        Spaces string = "    ";
    end
    
    methods
        function indented = ArrowIndentedString(str)
            import matlab.internal.display.wrappedLength;
            
            indented = indented@matlab.unittest.internal.diagnostics.CompositeFormattableString(str);
            indented = indented.applyIndention(wrappedLength(char(indented.Arrow)));
        end
        
        function txt = get.Text(str)
            lines = splitlines(str.ComposedText).';
            txt = join([str.Arrow + lines(1), str.Spaces + lines(2:end)], newline);
        end
    end
end

% LocalWords:  Formattable splitlines
