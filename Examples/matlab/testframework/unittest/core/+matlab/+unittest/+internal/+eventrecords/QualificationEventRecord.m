classdef QualificationEventRecord < matlab.unittest.internal.eventrecords.EventRecord
    % QualificationEventRecord - A record of an event which produced a QualificationEventData instance
    
    % Copyright 2016-2017 The MathWorks, Inc.
    properties(SetAccess=immutable)
        % Stack - Stack at the time the event originated
        %
        %   The Stack property is a structure that represents the call stack for
        %   the event.
        Stack struct;
    end
    
    properties(SetAccess=immutable)
        % FormattableTestDiagnosticResults - Results of test diagnostics as FormattableDiagnostcResult vector
        %
        %   The FormattableTestDiagnosticResults property is a
        %   FormattableDiagnostcResult vector containing the results of the test
        %   diagnostics.
        FormattableTestDiagnosticResults matlab.unittest.internal.diagnostics.FormattableDiagnosticResult;
        
        % FormattableFrameworkDiagnosticResults - Results of framework diagnostics as FormattableDiagnostcResult vector
        %
        %   The FormattableFrameworkDiagnosticResults property is a
        %   FormattableDiagnostcResult vector containing the results of the
        %   framework diagnostics.
        FormattableFrameworkDiagnosticResults matlab.unittest.internal.diagnostics.FormattableDiagnosticResult;
        
        % FormattableAdditionalDiagnosticResults - Results of additional diagnostics as FormattableDiagnostcResult vector
        %
        %   The FormattableAdditionalDiagnosticResults property is a
        %   FormattableDiagnostcResult vector containing the results of the
        %   additional diagnostics.
        FormattableAdditionalDiagnosticResults matlab.unittest.internal.diagnostics.FormattableDiagnosticResult;
    end
    
    methods
        function str = getFormattedReport(record, formatter)
            str = formatter.getFormattedQualificationReport(record);
        end
    end
    
    methods(Access=protected)
        function diagRecord = convertToDiagnosticRecord(eventRecord)
            import matlab.unittest.plugins.diagnosticrecord.QualificationDiagnosticRecord;
            diagRecord = QualificationDiagnosticRecord(eventRecord);
        end
    end
    
    methods(Static)
        function eventRecord = fromEventData(eventData,eventScope,eventLocation)
            import matlab.unittest.internal.eventrecords.QualificationEventRecord;
            eventName = eventData.EventName;
            stack = eventData.Stack;
            formattableTestDiagnosticResults = eventData.TestDiagnosticResultsStore.getFormattableResults();
            formattableFrameworkDiagnosticResults = eventData.FrameworkDiagnosticResultsStore.getFormattableResults();
            formattableAdditionalDiagnosticResults = eventData.AdditionalDiagnosticResultsStore.getFormattableResults();
            eventRecord = QualificationEventRecord(eventName,eventScope,eventLocation, ...
                stack, formattableTestDiagnosticResults, formattableFrameworkDiagnosticResults,formattableAdditionalDiagnosticResults);
        end
        
        function eventRecord = fromDiagnosticRecord(diagRecord)
            import matlab.unittest.internal.eventrecords.QualificationEventRecord;
            eventName = diagRecord.Event;
            eventScope = diagRecord.EventScope;
            eventLocation = diagRecord.EventLocation;
            stack = diagRecord.Stack;
            formattableTestDiagnosticResults = convertToFormattableDiagnosticResults(...
                diagRecord.TestDiagnosticResults);
            formattableFrameworkDiagnosticResults = convertToFormattableDiagnosticResults(...
                diagRecord.FrameworkDiagnosticResults);
            formattableAdditionalDiagnosticResults = convertToFormattableDiagnosticResults(...
                diagRecord.AdditionalDiagnosticResults);
            eventRecord = QualificationEventRecord(eventName,eventScope,eventLocation, ...
                stack,formattableTestDiagnosticResults,formattableFrameworkDiagnosticResults,formattableAdditionalDiagnosticResults);
        end
    end
    
    methods(Access=private)
        function eventRecord = QualificationEventRecord(eventName,eventScope,eventLocation, ...
                stack,formattableTestDiagnosticResults,formattableFrameworkDiagnosticResults,formattableAdditionalDiagnosticResults)
            
            eventRecord = eventRecord@matlab.unittest.internal.eventrecords.EventRecord(...
                eventName,eventScope,eventLocation);
            eventRecord.Stack = stack;
            eventRecord.FormattableTestDiagnosticResults = formattableTestDiagnosticResults;
            eventRecord.FormattableFrameworkDiagnosticResults = formattableFrameworkDiagnosticResults;
            eventRecord.FormattableAdditionalDiagnosticResults = formattableAdditionalDiagnosticResults;
        end
    end
end


function formattableResults = convertToFormattableDiagnosticResults(results)
import matlab.unittest.internal.diagnostics.FormattableDiagnosticResult;
import matlab.unittest.internal.diagnostics.PlainString;
formattableResultsCell = arrayfun(@(result) FormattableDiagnosticResult(...
    result.Artifacts, PlainString(result.DiagnosticText)),...
    results, 'UniformOutput', false);
formattableResults = [FormattableDiagnosticResult.empty(1,0),...
    formattableResultsCell{:}];
end