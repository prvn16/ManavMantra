% Copyright 2016 The MathWorks, Inc.

classdef FileThumbnails < iptui.internal.imageBrowser.BrowserThumbnails
    
    properties
        imds;
    end
    
    properties (SetAccess = protected)
        NumberOfThumbnails = 0;
    end
    
    events
        CountChanged;
    end
    
    methods
        function thumbs = FileThumbnails(hParent, tSize)
            thumbs@iptui.internal.imageBrowser.BrowserThumbnails(hParent, tSize);
            
            thumbs.imds = datastore({},'Type','image',...
                'ReadFcn', @iptui.internal.imageBrowser.readAllIPTFormats);
            addlistener(thumbs, 'DeleteSelection', @thumbs.removeSelectedFiles);
            
            uimenu(thumbs.hContextMenu,...
                'Label',getString(message('images:imageBrowser:removeFromBrowser')),...
                'Tag', 'Remove',...
                'Callback',@thumbs.removeSelectedFiles);                        
        end
        
        function set.imds(thumbs, imds_)
            if ~isequal(thumbs.imds, imds_)
                thumbs.imds = imds_;
                thumbs.NumberOfThumbnails = numel(imds_.Files); %#ok<MCSUP>
                thumbs.refreshThumbnails();
            end
        end
                
        function delete(~)
        end
                        
        function removeSelectedFiles(thumbs,~,~)
            inds = thumbs.CurrentSelection;            
            
            % Remove from data source
            thumbs.imds.Files(inds) = [];
            % Remove from browser view and cache
            thumbs.removeImages(inds);
            
            % Notify app of change in thumbnail count
            thumbs.NumberOfThumbnails = numel(thumbs.imds.Files);
            notify(thumbs, 'CountChanged');               
            
            if isvalid(thumbs) % Component is destroyed by the app if count==0                
                newSelection = min(max(inds), thumbs.NumberOfThumbnails);
                if newSelection ~=0
                    % If any images are left
                    thumbs.setSelection(newSelection);
                end
                % Reposition thumbnails to account for the deleted
                thumbs.updateGridLayout();
            end                        
        end
        
        function [thumbnail, userdata] = createThumbnail(thumbs, imageNum)
            fullImage = thumbs.readFullImage(imageNum);
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
        
        function desc = getOneLineDescription(thumbs, imageNum)
            desc = thumbs.imds.Files{imageNum};
        end
        
        function im = readFullImage(thumbs, imageNum)
            try
                im = thumbs.imds.readimage(imageNum);
            catch ALL %#ok<NASGU>
                im = thumbs.CorruptedImagePlaceHolder;
            end
        end
        
    end
end