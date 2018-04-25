classdef TAPVersion12Formatter < matlab.unittest.internal.eventrecords.EventRecordFormatter & ...
        matlab.unittest.internal.diagnostics.ErrorReportingMixin
    % This class is undocumented and may change in a future release.
    
    % Copyright 2016-2017 The MathWorks, Inc.
    
    methods
        function str = getFormattedExceptionReport(formatter, eventRecord)
            headerTxt = createHeaderText(eventRecord,'UncaughtException');
            exceptionReport = formatter.getExceptionReport(eventRecord.Exception);
            
            diagnosticsPrinter = createDiagnosticsPrinter();
            diagnosticsPrinter.printUncaughtException(headerTxt, eventRecord.Exception.identifier, exceptionReport,...
                eventRecord.FormattableAdditionalDiagnosticResults.toFormattableStrings());
            str = diagnosticsPrinter.OutputStream.FormattableLog;
        end
        
        function str = getFormattedLoggedReport(~, eventRecord)
            loggedDescription = getString(message('MATLAB:unittest:LoggingPlugin:DefaultDescription'));
            hideTimestamp = false;
            hideLevel = false;
            numStackFrames = 0;
            
            diagnosticsPrinter = createDiagnosticsPrinter();
            delimiter = '================================================================================';
            diagnosticsPrinter.printLine(delimiter);
            diagnosticsPrinter.printLoggedDiagnostics(...
                eventRecord.FormattableDiagnosticResults.toFormattableStrings(), ...
                eventRecord.Verbosity, loggedDescription, hideTimestamp, ...
                eventRecord.Timestamp, hideLevel, numStackFrames, eventRecord.Stack);
            diagnosticsPrinter.printLine(delimiter);
            str = diagnosticsPrinter.OutputStream.FormattableLog;
        end
        
        function str = getFormattedQualificationReport(~, eventRecord)
            diagnosticsPrinter = createDiagnosticsPrinter();
            if strcmp(eventRecord.EventName, 'AssumptionFailed')
                summaryHdr =  createHeaderText(eventRecord,'AssumptionFailureSummary');
                detailsHdr = createHeaderText(eventRecord,'AssumptionFailureDetails');
                diagnosticsPrinter.printAssumptionFailure(...
                    eventRecord.FormattableTestDiagnosticResults.toFormattableStrings(), ...
                    eventRecord.FormattableFrameworkDiagnosticResults.toFormattableStrings(), ...
                    eventRecord.FormattableAdditionalDiagnosticResults.toFormattableStrings(), ...
                    summaryHdr, detailsHdr, eventRecord.Stack);
            else
                headerTxt = createHeaderText(eventRecord,eventRecord.EventName);
                diagnosticsPrinter.printQualificationReport(...
                    eventRecord.FormattableTestDiagnosticResults.toFormattableStrings(), ...
                    eventRecord.FormattableFrameworkDiagnosticResults.toFormattableStrings(), ...
                    eventRecord.FormattableAdditionalDiagnosticResults.toFormattableStrings(), ...
                    headerTxt, eventRecord.Stack);
            end
            str = diagnosticsPrinter.OutputStream.FormattableLog;
        end
    end
end

function diagnosticsPrinter = createDiagnosticsPrinter()
import matlab.unittest.internal.plugins.LoggingStream;
import matlab.unittest.internal.plugins.DiagnosticsPrinter;
diagnosticsPrinter = DiagnosticsPrinter(LoggingStream);
end

function txt = createHeaderText(eventRecord,eventKey)
txt = getString(message(['MATLAB:unittest:Diagnostic:' ...
    char(eventRecord.EventScope) eventKey],eventRecord.EventLocation));
end

% LocalWords:  formatter Hdr Formattable