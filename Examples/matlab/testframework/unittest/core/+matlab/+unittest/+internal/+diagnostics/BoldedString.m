classdef BoldedString < matlab.unittest.internal.diagnostics.LeafFormattableString
    
    % Copyright 2016-2017 The MathWorks, Inc.
    
    properties (Dependent, SetAccess=private)
        Text string;
    end
    
    properties (SetAccess=private)
        BoldableString (1,1) matlab.unittest.internal.diagnostics.BoldableString = ...
            matlab.unittest.internal.diagnostics.BoldableString("");
    end
    
    methods
        function str = BoldedString(boldableString)
            str.BoldableString = boldableString;
        end
        
        function txt = get.Text(str)
            txt = sprintf("<strong>%s</strong>", str.BoldableString.BoldableText);
        end
    end
end

% LocalWords:  Formattable  Boldable boldable
