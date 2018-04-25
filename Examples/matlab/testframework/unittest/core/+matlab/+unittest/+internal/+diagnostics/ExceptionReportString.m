classdef ExceptionReportString < matlab.unittest.internal.diagnostics.LeafFormattableString
    
    % Copyright 2016 The MathWorks, Inc.
    
    properties (Dependent, SetAccess=private)
        Text string;
    end
    
    properties (SetAccess=immutable)
        Exception MException;
    end
    
    properties (SetAccess=private)
        HyperlinkState = 'off';
    end
    
    methods
        function str = ExceptionReportString(exception)
            str.Exception = exception;
        end
        
        function txt = get.Text(str)
            txt = string(str.Exception.getReport('extended','hyperlinks',str.HyperlinkState));
        end
        
        function str = enrich(str)
            str.HyperlinkState = 'on';
        end
    end
end

% LocalWords:  Formattable Wrappable
