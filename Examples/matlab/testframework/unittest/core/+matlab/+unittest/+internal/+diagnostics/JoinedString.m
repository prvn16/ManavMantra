classdef JoinedString < matlab.unittest.internal.diagnostics.CompositeFormattableString
    
    % Copyright 2016 The MathWorks, Inc.
    
    properties (Dependent, SetAccess=private)
        Text string;
    end
    
    properties (SetAccess=immutable)
        Delimiter string;
    end
    
    methods
        function joined = JoinedString(str, delim)
            joined = joined@matlab.unittest.internal.diagnostics.CompositeFormattableString(str);
            joined.Delimiter = delim;
        end
        
        function txt = get.Text(str)
            txt = join(str.ComposedText, str.Delimiter);
            if isempty(txt)
                txt = "";
            end
        end
    end
end

% LocalWords:  Formattable delim
