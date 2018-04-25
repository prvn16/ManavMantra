classdef ReplacedString < matlab.unittest.internal.diagnostics.CompositeFormattableString
    
    % Copyright 2016 The MathWorks, Inc.
    
    properties (Dependent, SetAccess=private)
        Text string;
    end
    
    properties (SetAccess=immutable)
        Pattern string;
        Replacement string;
    end
    
    methods
        function replaced = ReplacedString(str, pattern, replacement)
            replaced = replaced@matlab.unittest.internal.diagnostics.CompositeFormattableString(str);
            replaced.Pattern = pattern;
            replaced.Replacement = replacement;
        end
        
        function txt = get.Text(str)
            txt = regexprep(str.ComposedText, str.Pattern, str.Replacement);
        end
    end
end

% LocalWords:  Formattable
