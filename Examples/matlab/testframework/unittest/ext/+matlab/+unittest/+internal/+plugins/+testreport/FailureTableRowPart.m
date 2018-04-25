classdef FailureTableRowPart < matlab.unittest.internal.dom.ReportDocumentPart
    %This class is undocumented and may change in a future release.
    
    %  Copyright 2016-2017 The MathWorks, Inc.
    properties(GetAccess=private,SetAccess=immutable)
        IndexOfFailure
    end
    
    properties(Access=private)
        TestName = [];
        TestResult = [];
        LinkToTestDetails = [];
    end
    
    properties(Constant,Access=private)
        Catalog = matlab.internal.Catalog('MATLAB:unittest:TestReportDocument');
    end
    
    methods
        function docPart = FailureTableRowPart(indexOfFailure)
            docPart.IndexOfFailure = indexOfFailure;
        end
    end
    
    methods(Access=protected)
        function delegateDocPart = createDelegateDocumentPart(~,testReportData)
            delegateDocPart = testReportData.createDelegateDocumentPartFromName('FailureTableRowPart');
        end
        
        function setupPart(docPart,testReportData,~)
            import mlreportgen.dom.InternalLink;
            
            ind = docPart.IndexOfFailure;
            testName = testReportData.TestSessionData.TestSuite(ind).Name;
            linkGen = testReportData.LinkTargetGenerator;
            linkTarget = linkGen.getDetailsLinkTargetForTestIndex(ind);
            detailsStr = docPart.Catalog.getString('DetailsLinkText');
            
            docPart.TestName = InternalLink(linkTarget.Name,testName);
            docPart.TestResult = testReportData.TestSessionData.TestResults(ind);
            docPart.LinkToTestDetails = InternalLink(linkTarget.Name,detailsStr);
        end
        
        function teardownPart(docPart)
            docPart.TestName = [];
            docPart.TestResult = [];
            docPart.LinkToTestDetails = [];
        end
    end
    
    methods(Hidden) % Fill template holes ---------------------------------
        function fillTestName(docPart)
            docPart.append(docPart.TestName);
        end
        
        function fillReasons(docPart)
            result = docPart.TestResult;
            
            reasonsCell = cell(1,0);
            if result.VerificationFailed
                reasonsCell{end+1} = docPart.Catalog.getString('FailedByVerification');
            end
            if result.AssertionFailed
                reasonsCell{end+1} = docPart.Catalog.getString('FailedByAssertion');
            end
            if result.Errored
                reasonsCell{end+1} = docPart.Catalog.getString('FailedByError');
            end
            if result.FatalAssertionFailed
                reasonsCell{end+1} = docPart.Catalog.getString('FailedByFatalAssertion');
            end
            
            docPart.appendUnmodifiedText(strjoin(reasonsCell,newline()));
        end
        
        function fillDetailsLink(docPart)
            docPart.append(docPart.LinkToTestDetails);
        end
    end
end

% LocalWords:  unittest
