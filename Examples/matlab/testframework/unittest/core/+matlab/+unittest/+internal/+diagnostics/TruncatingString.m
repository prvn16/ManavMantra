classdef TruncatingString < matlab.unittest.internal.diagnostics.CompositeFormattableString
    
    % Copyright 2016 The MathWorks, Inc.
    
    properties (Dependent, SetAccess=private)
        Text string;
    end
    
    properties (Constant, Access=private)
        % 4500 characters allows enough room to fully display a 10x10 cell array
        % with numeric elements with real and complex parts using up all 15 decimal
        % digits when displayed in long format.
        MaxPrintedCharacters = 4500;
    end
    
    methods
        function str = TruncatingString(otherString)
            str = str@matlab.unittest.internal.diagnostics.CompositeFormattableString(otherString);
        end
        
        function txt = get.Text(str)
            txt = str.ComposedText;
            
            if strlength(txt) > str.MaxPrintedCharacters
                txt = txt.extractBefore(str.MaxPrintedCharacters + 1) + ...
                    newline + newline + ...
                    getString(message('MATLAB:unittest:ConstraintDiagnostic:TruncatedString'));
            end
        end
    end
end

% LocalWords:  Formattable Truncatable strlength
