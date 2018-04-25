classdef FilterTableRowPart < matlab.unittest.internal.dom.ReportDocumentPart
    %This class is undocumented and may change in a future release.
    
    %  Copyright 2016-2017 The MathWorks, Inc.
    properties(GetAccess=private,SetAccess=immutable)
        IndexOfFiltered
    end
    
    properties(Access=private)
        TestName = [];
        LinkToTestDetails = [];
    end
    
    properties(Constant,Access=private)
        Catalog = matlab.internal.Catalog('MATLAB:unittest:TestReportDocument');
    end
    
    methods
        function docPart = FilterTableRowPart(indexOfFiltered)
            docPart.IndexOfFiltered = indexOfFiltered;
        end
    end
    
    methods(Access=protected)
        function delegateDocPart = createDelegateDocumentPart(~,testReportData)
            delegateDocPart = testReportData.createDelegateDocumentPartFromName('FilterTableRowPart');
        end
        
        function setupPart(docPart,testReportData,~)
            import mlreportgen.dom.InternalLink;
            
            ind = docPart.IndexOfFiltered;
            testName = testReportData.TestSessionData.TestSuite(ind).Name;
            linkGen = testReportData.LinkTargetGenerator;
            linkTarget = linkGen.getDetailsLinkTargetForTestIndex(ind);
            detailsStr = docPart.Catalog.getString('DetailsLinkText');
            
            docPart.TestName = InternalLink(linkTarget.Name,testName);
            docPart.LinkToTestDetails = InternalLink(linkTarget.Name,detailsStr);
        end
        
        function teardownPart(docPart)
            docPart.TestName = [];
            docPart.LinkToTestDetails = [];
        end
    end
    
    methods(Hidden) % Fill template holes ---------------------------------
        function fillTestName(docPart)
            docPart.append(docPart.TestName);
        end
        
        function fillDetailsLink(docPart)
            docPart.append(docPart.LinkToTestDetails);
        end
    end
end