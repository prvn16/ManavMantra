classdef StringPlusNewline < matlab.unittest.internal.diagnostics.CompositeFormattableString
    
    % Copyright 2016 The MathWorks, Inc.
    
    properties (Dependent, SetAccess=private)
        Text string;
    end
    
    methods
        function withNewline = StringPlusNewline(str)
            withNewline = withNewline@matlab.unittest.internal.diagnostics.CompositeFormattableString(str);
        end
        
        function txt = get.Text(str)
            txt = str.ComposedText;
            if txt == ""
                return;
            end
            txt = txt + newline;
        end
    end
end

% LocalWords:  Formattable
