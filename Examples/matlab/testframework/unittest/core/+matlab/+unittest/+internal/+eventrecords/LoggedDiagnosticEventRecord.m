classdef LoggedDiagnosticEventRecord < matlab.unittest.internal.eventrecords.EventRecord
    % LoggedDiagnosticEventRecord - A record of an event which produced a LoggedDiagnosticEventData instance
    
    % Copyright 2016 The MathWorks, Inc.
    properties(SetAccess=immutable)
        % Stack - Stack at the time the event originated
        %
        %   The Stack property is a structure that represents the call stack for
        %   the event.
        Stack struct;
    end
    
    properties(SetAccess=immutable)
        % Verbosity - Verbosity at which this diagnostic was logged
        %
        %   Verbosity is a scalar instance of matlab.unittest.Verbosity
        %   at which the diagnostic was logged.
        Verbosity matlab.unittest.Verbosity;
        
        % Timestamp - The date and time of the call to the log method
        %
        %   The Timestamp property is a datetime instance that records the
        %   moment when the log method was called.
        Timestamp datetime;
        
        % FormattableDiagnosticResults - Results of logged diagnostics as a FormattableDiagnosticResult vector
        %
        %   The FormattableDiagnosticResults property is a
        %   FormattableDiagnosticResult vector containing the results of the logged
        %   diagnostics.
        FormattableDiagnosticResults matlab.unittest.internal.diagnostics.FormattableDiagnosticResult;
    end
    
    methods
        function txt = getFormattedReport(eventRecord, formatter)
            txt = formatter.getFormattedLoggedReport(eventRecord);
        end
    end
    
    methods(Access=protected)
        function diagRecord = convertToDiagnosticRecord(eventRecord)
            import matlab.unittest.plugins.diagnosticrecord.LoggedDiagnosticRecord;
            diagRecord = LoggedDiagnosticRecord(eventRecord);
        end
    end
    
    methods(Static)
        function eventRecord = fromEventData(eventData,eventScope,eventLocation)
            import matlab.unittest.internal.eventrecords.LoggedDiagnosticEventRecord;
            eventName = eventData.EventName;
            stack = eventData.Stack;
            verbosity = eventData.Verbosity;
            timestamp = eventData.Timestamp;
            formattableDiagnosticResults = eventData.DiagnosticResultsStore.getFormattableResults();
            eventRecord = LoggedDiagnosticEventRecord(eventName,eventScope,eventLocation, ...
                stack,verbosity,timestamp,formattableDiagnosticResults);
        end
        
        function eventRecord = fromDiagnosticRecord(diagRecord)
            import matlab.unittest.internal.eventrecords.LoggedDiagnosticEventRecord;
            eventName = diagRecord.Event;
            eventScope = diagRecord.EventScope;
            eventLocation = diagRecord.EventLocation;
            stack = diagRecord.Stack;
            verbosity = diagRecord.Verbosity;
            timestamp = diagRecord.Timestamp;
            formattableDiagnosticResults = convertToFormattableDiagnosticResults(...
                diagRecord.LoggedDiagnosticResults);
            eventRecord = LoggedDiagnosticEventRecord(eventName,eventScope,eventLocation, ...
                stack,verbosity,timestamp,formattableDiagnosticResults);
        end
    end
    
    methods(Access=private)
        function eventRecord = LoggedDiagnosticEventRecord(eventName,eventScope,eventLocation,...
                stack,verbosity,timestamp,formattableDiagnosticResults)
            eventRecord = eventRecord@matlab.unittest.internal.eventrecords.EventRecord(...
                eventName,eventScope,eventLocation);
            eventRecord.Stack = stack;
            eventRecord.Verbosity = verbosity;
            eventRecord.Timestamp = timestamp;
            eventRecord.FormattableDiagnosticResults = formattableDiagnosticResults;
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