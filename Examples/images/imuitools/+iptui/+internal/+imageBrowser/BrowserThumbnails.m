% Copyright 2016 The MathWorks, Inc.
classdef BrowserThumbnails < iptui.internal.imageBrowser.Thumbnails

    properties (Constant = true)
        % PaddingAroundThumbnail - padding around the thumbnail
        PaddingAroundThumbnail = [20 20];        
    end
    
    properties
        hExportToWorkspacemenu = [];
        hBoldPatch = [];                       
    end
    
    properties (Access = private)
        % BoldImageNum - the single block that is currently shown as bold
        BoldImageNum = []
        
        % Border color for showing current image (shown in preview) when
        % multi selected thumbnails exist and preview is open.
        ThumbNailImageBoldColor = uint8([0 147 255]);       
    end
    
    methods (Abstract = true)        
        createThumbnail(thumbs,imageNum);
    end
    
    methods
        function thumbs = BrowserThumbnails(hParent, tSize)            
            thumbs@iptui.internal.imageBrowser.Thumbnails(hParent, [1 1]);
            
            thumbs.BlockSize     = tSize + thumbs.PaddingAroundThumbnail;
            thumbs.ThumbnailSize = tSize;
            
            thumbs.hExportToWorkspacemenu = uimenu(thumbs.hContextMenu,...
                'Label',getString(message('images:commonUIString:exportImageToWS')),...
                'Tag','ExportToWS',...
                'Callback',@thumbs.exportToWorkSpace);
        end
        
        function showContextMenu(thumbs, hContextMenu, ~) %#ok<INUSD>
            if numel(thumbs.CurrentSelection)>1
                thumbs.hExportToWorkspacemenu.Enable = 'off';
            else
                thumbs.hExportToWorkspacemenu.Enable = 'on';
            end
        end
        
        function exportToWorkSpace(thumbs, varargin)
            % will only be called for single selection
            im = thumbs.readFullImage(thumbs.CurrentSelection(1));
            h = export2wsdlg({[getString(message('images:commonUIString:saveAs')) ':']},{'im'}, {im});
            movegui(h,'center');
        end

        function updateThumbnailSize(thumbs, tSize)
            thumbs.BlockSize     = tSize + thumbs.PaddingAroundThumbnail;
            thumbs.ThumbnailSize = tSize;       
            thumbs.refreshThumbnails();
        end
        
        function meta = getBasicMetaDataFromThumbnail(thumbs, imageNum)
            meta = [];
            if ~isempty(thumbs.ImageNumToDataInd) && thumbs.ImageNumToDataInd(imageNum)
                meta = thumbs.hImageData(thumbs.ImageNumToDataInd(imageNum)).hImage.UserData;
            end
        end
        
    end
    
    methods % Abstract and overiding implementations of base class methods
        function positionsInvalidated(thumbs)
            if ~isvalid(thumbs)
                return;
            end
            
            positionsInvalidated@iptui.internal.imageBrowser.Thumbnails(thumbs);
            
            % Reposition bold patch
            thumbs.enBolden(thumbs.BoldImageNum);            
        end
        
        function updateBlockWithPlaceholder(thumbs, topLeftyx, imageNum)            
            % Gets called whenever imageNum is visible
            if(thumbs.ImageNumToDataInd(imageNum))
                % Already created, reposition
                hImage = thumbs.hImageData(thumbs.ImageNumToDataInd(imageNum)).hImage;
                % Center in block space
                topLeftyx = topLeftyx + ...
                    (thumbs.BlockSize-[size(hImage.CData,1), size(hImage.CData,2)])/2;
                set(hImage,'YData',topLeftyx(1));
                set(hImage,'XData',topLeftyx(2));
                set(hImage,'Visible','on');                
            else
                % Create placeholder image
                userdata = [];
                userdata.isPlaceholder = true;
                thumbnail = thumbs.PlaceHolderImage;
                
                % Center in block
                topLeftyx = topLeftyx + (thumbs.BlockSize-[size(thumbnail,1), size(thumbnail,2)])/2;
                hImage = image(...
                    'Parent', thumbs.hAxes,...
                    'YData', topLeftyx(1),...
                    'XData', topLeftyx(2),...
                    'Tag','Placeholder',...
                    'CDataMapping', 'scaled',...
                    'HitTest','off',...
                    'UserData', userdata,...
                    'Cdata', thumbnail);
                thumbs.hImageData(end+1).hImage = hImage;
                thumbs.ImageNumToDataInd(imageNum) = numel(thumbs.hImageData);
            end
        end
        
        function updateBlockWithActual(thumbs, topLeftyx, imageNum)
            % Place holder is guaranteed to be created
            
            hImageInd = thumbs.ImageNumToDataInd(imageNum);
            % Already created (could be a placeholder image)
            hImage = thumbs.hImageData(hImageInd).hImage;
            
            if strcmp(hImage.Tag,'Realthumbnail')
                % Real thumbnail already created, reposition
                % Center in block
                topLeftyx = topLeftyx + ...
                    (thumbs.BlockSize-[size(hImage.CData,1), size(hImage.CData,2)])/2;
                set(hImage,'YData',topLeftyx(1));
                set(hImage,'XData',topLeftyx(2));
                set(hImage,'Visible','on');                
            else
                % Create
                [thumbnail, userdata] = thumbs.createThumbnail(imageNum);
                % Scale display range if required
                if(~isa(thumbnail,'uint8'))
                    minPix = min(thumbnail(:));
                    thumbnail = thumbnail - minPix;
                    maxPix = max(thumbnail(:));
                    thumbnail = uint8(double(thumbnail)/double(maxPix) *255);
                end
                
                % Center in block
                topLeftyx = topLeftyx + (thumbs.BlockSize-[size(thumbnail,1), size(thumbnail,2)])/2;
                
                % Update existing placeholder with real image
                hImage.CData = thumbnail;
                hImage.YData = topLeftyx(1);
                hImage.XData = topLeftyx(2);
                hImage.Tag   = 'Realthumbnail';
                userdata.isPlaceholder = false;
                hImage.UserData =  userdata;
                
                % Allow the app launcher gallery to update based on real
                % thumbnail
                if ismember(imageNum, thumbs.CurrentSelection)
                    notify(thumbs,'SelectionChange');
                end
            end            
        end        
    end
    
    methods % Custom color markings        
        function enBolden(thumbs, imageNum)
            % Make a single thumbnail 'bold' to highlight selection within
            % a multiselection
            delete(thumbs.hBoldPatch);
            [patchX, patchY] = getPatchVerticesForFullBlock(thumbs, imageNum);
            thumbs.hBoldPatch = ...
                patch(patchX, patchY, thumbs.ThumbNailImageBoldColor,...
                'Parent',thumbs.hAxes,...
                'FaceAlpha', 0.5,...
                'Tag','BoldPatch',...
                'EdgeColor','none');
            thumbs.BoldImageNum = imageNum;
        end
        
        function unBold(thumbs)
            delete(thumbs.hBoldPatch);
            thumbs.BoldImageNum = [];
        end
                
    end
end