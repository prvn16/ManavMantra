classdef LeftArtifactImagePart < matlab.unittest.internal.dom.ReportDocumentPart
    %This class is undocumented and may change in a future release.
    
    %  Copyright 2016-2017 The MathWorks, Inc.
    properties(SetAccess=immutable)
        ImageFile
    end
    
    properties(Access=private)
        ImageObject = [];
    end
    
    methods
        function docPart = LeftArtifactImagePart(imageFile)
            docPart.ImageFile = imageFile;
        end
    end
    
    methods(Access=protected)
        function delegateDocPart = createDelegateDocumentPart(docPart,testReportData)
            if isa(docPart.ImageObject,'mlreportgen.dom.Image')
                delegateDocPart = testReportData.createDelegateDocumentPartFromName('LeftArtifactImagePart');
            else
                delegateDocPart = testReportData.createDelegateDocumentPartFromName('BlankPart');
            end
        end
        
        function setupPart(docPart,~)
            try
                docPart.ImageObject = docPart.createRestrictedImage(docPart.ImageFile);
            catch exception
                warning(message('MATLAB:unittest:TestReportDocument:UnableToAddImageFile',...
                    docPart.ImageFile,exception.message));
            end
        end
        
        function teardownPart(docPart)
            docPart.ImageObject = [];
        end
    end
    
    methods(Hidden) % Fill template holes ---------------------------------
        function fillImage(docPart)
            docPart.append(docPart.ImageObject);
        end
    end
    
    methods(Static)
        function imgObj = createRestrictedImage(imgFile)
            % Creates a mlreportgen.dom.Image whose width does not exceed 6.9 inches and
            % whose height does not exceed 3.5 inches given the image file provided.
            maxWidthInches = 6.9;
            maxHeightInches = 3.5;
            
            imgObj = mlreportgen.dom.Image(imgFile);
            widthPixels = str2double(strrep(imgObj.Width,'px',''));
            heightPixels = str2double(strrep(imgObj.Height,'px',''));
            
            pxPerIn = rptgen.utils.getScreenPixelsPerInch();
            widthInches = widthPixels/pxPerIn;
            heightInches = heightPixels/pxPerIn;
            
            [newWidth,newHeight] = constrainDimensions(widthInches,heightInches,...
                maxWidthInches,maxHeightInches);
            
            imgObj.Width = sprintf('%fin',newWidth);
            imgObj.Height = sprintf('%fin',newHeight);
        end
    end
end


function [newWidth,newHeight] = constrainDimensions(width,height,widthMax,heightMax)
% Maintains that newWidth/newHeight is equal to width/height ratio while
% ensuring that newWidth <= widthMax and newHeight <= heightMax
reductionFactor = min([1,widthMax/width,heightMax/height]);
newWidth  = reductionFactor * width;
newHeight = reductionFactor * height;
end

% LocalWords:  mlreportgen dom unittest mlreportgen dom unittest px
