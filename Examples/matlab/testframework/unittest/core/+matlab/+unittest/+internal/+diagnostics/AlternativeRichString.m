classdef AlternativeRichString < matlab.unittest.internal.diagnostics.LeafFormattableString
    
    % Copyright 2016 The MathWorks, Inc.
    
    properties (SetAccess=private)
        Text string;
    end
    
    properties (Access=private)
        RichText string;
    end
    
    methods
        function str = AlternativeRichString(plainString, richString)
            str.Text = plainString;
            str.RichText = richString;
        end
        
        function str = enrich(str)
            str.Text = str.RichText;
        end
    end
end

% LocalWords:  Formattable
