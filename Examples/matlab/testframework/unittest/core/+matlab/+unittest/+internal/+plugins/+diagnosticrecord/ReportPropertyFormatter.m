classdef ReportPropertyFormatter < matlab.unittest.internal.eventrecords.EventRecordFormatter & ...
        matlab.unittest.internal.diagnostics.ErrorReportingMixin
    % This class is undocumented and may change in a future release.
    
    % Copyright 2016-2017 The MathWorks, Inc.
    methods
        function str = getFormattedExceptionReport(formatter, eventRecord)
            msgID = ['MATLAB:unittest:Diagnostic:' ...
                char(eventRecord.EventScope) 'UncaughtException'];
            headerTxt = getString(message(msgID,eventRecord.EventLocation));
            exceptionReport = formatter.getExceptionReport(eventRecord.Exception);
            
            diagnosticsPrinter = createDiagnosticsPrinter();
            diagnosticsPrinter.printUncaughtException(headerTxt, eventRecord.Exception.identifier, exceptionReport,...
                 eventRecord.FormattableAdditionalDiagnosticResults.toFormattableStrings());
            str = diagnosticsPrinter.OutputStream.FormattableLog;
            str = regexprep(str,'\n+$','');
        end
        
        function str = getFormattedLoggedReport(~, eventRecord)
            loggedDescription = getString(message('MATLAB:unittest:LoggingPlugin:DefaultDescription'));
            hideTimestamp = false;
            hideLevel = false;
            numStackFrames = 0;
            
            diagnosticsPrinter = createDiagnosticsPrinter();
            diagnosticsPrinter.printLoggedDiagnostics(...
                eventRecord.FormattableDiagnosticResults.toFormattableStrings(), ...
                eventRecord.Verbosity, loggedDescription, hideTimestamp, ...
                eventRecord.Timestamp, hideLevel, numStackFrames, eventRecord.Stack);
            str = diagnosticsPrinter.OutputStream.FormattableLog;
            str = regexprep(str,'\n+$','');
        end
        
        function str = getFormattedQualificationReport(~, eventRecord)
            if strcmp(eventRecord.EventName,'AssumptionFailed')
                msgKey = [char(eventRecord.EventScope) 'AssumptionFailureDetails'];
            else
                msgKey = [char(eventRecord.EventScope) eventRecord.EventName];
            end
            headerTxt = getString(message(['MATLAB:unittest:Diagnostic:' msgKey],eventRecord.EventLocation));
            
            diagnosticsPrinter = createDiagnosticsPrinter();
            diagnosticsPrinter.printQualificationReport(...
                eventRecord.FormattableTestDiagnosticResults.toFormattableStrings(), ...
                eventRecord.FormattableFrameworkDiagnosticResults.toFormattableStrings(), ...
                eventRecord.FormattableAdditionalDiagnosticResults.toFormattableStrings(), ...
                headerTxt, eventRecord.Stack);
            str = diagnosticsPrinter.OutputStream.FormattableLog;
            str = regexprep(str,'\n+$','');
        end
    end
end

function diagnosticsPrinter = createDiagnosticsPrinter()
import matlab.unittest.internal.plugins.LoggingStream;
import matlab.unittest.internal.plugins.DiagnosticsPrinter;
diagnosticsPrinter = DiagnosticsPrinter(LoggingStream);
end

% LocalWords:  formatter Formattable