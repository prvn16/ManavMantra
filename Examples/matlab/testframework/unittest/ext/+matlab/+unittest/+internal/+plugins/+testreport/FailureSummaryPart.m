classdef FailureSummaryPart < matlab.unittest.internal.dom.ReportDocumentPart
    %This class is undocumented and may change in a future release.
    
    %  Copyright 2016-2017 The MathWorks, Inc.
    properties(Access=private)
        FailedCount = [];
        HeadingPart = [];
        FailureTableRowParts = [];
        FatalAssertionEventLocation = [];
        UnreachedCount = [];
    end
    
    properties(Constant,Access=private)
        Catalog = matlab.internal.Catalog('MATLAB:unittest:TestReportDocument');
    end
    
    methods(Access=protected)
        function delegateDocPart = createDelegateDocumentPart(~,testReportData)
            delegateDocPart = testReportData.createDelegateDocumentPartFromName('FailureSummaryPart');
        end
        
        function setupPart(docPart,testReportData)
            import matlab.unittest.internal.plugins.testreport.HeadingPart;
            import matlab.unittest.internal.plugins.testreport.FailureTableRowPart;
            
            failedMask = testReportData.TestSessionData.FailedMask;
            docPart.FailedCount = nnz(failedMask);
            
            if ~docPart.isApplicablePart()
                return;
            end
            
            fatalAssertionMask = [testReportData.TestSessionData.TestResults.FatalAssertionFailed];
            if any(fatalAssertionMask)
                record = testReportData.TestSessionData.EventRecordsList{find(fatalAssertionMask,1)};
                docPart.FatalAssertionEventLocation = record.EventLocation;
                docPart.UnreachedCount = nnz(testReportData.TestSessionData.UnreachedMask);
            end
            
            docPart.HeadingPart = HeadingPart(1,docPart.Catalog.getString('FailureSummaryHeading')); %#ok<CPROPLC>
            docPart.HeadingPart.setup(testReportData);
            
            cellOfParts = arrayfun(@(ind) FailureTableRowPart(ind),find(failedMask),...
                'UniformOutput',false);
            docPart.FailureTableRowParts = [cellOfParts{:}];
            docPart.FailureTableRowParts.setup(testReportData);
        end
        
        function teardownPart(docPart)
            docPart.FailedCount = [];
            docPart.HeadingPart = [];
            docPart.FailureTableRowParts = [];
            docPart.FatalAssertionEventLocation = [];
            docPart.UnreachedCount = [];
        end
        
        function bool = isApplicablePart(docPart)
            bool = docPart.FailedCount > 0;
        end
    end
    
    methods(Hidden) % Fill template holes ---------------------------------
        function fillHeadingPart(docPart)
            docPart.append(docPart.HeadingPart);
        end
        
        function fillFailureSummaryText(docPart)
            if docPart.FailedCount == 1
                failureSummaryText = docPart.Catalog.getString(...
                    'SingleFailureSummaryText');
            else
                failureSummaryText = docPart.Catalog.getString(...
                    'FailureSummaryText',docPart.FailedCount);
            end
            
            if ~isempty(docPart.FatalAssertionEventLocation)
                if docPart.UnreachedCount == 1
                    msgText = docPart.Catalog.getString('FatalAssertionCausedAbortSingleUnreached',...
                        docPart.FatalAssertionEventLocation);
                else
                    msgText = docPart.Catalog.getString('FatalAssertionCausedAbort',...
                        docPart.FatalAssertionEventLocation,docPart.UnreachedCount);
                end
                
                failureSummaryText = sprintf('%s\n%s',failureSummaryText,msgText);
            end
            
            docPart.appendUnmodifiedText(failureSummaryText);
        end
        
        function fillTestNameColumnLabel(docPart)
            docPart.append(docPart.Catalog.getString('FailingTestNameColumnLabel'));
        end
        
        function fillReasonsColumnLabel(docPart)
            docPart.append(docPart.Catalog.getString('FailureReasonsColumnLabel'));
        end
        
        function fillFailureTableRowParts(docPart)
            docPart.append(docPart.FailureTableRowParts);
        end
    end
end

% LocalWords:  unittest
