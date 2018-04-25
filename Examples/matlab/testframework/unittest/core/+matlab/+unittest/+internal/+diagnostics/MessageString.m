classdef MessageString < matlab.unittest.internal.diagnostics.CompositeFormattableString
    
    % Copyright 2016 The MathWorks, Inc.
    
    properties (Dependent, SetAccess=private)
        Text string;
    end
    
    properties (SetAccess=immutable)
        ID string;
    end
    
    methods
        function str = MessageString(id, plug)
            str = str@matlab.unittest.internal.diagnostics.CompositeFormattableString(plug);
            str.ID = id;
        end
        
        function text = get.Text(str)
            text = string(getString(message(char(str.ID), char(str.ComposedText))));
        end
    end
end

% LocalWords:  Formattable
