classdef EventRecord < handle & matlab.mixin.Heterogeneous
    % EventRecord - A record of an event which produced an EventData instance
    %
    %   EventRecord objects are to be used as safe substitutes for passing
    %   around snapshots of EventData objects and an alternative to
    %   DiagnosticRecord objects. EventRecord objects also add event scope and
    %   event location information which EventData objects do not have.
    %
    %   EventRecord objects are a good alternative to DiagnosticRecord
    %   objects so that DiagnosticRecord objects can be specific to the
    %   DiagnosticsRecordingPlugin and no other plugin.
    
    % Copyright 2016 The MathWorks, Inc.
    properties(Abstract, SetAccess=immutable)
        % Stack - Stack at the time the event originated
        %
        %   The Stack property is a structure that represents the call stack for
        %   the event.
        Stack struct;
    end
    
    properties(SetAccess=immutable)
        % EventName - Name of the event
        %
        %   The EventName property is a character vector that represents the name
        %   of the event.
        EventName char;
        
        % EventScope - Scope where the event originated
        %
        %   The EventScope property is a scalar matlab.unittest.Scope instance that
        %   represents the scope where the event originated.
        EventScope matlab.unittest.Scope;
        
        % EventLocation - Location where the event originated
        %
        %   The EventLocation property is a character vector that represents the
        %   location where the event originated.
        EventLocation char;
    end
    
    methods(Abstract)
        str = getFormattedReport(eventRecord, formatter);
    end
    
    methods(Abstract,Access=protected)
        diagRecord = convertToDiagnosticRecord(eventRecord);
    end
    
    methods(Abstract,Static)
        eventRecord = fromEventData(eventData,eventScope,eventLocation)
        eventRecord = fromDiagnosticRecord(diagRecord)
    end
    
    methods(Sealed)
        function diagRecords = toDiagnosticRecord(eventRecords)
            import matlab.unittest.plugins.diagnosticrecord.DiagnosticRecord;
            diagRecordsCell = arrayfun(@convertToDiagnosticRecord,eventRecords,...
                'UniformOutput',false);
            diagRecords = [DiagnosticRecord.empty(1,0), diagRecordsCell{:}];
        end
    end
    
    methods(Hidden, Access=protected)
        function eventRecord = EventRecord(eventName, eventScope, eventLocation)
            eventRecord.EventName = eventName;
            eventRecord.EventScope = eventScope;
            eventRecord.EventLocation = eventLocation;
        end
    end
end