classdef ExceptionEventPart < matlab.unittest.internal.dom.ReportDocumentPart & ...
        matlab.unittest.internal.diagnostics.ErrorReportingMixin
    %This class is undocumented and may change in a future release.
    
    %  Copyright 2016-2017 The MathWorks, Inc.
    properties(GetAccess=private, SetAccess=immutable)
        ExceptionEventRecord
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
        function docPart = ExceptionEventPart(eventRecord)
            docPart.ExceptionEventRecord = eventRecord;
        end
        
        function txt = get.EventSummaryText(docPart)
            record = docPart.ExceptionEventRecord;
            msgKey = [char(record.EventScope),record.EventName,'Summary'];
            txt = docPart.Catalog.getString(msgKey);
        end
    end
    
    methods(Access=protected)
        function delegateDocPart = createDelegateDocumentPart(~,testReportData)
            delegateDocPart = testReportData.createDelegateDocumentPartFromName('ExceptionEventPart');
        end
        
        function setupPart(docPart,testReportData)
            import matlab.unittest.internal.plugins.testreport.BlankPart;
            import matlab.unittest.internal.plugins.testreport.DiagnosticResultPart;
            import matlab.unittest.internal.plugins.testreport.StackTextPart;
            eventRecord = docPart.ExceptionEventRecord;
            
            exceptionResultPart = DiagnosticResultPart.fromLabelAndFormattableString(...
                docPart.Catalog.getString('ErrorReportLabel'),...
                docPart.getExceptionReport(eventRecord.Exception));
            additionalResultParts = DiagnosticResultPart.fromFormattableDiagnosticResults(...
                eventRecord.FormattableAdditionalDiagnosticResults,'Additional');
            docPart.DiagnosticResultParts = [exceptionResultPart,additionalResultParts];
            docPart.DiagnosticResultParts.setup(testReportData);
            
            if isempty(docPart.ExceptionEventRecord.Stack)
                docPart.StackTextPart = BlankPart;
            else
                docPart.StackTextPart = StackTextPart(eventRecord.Stack); %#ok<CPROPLC>
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
        
        function fillErrorIdentifierLabel(docPart)
            docPart.append(docPart.Catalog.getString('ErrorIdentifierLabel'));
        end
        
        function fillErrorIdentifierText(docPart)
            docPart.append(docPart.ExceptionEventRecord.Exception.identifier);
        end
        
        function fillDiagnosticResultParts(docPart)
            docPart.append(docPart.DiagnosticResultParts);
        end
        
        function fillEventLocationLabel(docPart)
            docPart.append(docPart.Catalog.getString('EventLocationLabel'));
        end
        
        function fillEventLocationText(docPart)
            docPart.append(docPart.ExceptionEventRecord.EventLocation);
        end
        
        function fillStackTextPart(docPart)
            docPart.append(docPart.StackTextPart);
        end
    end
end


% LocalWords:  dom testreport mlreportgen unittest
