classdef TestParentDetailsPart < matlab.unittest.internal.dom.ReportDocumentPart
    %This class is undocumented and may change in a future release.
    
    %  Copyright 2016-2017 The MathWorks, Inc.
    properties(GetAccess=private, SetAccess=immutable)
        BaseFolder
        TestParentName
        SubSuiteMask
    end
    
    properties(Access=private)
        ReportDocumentParts = [];
    end
    
    methods
        function docPart = TestParentDetailsPart(baseFolder,testParentName,subSuiteMask)
            docPart.BaseFolder = baseFolder;
            docPart.TestParentName = testParentName;
            docPart.SubSuiteMask = subSuiteMask;
        end
    end
    
    methods(Access=protected)
        function delegateDocPart = createDelegateDocumentPart(~,testReportData)
            delegateDocPart = testReportData.createDelegateDocumentPartFromName('SingleHolePart');
        end
        
        function setupPart(docPart,testReportData)
            import matlab.unittest.internal.plugins.testreport.HeadingPart;
            import matlab.unittest.internal.plugins.testreport.TestDetailsPart;
            
            baseFolder = docPart.BaseFolder;
            testParentName = docPart.TestParentName;
            subSuiteMask = docPart.SubSuiteMask;
            
            linkTarget = testReportData.LinkTargetGenerator.getDetailsLinkTargetForBaseFolderAndTestParentName(...
                baseFolder,testParentName);
            headingPart = HeadingPart(3,testParentName,linkTarget);
            
            testDetailsPartsCell = arrayfun(@TestDetailsPart,find(subSuiteMask),...
                'UniformOutput',false);
            docPart.ReportDocumentParts = [headingPart,testDetailsPartsCell{:}];
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