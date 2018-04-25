classdef SuiteOverviewPart < matlab.unittest.internal.dom.ReportDocumentPart
    %This class is undocumented and may change in a future release.
    
    %  Copyright 2016-2017 The MathWorks, Inc.
    properties(Access=private)
        ReportDocumentParts = [];
        IsApplicable = true;
    end
    
    properties(Constant,Access=private)
        Catalog = matlab.internal.Catalog('MATLAB:unittest:TestReportDocument');
    end
    
    methods(Access=protected)
        function delegateDocPart = createDelegateDocumentPart(~,testReportData)
            delegateDocPart = testReportData.createDelegateDocumentPartFromName('SingleHolePart');
        end
        
        function setupPart(docPart,testReportData)
            import matlab.unittest.internal.plugins.testreport.HeadingPart;
            import matlab.unittest.internal.plugins.testreport.BaseFolderOverviewPart;
            
            if isempty(testReportData.TestSessionData.TestSuite)
                docPart.IsApplicable = false;
                return;
            end
            
            headingPart = HeadingPart(1,docPart.Catalog.getString('SuiteOverviewHeading'));
            
            [baseFolders,~,ic] = unique(testReportData.TestSessionData.BaseFolders,'stable');
            baseFolderOverviewPartsCell = arrayfun(@(k) BaseFolderOverviewPart(...
                baseFolders{k},ic==k),...
                1:numel(baseFolders),'UniformOutput',false);
            
            docPart.ReportDocumentParts = [headingPart,...
                baseFolderOverviewPartsCell{:}];
            docPart.ReportDocumentParts.setup(testReportData);
        end
        
        function teardownPart(docPart)
            docPart.ReportDocumentParts = [];
            docPart.IsApplicable = true;
        end
        
        function bool = isApplicablePart(docPart)
            bool = docPart.IsApplicable;
        end
    end
    
    methods(Hidden) % Fill template holes ---------------------------------
        function fillContent(docPart)
            docPart.appendIfApplicable(docPart.ReportDocumentParts);
        end
    end
end

% LocalWords:  unittest
