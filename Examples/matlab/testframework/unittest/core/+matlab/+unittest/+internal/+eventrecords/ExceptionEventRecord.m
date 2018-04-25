classdef ExceptionEventRecord < matlab.unittest.internal.eventrecords.EventRecord
    % ExceptionEventRecord - A record of an event which produced a ExceptionEventData instance
    
    % Copyright 2016-2017 The MathWorks, Inc.
    properties(Dependent, SetAccess=immutable)
        % Stack - Stack at the time the event originated
        %
        %   The Stack property is a structure that represents the call stack for
        %   the event.
        Stack struct;
    end
    
    properties(SetAccess=immutable)
        % Exception - MException instance associated with ExceptionThrown event
        %
        %   The Exception property is the actual MException instance associated
        %   with ExceptionThrown event.
        Exception MException;
        
        % FormattableAdditionalDiagnosticResults - Results of additional diagnostics as FormattableDiagnostcResult vector
        %
        %   The FormattableAdditionalDiagnosticResults property is a
        %   FormattableDiagnostcResult vector containing the results of the
        %   additional diagnostics.
        FormattableAdditionalDiagnosticResults matlab.unittest.internal.diagnostics.FormattableDiagnosticResult;
    end
    
    methods
        function stack = get.Stack(eventRecord)
            import matlab.unittest.internal.trimStack;
            stack = trimStack(eventRecord.Exception.stack);
        end
        
        function str = getFormattedReport(eventRecord, formatter)
            str = formatter.getFormattedExceptionReport(eventRecord);
        end
    end
    
    methods(Access=protected)
        function diagRecord = convertToDiagnosticRecord(eventRecord)
            import matlab.unittest.plugins.diagnosticrecord.ExceptionDiagnosticRecord;
            diagRecord = ExceptionDiagnosticRecord(eventRecord);
        end
    end
    
    methods(Static)
        function eventRecord = fromEventData(eventData,eventScope,eventLocation)
            import matlab.unittest.internal.eventrecords.ExceptionEventRecord;
            eventName = eventData.EventName;
            exception = eventData.Exception;
            formattableAdditionalDiagnosticResults = eventData.AdditionalDiagnosticResultsStore.getFormattableResults();
            eventRecord = ExceptionEventRecord(eventName,eventScope,eventLocation,exception,formattableAdditionalDiagnosticResults);
        end
        
        function eventRecord = fromDiagnosticRecord(diagRecord)
            import matlab.unittest.internal.eventrecords.ExceptionEventRecord;
            eventName = diagRecord.Event;
            eventScope = diagRecord.EventScope;
            eventLocation = diagRecord.EventLocation;
            exception = diagRecord.Exception;
            formattableAdditionalDiagnosticResults = convertToFormattableDiagnosticResults(...
                diagRecord.AdditionalDiagnosticResults);
            eventRecord = ExceptionEventRecord(eventName,eventScope,eventLocation,exception,formattableAdditionalDiagnosticResults);
        end
    end
    
    methods(Access=private)
        function eventRecord = ExceptionEventRecord(eventName,eventScope,eventLocation,exception,formattableAdditionalDiagnosticResults)
            eventRecord = eventRecord@matlab.unittest.internal.eventrecords.EventRecord(...
                eventName,eventScope,eventLocation);
            eventRecord.Exception = exception;
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