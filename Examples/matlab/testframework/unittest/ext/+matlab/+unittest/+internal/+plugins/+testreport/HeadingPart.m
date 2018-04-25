classdef HeadingPart < matlab.unittest.internal.dom.ReportDocumentPart
    %This class is undocumented and may change in a future release.
    
    %  Copyright 2016-2017 The MathWorks, Inc.
    properties(SetAccess=immutable)
        OutlineLevel
        HeadingText
        LinkTarget
        IconFile
    end
    
    methods
        function docPart = HeadingPart(outlineLevel, headingTxt, linkTarget, iconFile)
            docPart.OutlineLevel = outlineLevel;
            docPart.HeadingText = headingTxt;
            if nargin > 2
                docPart.LinkTarget = linkTarget;
            end
            if nargin > 3
                docPart.IconFile = iconFile;
            end
        end
    end
    
    methods(Access=protected)
        function delegateDocPart = createDelegateDocumentPart(docPart,testReportData)
            templateName = sprintf('Heading%uPart',docPart.OutlineLevel);
            delegateDocPart = testReportData.createDelegateDocumentPartFromName(templateName);
        end
    end
    
    methods(Hidden) % Fill template holes ---------------------------------
        function fillHeading(docPart)
            import mlreportgen.dom.Image;
            
            if ~isempty(docPart.LinkTarget)
                docPart.append(docPart.LinkTarget);
            end
            
            if ~isempty(docPart.IconFile)
                imgObj = Image(docPart.IconFile);
                imgObj.Width = '0.11in';
                imgObj.Height = '0.11in';
                docPart.append(imgObj);
                docPart.appendUnmodifiedText(' ');
            end
            
            docPart.appendUnmodifiedText(docPart.HeadingText);
        end
    end
end