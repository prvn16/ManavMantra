classdef CommandHyperlinkedString < matlab.unittest.internal.diagnostics.LeafFormattableString
    
    % Copyright 2016-2017 The MathWorks, Inc.
    
    properties (Dependent, SetAccess=private)
        Text string;
    end
    
    properties (SetAccess=private)
        HyperlinkableString (1,1) matlab.unittest.internal.diagnostics.CommandHyperlinkableString = ...
            matlab.unittest.internal.diagnostics.CommandHyperlinkableString("","");
    end
    
    methods
        function str = CommandHyperlinkedString(hyperlinkableString)
            str.HyperlinkableString = hyperlinkableString;
        end
        
        function txt = get.Text(str)
            style = str.HyperlinkableString.Style;
            if strlength(style) > 0
                style = sprintf(" style=""%s""", style);
            end
            
            txt = sprintf("<a href=""matlab:%s""%s>%s</a>", ...
                str.HyperlinkableString.CommandToExecute, ...
                style, ...
                str.HyperlinkableString.LinkText);
        end
    end
end

% LocalWords:  Formattable Hyperlinkable hyperlinkable strlength
