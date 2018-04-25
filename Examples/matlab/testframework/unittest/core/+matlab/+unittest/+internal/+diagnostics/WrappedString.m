classdef WrappedString < matlab.unittest.internal.diagnostics.CompositeFormattableString
    
    % Copyright 2016 The MathWorks, Inc.
    
    properties (Dependent, SetAccess=private)
        Text string;
    end
    
    properties (SetAccess=immutable)
        WrappedWidth double;
    end
    
    properties (Dependent, SetAccess=private)
        IndentionAmount double;
    end
    
    methods
        function str = WrappedString(wrappableString, wrappedWidth)
            str = str@matlab.unittest.internal.diagnostics.CompositeFormattableString(wrappableString);
            str.WrappedWidth = wrappedWidth;
        end
        
        function txt = get.Text(str)
            import matlab.internal.display.printWrapped;
            
            availableWidth = str.WrappedWidth - str.IndentionAmount;
            txt = string(printWrapped(str.ComposedText, availableWidth));
            txt = txt.extractBefore(strlength(txt)); % remove extra newline added by printWrapped
        end
        
        function amount = get.IndentionAmount(str)
            amount = getComposedStringIndentionAmount(str);
        end
    end
end

function amount = getComposedStringIndentionAmount(str)
amount = str.ComposedString.IndentionAmount;
end

% LocalWords:  Formattable wrappable strlength
