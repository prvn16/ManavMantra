classdef FormattedString < matlab.unittest.internal.diagnostics.CompositeFormattableString
    
    % Copyright 2016 The MathWorks, Inc.
    
    properties (Dependent, SetAccess=private)
        Text string;
    end
    
    properties (SetAccess=immutable)
        Format string;
    end
    
    methods
        function formatted = FormattedString(format, varargin)
            
            % Replace chars with strings so that they don't get lost in the
            % horzcat operation.
            charMask = cellfun(@ischar, varargin);
            varargin(charMask) = num2cell(string(varargin(charMask)));
            
            formatted = formatted@matlab.unittest.internal.diagnostics.CompositeFormattableString([varargin{:}]);
            formatted.Format = format;
        end
        
        function txt = get.Text(str)
            txt = sprintf(str.Format, str.ComposedText);
        end
    end
end

% LocalWords:  Formattable strs
