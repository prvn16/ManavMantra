classdef LoggedDiagnosticEventPart < matlab.unittest.internal.dom.ReportDocumentPart
    %This class is undocumented and may change in a future release.
    
    %  Copyright 2016-2017 The MathWorks, Inc.
    properties(GetAccess=private, SetAccess=immutable)
        LoggedDiagnosticEventRecord
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
        function docPart = LoggedDiagnosticEventPart(eventRecord)
            docPart.LoggedDiagnosticEventRecord = eventRecord;
        end
        
        function txt = get.EventSummaryText(docPart)
            record = docPart.LoggedDiagnosticEventRecord;
            if numel(record.FormattableDiagnosticResults)==1
                msgKey = [char(record.EventScope),'DiagnosticLoggedSummary'];
            else
                msgKey = [char(record.EventScope),'DiagnosticsLoggedSummary'];
            end
            txt = docPart.Catalog.getString(msgKey);
        end
    end
    
    methods(Access=protected)
        function delegateDocPart = createDelegateDocumentPart(~,testReportData)
            delegateDocPart = testReportData.createDelegateDocumentPartFromName('LoggedDiagnosticEventPart');
        end
        
        function setupPart(docPart,testReportData)
            import matlab.unittest.internal.plugins.testreport.BlankPart;
            import matlab.unittest.internal.plugins.testreport.DiagnosticResultPart;
            import matlab.unittest.internal.plugins.testreport.StackTextPart;
            eventRecord = docPart.LoggedDiagnosticEventRecord;
            
            docPart.DiagnosticResultParts = ...
                DiagnosticResultPart.fromFormattableDiagnosticResults(...
                    eventRecord.FormattableDiagnosticResults,'Logged');
            if isempty(docPart.DiagnosticResultParts)
                docPart.DiagnosticResultParts = BlankPart;
            end
            docPart.DiagnosticResultParts.setup(testReportData);
            
            if isempty(eventRecord.Stack)
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
        
        function fillTimestampLabel(docPart)
            docPart.append(docPart.Catalog.getString('TimestampLabel'));
        end
        
        function fillTimestampText(docPart)
            docPart.append(char(docPart.LoggedDiagnosticEventRecord.Timestamp));
        end
        
        function fillVerbosityLabel(docPart)
            docPart.append(docPart.Catalog.getString('VerbosityLabel'));
        end
        
        function fillVerbosityText(docPart)
            docPart.append(char(docPart.LoggedDiagnosticEventRecord.Verbosity));
        end
        
        function fillDiagnosticResultParts(docPart)
            docPart.append(docPart.DiagnosticResultParts);
        end
        
        function fillEventLocationLabel(docPart)
            docPart.append(docPart.Catalog.getString('EventLocationLabel'));
        end
        
        function fillEventLocationText(docPart)
            docPart.append(docPart.LoggedDiagnosticEventRecord.EventLocation);
        end
        
        function fillStackTextPart(docPart)
            docPart.append(docPart.StackTextPart);
        end
    end
end

% LocalWords:  dom testreport mlreportgen KLabel unittest
