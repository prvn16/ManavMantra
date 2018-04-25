classdef BoldableString < matlab.unittest.internal.diagnostics.LeafFormattableString
    
    % Copyright 2016-2017 The MathWorks, Inc.
    
    properties (Dependent, SetAccess=private)
        Text string;
    end
    
    properties (SetAccess=private)
        BoldableText (1,1) string;
    end
    
    methods
        function str = BoldableString(txt)
            str.BoldableText = txt;
        end
        
        function txt = get.Text(str)
            txt = str.BoldableText;
        end
        
        function str = enrich(str)
            import matlab.unittest.internal.diagnostics.BoldedString;
            str = BoldedString(str);
        end
    end
end

% LocalWords:  Formattable Boldable Bolded
