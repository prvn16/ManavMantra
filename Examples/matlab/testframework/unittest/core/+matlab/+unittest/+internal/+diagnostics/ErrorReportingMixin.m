classdef(Abstract,Hidden,HandleCompatible) ErrorReportingMixin
    % This class is undocumented and may change in a future release.
    
    %  Copyright 2014-2017 The MathWorks, Inc.
    
    methods(Hidden, Access=protected)
        function trimmed = createTrimmedException(~, exception)
            trimmed = matlab.unittest.internal.TrimmedException(exception);
        end
    end
    
    methods(Hidden, Sealed, Access=protected)
        function report = getExceptionReport(mixin, exception)
            import matlab.unittest.internal.diagnostics.ExceptionReportString;
            import matlab.unittest.internal.diagnostics.WrappableStringDecorator;
            
            report = WrappableStringDecorator(ExceptionReportString(mixin.createTrimmedException(exception)));
        end
    end
end

% LocalWords:  Wrappable
