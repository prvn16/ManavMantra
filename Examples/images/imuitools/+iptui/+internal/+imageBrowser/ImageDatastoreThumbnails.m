% Copyright 2016 The MathWorks, Inc.
classdef  ImageDatastoreThumbnails< iptui.internal.imageBrowser.BrowserThumbnails
    
    properties (SetAccess = protected)
        NumberOfThumbnails = 0;
        imVar;
    end
    
    
    methods
        function thumbs = ImageDatastoreThumbnails(hParent, tSize, imVar_)
            thumbs@iptui.internal.imageBrowser.BrowserThumbnails(hParent, tSize);
            thumbs.imVar = imVar_;
            thumbs.NumberOfThumbnails = numel(thumbs.imVar.Files);
            thumbs.refreshThumbnails();
        end
        
        function delete(~)
        end
        
        function [thumbnail, userdata] = createThumbnail(thumbs, imageNum)
            fullImage = thumbs.readFullImage(imageNum);
            % Create thumbnail
            if ndims(fullImage)>3 || ( size(fullImage,3)~=1 &&size(fullImage,3)~=3)
                % pick first plane
                fullImage = fullImage(:,:,1);
            end
            thumbnail = thumbs.resizeToThumbnail(fullImage);
            
            % Meta data of the full image
            userdata.class = class(fullImage);
            userdata.isStack = false;
            userdata.size = size(fullImage);
        end
        
        function im = readFullImage(thumbs, imageNum)
            try
                im = thumbs.imVar.readimage(imageNum);
            catch ALL %#ok<NASGU>
                im = thumbs.CorruptedImagePlaceHolder;
            end
        end
        
        
        function desc = getOneLineDescription(thumbs, imageNum)
            desc = thumbs.imVar.Files{imageNum};
        end
        
    end
end