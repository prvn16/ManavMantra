classdef QualificationEventPart < matlab.unittest.internal.dom.ReportDocumentPart
    %This class is undocumented and may change in a future release.
    
    %  Copyright 2016-2017 The MathWorks, Inc.
    properties(GetAccess=private, SetAccess=immutable)
        QualificationEventRecord
    end
    
    properties(Hidden,Dependent,GetAccess=protected,SetAccess=private)
        EventSummaryText
    end
    
    properties(Access=private)
        DiagnosticResultParts = [];
        StackTextPart = [];
    end
    
    properties(Constant,Access=private)
        Catalog = matlab.internal.Catalog('MATLAB:unittest:TestReportDocument');
    end
    
    methods
        function docPart = QualificationEventPart(eventRecord)
            docPart.QualificationEventRecord = eventRecord;
        end
        
        function txt = get.EventSummaryText(docPart)
            record = docPart.QualificationEventRecord;
            msgKey = [char(record.EventScope),record.EventName,'Summary'];
            txt = docPart.Catalog.getString(msgKey);
        end
    end
    
    methods(Access=protected)
        function delegateDocPart = createDelegateDocumentPart(~,testReportData)
            delegateDocPart = testReportData.createDelegateDocumentPartFromName('QualificationEventPart');
        end
        
        function setupPart(docPart,testReportData)
            import matlab.unittest.internal.plugins.testreport.BlankPart;
            import matlab.unittest.internal.plugins.testreport.DiagnosticResultPart;
            import matlab.unittest.internal.plugins.testreport.StackTextPart;
            eventRecord = docPart.QualificationEventRecord;
            
            docPart.DiagnosticResultParts = [...
                DiagnosticResultPart.fromFormattableDiagnosticResults(...
                    eventRecord.FormattableTestDiagnosticResults,'Test'),...
                DiagnosticResultPart.fromFormattableDiagnosticResults(...
                    eventRecord.FormattableFrameworkDiagnosticResults,'Framework'),...
                DiagnosticResultPart.fromFormattableDiagnosticResults(...
                    eventRecord.FormattableAdditionalDiagnosticResults,'Additional')];
            if isempty(docPart.DiagnosticResultParts)
                docPart.DiagnosticResultParts = BlankPart;
            end
            docPart.DiagnosticResultParts.setup(testReportData);
            
            if isempty(eventRecord.Stack)
                docPart.StackTextPart = BlankPart;
            else
                docPart.StackTextPart = StackTextPart(docPart.QualificationEventRecord.Stack); %#ok<CPROPLC>
            end
            docPart.StackTextPart.setup(testReportData);
        end
        
        function teardownPart(docPart)
            docPart.DiagnosticResultParts = [];
            docPart.StackTextPart = [];
        end
    end
    
    methods(Hidden) % Fill template holes ---------------------------------
        function fillEventSummaryText(docPart)
            docPart.append(docPart.EventSummaryText);
        end
        
        function fillDiagnosticResultParts(docPart)
            docPart.append(docPart.DiagnosticResultParts);
        end
        
        function fillEventLocationLabel(docPart)
            docPart.append(docPart.Catalog.getString('EventLocationLabel'));
        end
        
        function fillEventLocationText(docPart)
            docPart.append(docPart.QualificationEventRecord.EventLocation);
        end
        
        function fillStackTextPart(docPart)
            docPart.append(docPart.StackTextPart);
        end
    end
end

% LocalWords:  dom qual mlreportgen testreport KLabel unittest
