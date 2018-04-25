classdef EventListPart < matlab.unittest.internal.dom.ReportDocumentPart
    %This class is undocumented and may change in a future release.
    
    %  Copyright 2016-2017 The MathWorks, Inc.
    properties(GetAccess=private,SetAccess=immutable)
        EventRecords
    end
    
    properties(Access=private)
        EventParts = [];
    end
    
    properties(Constant,Access=private)
        Catalog = matlab.internal.Catalog('MATLAB:unittest:TestReportDocument');
    end
    
    methods
        function docPart = EventListPart(eventRecords)
            docPart.EventRecords = eventRecords;
        end
    end
    
    methods(Access=protected)
        function delegateDocPart = createDelegateDocumentPart(~,testReportData)
            delegateDocPart = testReportData.createDelegateDocumentPartFromName('EventListPart');
        end
        
        function setupPart(docPart,testReportData)
            docPart.EventParts = docPart.createEventParts();
            
            if ~isempty(docPart.EventParts)
                docPart.EventParts.setup(testReportData);
            end
        end
        
        function teardownPart(docPart)
            docPart.EventParts = [];
        end
        
        function bool = isApplicablePart(docPart)
            bool = ~isempty(docPart.EventParts);
        end
    end
    
    methods(Hidden) % Fill template holes ---------------------------------
        function fillEventsLabel(docPart)
            if numel(docPart.EventParts) == 1
                labelText = docPart.Catalog.getString('EventLabel');
            else
                labelText = docPart.Catalog.getString('EventsLabel');
            end
            docPart.append(labelText);
        end
        
        function fillEventParts(docPart)
            docPart.append(docPart.EventParts);
        end
    end
    
    methods(Hidden,Access=protected)
        function docParts = createEventParts(docPart)
            docPartsCell = arrayfun(@eventRecordToReportDocumentPart,...
                docPart.EventRecords,'UniformOutput',false);
            docParts = [docPartsCell{:}];
        end
    end
end

function docPart = eventRecordToReportDocumentPart(eventRecord)
import matlab.unittest.internal.eventrecords.QualificationEventRecord;
import matlab.unittest.internal.eventrecords.ExceptionEventRecord;
import matlab.unittest.internal.eventrecords.LoggedDiagnosticEventRecord;
import matlab.unittest.internal.plugins.testreport.QualificationEventPart;
import matlab.unittest.internal.plugins.testreport.ExceptionEventPart;
import matlab.unittest.internal.plugins.testreport.LoggedDiagnosticEventPart;

if isa(eventRecord,'QualificationEventRecord')
    docPart = QualificationEventPart(eventRecord);
elseif isa(eventRecord,'ExceptionEventRecord')
    docPart = ExceptionEventPart(eventRecord);
elseif isa(eventRecord,'LoggedDiagnosticEventRecord')
    docPart = LoggedDiagnosticEventPart(eventRecord);
end
end

% LocalWords:  unittest
