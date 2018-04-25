classdef IndentedString < matlab.unittest.internal.diagnostics.CompositeFormattableString
    
    % Copyright 2016 The MathWorks, Inc.
    
    properties (Dependent, SetAccess=private)
        Text string;
    end
    
    properties (SetAccess=immutable)
        Indention string = "    ";
    end
    
    methods
        function indented = IndentedString(str, indention)
            import matlab.internal.display.wrappedLength;
            
            indented = indented@matlab.unittest.internal.diagnostics.CompositeFormattableString(str);
            if nargin > 1
                indented.Indention = indention;
            end
            
            indented = indented.applyIndention(wrappedLength(indented.Indention));
        end
        
        function txt = get.Text(str)
            txt = str.ComposedText;
            if txt == ""
                return;
            end
            txt = join(str.Indention + splitlines(txt), newline);
        end
    end
end

% LocalWords:  Formattable splitlines
