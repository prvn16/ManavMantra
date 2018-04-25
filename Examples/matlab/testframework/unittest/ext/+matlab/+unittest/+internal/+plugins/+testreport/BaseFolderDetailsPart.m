classdef BaseFolderDetailsPart < matlab.unittest.internal.dom.ReportDocumentPart
    %This class is undocumented and may change in a future release.
    
    %  Copyright 2016-2017 The MathWorks, Inc.
    properties(GetAccess=private, SetAccess=immutable)
        BaseFolder
        SubSuiteMask
    end
    
    properties(Access=private)
        ReportDocumentParts = [];
    end
    
    methods
        function docPart = BaseFolderDetailsPart(baseFolder,subSuiteMask)
            docPart.BaseFolder = baseFolder;
            docPart.SubSuiteMask = subSuiteMask;
        end
    end
    
    methods(Access=protected)
        function delegateDocPart = createDelegateDocumentPart(~,testReportData)
            delegateDocPart = testReportData.createDelegateDocumentPartFromName('SingleHolePart');
        end
        
        function setupPart(docPart,testReportData)
            import matlab.unittest.internal.plugins.testreport.HeadingPart;
            import matlab.unittest.internal.plugins.testreport.TestParentDetailsPart;
            baseFolder = docPart.BaseFolder;
            subSuiteMask = docPart.SubSuiteMask;
            
            linkTarget = testReportData.LinkTargetGenerator.getDetailsLinkTargetForBaseFolder(baseFolder);
            headingPart = HeadingPart(2,[baseFolder filesep],linkTarget);
            
            [testParentNames,~,ic] = unique({testReportData.TestSessionData.TestSuite(subSuiteMask).TestParentName},'stable');
            testParentDetailsPartsCell = cell(1,numel(testParentNames));
            for k=1:numel(testParentNames)
                newSubSuiteMask = subSuiteMask;
                newSubSuiteMask(subSuiteMask) = ic == k;
                testParentDetailsPartsCell{k} = TestParentDetailsPart(...
                    baseFolder,testParentNames{k},newSubSuiteMask);
            end
            
            docPart.ReportDocumentParts = [headingPart,testParentDetailsPartsCell{:}];
            docPart.ReportDocumentParts.setup(testReportData);
        end
        
        function teardownPart(docPart)
            docPart.ReportDocumentParts = [];
        end
    end
    
    methods(Hidden) % Fill template holes ---------------------------------
        function fillContent(docPart)
            docPart.appendIfApplicable(docPart.ReportDocumentParts);
        end
    end
end