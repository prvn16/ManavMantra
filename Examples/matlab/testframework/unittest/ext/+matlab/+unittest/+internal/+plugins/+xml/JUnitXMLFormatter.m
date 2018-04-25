classdef JUnitXMLFormatter < matlab.unittest.internal.eventrecords.EventRecordFormatter & ...
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
        
        function str = getFormattedQualificationReport(~, eventRecord)
            diagnosticsPrinter = createDiagnosticsPrinter();
            eventKey = eventRecord.EventName;
            if strcmp(eventKey,'AssumptionFailed')
                eventKey = 'AssumptionFailureDetails';
            end
            headerTxt = createHeaderText(eventRecord,eventKey);
            diagnosticsPrinter.printQualificationReport(...
                eventRecord.FormattableTestDiagnosticResults.toFormattableStrings(), ...
                eventRecord.FormattableFrameworkDiagnosticResults.toFormattableStrings(), ...
                eventRecord.FormattableAdditionalDiagnosticResults.toFormattableStrings(), ...
                headerTxt, eventRecord.Stack);
            str = diagnosticsPrinter.OutputStream.FormattableLog;
        end
        
        %Currently not needed since JUnitXMLPlugin does not support logged diagnostics
        str = getFormattedLoggedReport(~, eventRecord)
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