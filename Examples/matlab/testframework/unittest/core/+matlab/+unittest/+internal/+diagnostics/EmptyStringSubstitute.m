classdef EmptyStringSubstitute < matlab.unittest.internal.diagnostics.CompositeFormattableString
    
    % Copyright 2016-2017 The MathWorks, Inc.
    
    properties (Dependent, SetAccess=private)
        Text string;
    end
    
    properties (SetAccess=immutable)
        Class string;
        Size string;
    end
    
    methods
        function str = EmptyStringSubstitute(otherString, valueClass, valueSize)
            str = str@matlab.unittest.internal.diagnostics.CompositeFormattableString(otherString);
            str.Class = valueClass;
            str.Size = valueSize;
        end
        
        function txt = get.Text(str)
            txt = str.ComposedText;
            
            if strlength(txt) == 0
                txt = string(getString(message('MATLAB:unittest:ConstraintDiagnostic:NoDisplayedOutput', ...
                    str.Class, str.Size)));
            end
        end
    end
end

% LocalWords:  Formattable strlength
