classdef BaseFolderOverviewPart < matlab.unittest.internal.dom.ReportDocumentPart
    %This class is undocumented and may change in a future release.
    
    %  Copyright 2016-2017 The MathWorks, Inc.
    properties(GetAccess=private, SetAccess=immutable)
        BaseFolder
        SubSuiteMask
    end
    
    properties(Access=private)
        LinkToBaseFolderDetails = [];
        TestParentOverviewParts = [];
    end
    
    methods
        function docPart = BaseFolderOverviewPart(baseFolder,subSuiteMask)
            docPart.BaseFolder = baseFolder;
            docPart.SubSuiteMask = subSuiteMask;
        end
    end
    
    methods(Access=protected)
        function delegateDocPart = createDelegateDocumentPart(~,testReportData)
            delegateDocPart = testReportData.createDelegateDocumentPartFromName('BaseFolderOverviewPart');
        end
        
        function setupPart(docPart,testReportData)
            import mlreportgen.dom.InternalLink;
            import matlab.unittest.internal.plugins.testreport.TestParentOverviewPart;
            baseFolder = docPart.BaseFolder;
            subSuiteMask = docPart.SubSuiteMask;
            
            linkTarget = testReportData.LinkTargetGenerator.getDetailsLinkTargetForBaseFolder(baseFolder);
            docPart.LinkToBaseFolderDetails = InternalLink(linkTarget.Name,[baseFolder filesep]);
            
            [testParentNames,~,ic] = unique({testReportData.TestSessionData.TestSuite(subSuiteMask).TestParentName},'stable');
            testParentOverviewPartsCell = cell(1,numel(testParentNames));
            for k=1:numel(testParentNames)
                newSubSuiteMask = subSuiteMask;
                newSubSuiteMask(subSuiteMask) = ic == k;
                testParentOverviewPartsCell{k} = TestParentOverviewPart(...
                    baseFolder,testParentNames{k},newSubSuiteMask);
            end
            docPart.TestParentOverviewParts = [testParentOverviewPartsCell{:}];
            docPart.TestParentOverviewParts.setup(testReportData);
        end
        
        function teardownPart(docPart)
            docPart.LinkToBaseFolderDetails = [];
            docPart.TestParentOverviewParts = [];
        end
    end
    
    methods(Hidden) % Fill template holes ---------------------------------
        function fillBaseFolder(docPart)
            docPart.append(docPart.LinkToBaseFolderDetails);
        end
        
        function fillTestParentOverviewParts(docPart)
            arrayfun(@docPart.append,docPart.TestParentOverviewParts);
        end
    end
end