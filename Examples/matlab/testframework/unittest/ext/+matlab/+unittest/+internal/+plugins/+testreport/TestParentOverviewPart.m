classdef TestParentOverviewPart < matlab.unittest.internal.dom.ReportDocumentPart
    %This class is undocumented and may change in a future release.
    
    %  Copyright 2016-2017 The MathWorks, Inc.
    properties(SetAccess=immutable)
        BaseFolder
        TestParentName
        SubSuiteMask
    end
    
    properties(Access=private)
        OverviewLinkTarget = [];
        LinkToTestParentDetails = [];
        TotalDuration = [];
        ImageObjects = [];
    end
    
    properties(Constant,Access=private)
        Catalog = matlab.internal.Catalog('MATLAB:unittest:TestReportDocument');
    end
    
    methods
        function docPart = TestParentOverviewPart(baseFolder,testParentName,subSuiteMask)
            docPart.BaseFolder = baseFolder;
            docPart.TestParentName = testParentName;
            docPart.SubSuiteMask = subSuiteMask;
        end
    end
    
    methods(Access=protected)
        function delegateDocPart = createDelegateDocumentPart(~,testReportData)
            delegateDocPart = testReportData.createDelegateDocumentPartFromName('TestParentOverviewPart');
        end
        
        function setupPart(docPart,testReportData,~)
            import mlreportgen.dom.InternalLink;
            import mlreportgen.dom.Image;
            
            baseFolder = docPart.BaseFolder;
            linkTargetGenerator = testReportData.LinkTargetGenerator;
            subSuiteMask = docPart.SubSuiteMask;
            subResults = testReportData.TestSessionData.TestResults(subSuiteMask);
            subSuite = testReportData.TestSessionData.TestSuite(subSuiteMask);
            subSuiteInds = find(subSuiteMask);
            
            docPart.OverviewLinkTarget = linkTargetGenerator.getOverviewLinkTargetForBaseFolderAndTestParentName(...
                baseFolder,docPart.TestParentName);
            
            detailsLinkTarget = linkTargetGenerator.getDetailsLinkTargetForBaseFolderAndTestParentName(...
                baseFolder,docPart.TestParentName);
            docPart.LinkToTestParentDetails = InternalLink(detailsLinkTarget.Name,docPart.TestParentName);
            
            docPart.TotalDuration = sum([subResults.Duration]);
            
            docPart.ImageObjects = Image.empty(1,0);
            for k=1:numel(subSuite)
                iconFile = testReportData.resultToIconFile(subResults(k));
                linkTargetForTest = linkTargetGenerator.getDetailsLinkTargetForTestIndex(...
                    subSuiteInds(k));
                linkForTest = InternalLink(linkTargetForTest.Name,'');
                imgObj = Image(iconFile);
                imgObj.Width = '0.11in';
                imgObj.Height = '0.11in';
                linkForTest.append(imgObj);
                docPart.ImageObjects(end+1) = linkForTest;
            end
        end
        
        function teardownPart(docPart)
            docPart.OverviewLinkTarget = [];
            docPart.LinkToTestParentDetails = [];
            docPart.TotalDuration = [];
            docPart.ImageObjects = [];
        end
    end
    
    methods(Hidden) % Fill template holes ---------------------------------
        function fillTestParentName(docPart)
            docPart.append(docPart.OverviewLinkTarget);
            docPart.append(docPart.LinkToTestParentDetails);
        end
        
        function fillTotalDurationText(docPart)
            docPart.append(docPart.Catalog.getString('TimeInSeconds',...
                sprintf('%.4f',docPart.TotalDuration)));
        end
        
        function fillResultsIcons(docPart)
            numImages = numel(docPart.ImageObjects);
            for k=1:numImages
                docPart.append(docPart.ImageObjects(k));
                if k~=numImages
                    docPart.appendUnmodifiedText(getSpacingToAddAfterIndex(k));
                end
            end
        end
    end
end


function txt = getSpacingToAddAfterIndex(k)
if mod(k,50)==0
    txt = newline();
elseif mod(k,5)==0
    txt = '    ';
else
    txt = ' ';
end
end

% LocalWords:  unittest
