classdef ExceptionDiagnostic < matlab.unittest.diagnostics.Diagnostic
    % This class is undocumented and may change in a future release.
    
    %  Copyright 2016 The MathWorks, Inc.
    properties(SetAccess=immutable)
        Exception MException
        MessageIdentifier char
    end
    
    methods
        function diag = ExceptionDiagnostic(exception,msgID)
            diag.Exception = exception;
            diag.MessageIdentifier = msgID;
        end
        
        function diagnose(diag)
            import matlab.unittest.internal.diagnostics.MessageString;
            diag.DiagnosticText = MessageString(diag.MessageIdentifier, ...
                indent(getFormattableExceptionReport(diag.Exception)));
        end
    end
end

function report = getFormattableExceptionReport(exception)
import matlab.unittest.internal.diagnostics.ExceptionReportString;
import matlab.unittest.internal.diagnostics.WrappableStringDecorator;
import matlab.unittest.internal.TrimmedException;
report = WrappableStringDecorator(ExceptionReportString(TrimmedException(exception)));
end