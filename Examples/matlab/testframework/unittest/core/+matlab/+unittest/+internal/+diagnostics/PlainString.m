classdef PlainString < matlab.unittest.internal.diagnostics.LeafFormattableString
    
    % Copyright 2016 The MathWorks, Inc.
    
    properties (SetAccess=private)
        Text string = "";
    end
    
    methods
        function str = PlainString(text)
            if nargin > 0
                str.Text = text;
            end
        end
    end
end

% LocalWords:  Formattable
