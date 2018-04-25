classdef CommandHyperlinkableString < matlab.unittest.internal.diagnostics.LeafFormattableString
    
    % Copyright 2016-2017 The MathWorks, Inc.
    
    properties (Dependent, SetAccess=private)
        Text string;
    end
    
    properties (SetAccess=private)
        LinkText (1,1) string;
        CommandToExecute (1,1) string;
        Style (1,1) string = "";
    end
    
    methods
        function str = CommandHyperlinkableString(linkText, commandToExecute, style)
            str.LinkText = linkText;
            str.CommandToExecute = commandToExecute;
            if nargin > 2
                str.Style = style;
            end
        end
        
        function txt = get.Text(str)
            txt = str.LinkText;
        end
        
        function str = enrich(str)
            import matlab.unittest.internal.diagnostics.CommandHyperlinkedString;
            str = CommandHyperlinkedString(str);
        end
    end
end

% LocalWords:  Formattable
