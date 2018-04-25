% Copyright 2016 The MathWorks, Inc.
classdef  BatchThumbnails< iptui.internal.imageBrowser.Thumbnails
    
    properties (SetAccess = protected)
        NumberOfThumbnails = 0;
    end
    
    properties
        imageStore;
        
        errorColor     = uint8([162 20 47]);
        doneColor      = uint8([119 172 48]);
        staleColor     = uint8([180 204 149]);
        
        maxTextChars   = 14;
        StatusIndicatorSize = 10;
        PaddingBetweenImageAndText = 2;
        
        fileState     = uint8([]);
        
        hColorPatchesMap = containers.Map();
        hNotDonePatch    = [];
        
        hPanel = [];
        hShowDropDown = [];
        
        allImageStore = [];
        erroredImageStore = [];
    end
    
    
    methods
        function thumbs = BatchThumbnails(hParent)
            hPanel = uipanel(...
                'Units','Pixels',...
                'Parent', hParent);
            
            thumbs@iptui.internal.imageBrowser.Thumbnails(hPanel, [1 1]);
            
            thumbs.hShowDropDown =  uicontrol(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Background',[ 1 1 1 ],...
                'Style', 'popupmenu',...
                'Callback', @thumbs.toggleThumbnails,...
                'Tag', 'FilterThumbnailsDropDown',...
                'Value', 1,...
                'String', {getString(message('images:imageList:showAll')),getString(message('images:imageList:showErrored'))});
            
            thumbs.hPanel = hPanel;
            hParent.SizeChangedFcn = @(varargin)thumbs.repositionPanels;
            thumbs.repositionPanels();
        end
        
        function thumbs = setContent(thumbs, imageBatchDataStore_)
            thumbs.imageStore    = imageBatchDataStore_;
            thumbs.NumberOfThumbnails = thumbs.imageStore.NumberOfImages;
            
            thumbs.ThumbnailSize = [100 100];            
            thumbs.BlockSize     = [130 130];
            
            thumbs.hShowDropDown.Value = 1;
            thumbs.refreshThumbnails();
            thumbs.setSelection(1);
        end
    end
    
    % Implementations of required abstract methods
    methods
        function [thumbnail, userdata] = createThumbnail(thumbs, imageNum)
            try
                fullImage = thumbs.imageStore.read(imageNum);
            catch ALL %#ok<NASGU>
                fullImage = thumbs.CorruptedImagePlaceHolder;
            end
            
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
        
        function desc = getFileName(thumbs, imageNum)
            desc = thumbs.imageStore.getInputImageName(imageNum);
        end
    end
    
    % Overriding methods of base class
    methods
        function refreshThumbnails(thumbs)
            refreshThumbnails@iptui.internal.imageBrowser.Thumbnails(thumbs);
            thumbs.deleteAllMarkings();
            thumbs.fileState = zeros(1, thumbs.imageStore.NumberOfImages,'uint8');
        end
        
        function positionsInvalidated(thumbs)
            positionsInvalidated@iptui.internal.imageBrowser.Thumbnails(thumbs);
            % Delete custom markings
            thumbs.repositionMarkings();           
        end
        
        function updateBlockWithPlaceholder(thumbs, topLeftyx, imageNum)
            % Gets called whenever imageNum is visible
            if ~(thumbs.ImageNumToDataInd(imageNum))
                % Create placeholder image
                userdata = [];
                userdata.isPlaceholder = true;
                thumbnail = thumbs.PlaceHolderImage;
                
                hImage = image(...
                    'Parent', thumbs.hAxes,...
                    'Tag','Placeholder',...
                    'HitTest','off',...
                    'CDataMapping', 'scaled',...
                    'UserData', userdata,...
                    'Cdata', thumbnail);
                thumbs.hImageData(end+1).hImage  = hImage;
                thumbs.ImageNumToDataInd(imageNum) = numel(thumbs.hImageData);
                
                % Additional decorations
                [~, fileName, ext] = fileparts(thumbs.getFileName(imageNum));
                fileName = [fileName, ext];
                if numel(fileName)>thumbs.maxTextChars
                    % Trim
                    trimCount = thumbs.maxTextChars-3;
                    fileName = ['...',fileName(end-trimCount:end)];
                end
                
                thumbs.hImageData(end).hNameText = text(thumbs.hAxes, ...
                    0, 0, ...
                    fileName,...
                    'FontSize', 8,...
                    'FontName','FixedWidth',...
                    'VerticalAlignment', 'cap',...
                    'Interpreter','None');
            end
            thumbs.repositionElements(imageNum, topLeftyx);
        end
        
        function updateBlockWithActual(thumbs, topLeftyx, imageNum)
            
            hImageInd = thumbs.ImageNumToDataInd(imageNum);
            % Already created (could be a placeholder image)
            hImage = thumbs.hImageData(hImageInd).hImage;
            
            if ~strcmp(hImage.Tag,'Realthumbnail')
                % Create
                [thumbnail, userdata] = thumbs.createThumbnail(imageNum);
                % Scale display range if required
                if(~isa(thumbnail,'uint8'))
                    minPix = min(thumbnail(:));
                    thumbnail = thumbnail - minPix;
                    maxPix = max(thumbnail(:));
                    thumbnail = uint8(double(thumbnail)/double(maxPix) *255);
                end
                
                % Update existing placeholder with real image
                hImage.CData = thumbnail;
                hImage.Tag   = 'Realthumbnail';
                userdata.isPlaceholder = false;
                hImage.UserData =  userdata;
            end
            
            thumbs.repositionElements(imageNum, topLeftyx);
            
            % Allow the app launcher gallery to update based on real
            % thumbnail
            if ismember(imageNum, thumbs.CurrentSelection)
                % To ensure selection patch goes on top.
                thumbs.markCurrentSelection();
            end
        end
    end
    
    % Helpers
    methods (Access = private)
        function repositionPanels(thumbs)
            menuHeight = 30;
            figurePos = thumbs.hPanel.Parent.Position;
            panelPos  = [0 0 figurePos(3) figurePos(4) - menuHeight];
            thumbs.hPanel.Position = panelPos;
            margin = 5;
            thumbs.hShowDropDown.Position = [margin figurePos(4)-menuHeight...
                figurePos(3)-margin menuHeight-margin];
        end
        
        function repositionElements(thumbs, imageNum, topLeftyx)
            hDataInd = thumbs.ImageNumToDataInd(imageNum);
            hImage   = thumbs.hImageData(hDataInd).hImage;
            
            topMargin = 4;
            topLeftyx(1) = topLeftyx(1)+topMargin;
            
            textOffset = thumbs.SelectionPatchInset ...
                         +thumbs.ThumbnailSize(1)...
                         +thumbs.PaddingBetweenImageAndText;
            % Bottom align thumbnail (account for text space)
            hImage.YData = topLeftyx(1) + thumbs.SelectionPatchInset ...
                         +thumbs.ThumbnailSize(1) -size(hImage.CData,1);
            
            leftMargin = (thumbs.BlockSize(2)-thumbs.ThumbnailSize(2))/2;
            hImage.XData = topLeftyx(2) + leftMargin;
            hImage.Visible = 'on';
                        
            xOffset = leftMargin + thumbs.StatusIndicatorSize + 2;
            posx = topLeftyx(2)+xOffset;
            posy = topLeftyx(1)+textOffset;
            thumbs.hImageData(hDataInd).hNameText.Position = [posx posy];
            thumbs.hImageData(hDataInd).hNameText.Visible = 'on';
        end
        
        function toggleThumbnails(thumbs, ~, ~)
            if thumbs.hShowDropDown.Value == 1
                thumbs.showAll();
            else
                thumbs.showOnlyErrored();
            end
        end
        
        function showAll(thumbs)
            allImageInds = 1:thumbs.imageStore.NumberOfImages;
            thumbs.filter(allImageInds);
        end
        
        function showOnlyErrored(thumbs)
            allImageInds = 1:thumbs.imageStore.NumberOfImages;
            % Hide everything, but errored images (fileState could be
            % smaller in length)
            allImageInds(thumbs.fileState~=1) = 0;
            thumbs.filter(allImageInds);
        end
    end
    
    % Required by batch processor
    methods
        
        function setFileState(thumbs, imageNum, stateString)
            switch stateString
                case 'errored'
                    thumbs.fileState(imageNum) = 1;
                    if thumbs.hShowDropDown.Value == 2
                        % Error filter is ON - update display
                        thumbs.showOnlyErrored();
                    end
                case 'done'
                    thumbs.fileState(imageNum) = 2;
            end
            thumbs.repositionMarkings();
        end
        
        function markAllProcessedAsStale(thumbs)
            thumbs.fileState(thumbs.fileState==2)=3;
            thumbs.repositionMarkings();
        end
    end
    
    methods % Coloring blocks as done/errored/stale
        function repositionMarkings(thumbs)
            thumbs.deleteAllMarkings();
            thumbs.markBlocksWithColor(find(thumbs.fileState==1),thumbs.errorColor); %#ok<FNDSB>
            thumbs.markBlocksWithColor(find(thumbs.fileState==2),thumbs.doneColor); %#ok<FNDSB>
            thumbs.markBlocksWithColor(find(thumbs.fileState==3),thumbs.staleColor); %#ok<FNDSB>
            thumbs.markNotDone();
        end
        
        function markNotDone(thumbs)
            topLeftYXs = thumbs.getTopLeftYX(1:thumbs.NumberOfThumbnails);
            topMargin = 4;
            topLeftYXs(:,1) = topLeftYXs(:,1)+topMargin;

            leftMargin = (thumbs.BlockSize(2)-thumbs.ThumbnailSize(2))/2;
            topLeftYXs(:,2) = topLeftYXs(:,2) + leftMargin;
            
            textOffset = thumbs.SelectionPatchInset ...
                +thumbs.ThumbnailSize(1)...
                +thumbs.PaddingBetweenImageAndText;
            markSquareSize = thumbs.StatusIndicatorSize;
            topLeftYXs(:,1) = topLeftYXs(:,1) + textOffset;
            
            % Mark out the four corners of a square
            topLeftX = topLeftYXs(:,2)';
            patchX       = topLeftX;
            patchX(2, :) = topLeftX+markSquareSize;
            patchX(3, :) = topLeftX+markSquareSize;
            patchX(4, :) = topLeftX;
            
            topLeftY     = topLeftYXs(:,1)';
            patchY       = topLeftY;
            patchY(2, :) = topLeftY;
            patchY(3, :) = topLeftY+markSquareSize;
            patchY(4, :) = topLeftY+markSquareSize;
            
            delete(thumbs.hNotDonePatch);
            thumbs.hNotDonePatch = ...
                patch(patchX, patchY, [1 1 1],...
                'FaceAlpha',0,...
                'Parent',thumbs.hAxes,...
                'Tag','NotDonePatch');
        end
            
        
        function markBlocksWithColor(thumbs, imageNums, color)
            if isempty(imageNums)
                return;
            end
            
            assert(isa(color,'uint8'));
            assert(numel(color)==3);
            key = sprintf('%d', color);
            
            if isKey(thumbs.hColorPatchesMap,key)...
                    && ~isempty(thumbs.hColorPatchesMap(key))...
                    && isvalid(thumbs.hColorPatchesMap(key))
                delete(thumbs.hColorPatchesMap(key));
            end
            
            blockNums = getBlockNumbers(thumbs, imageNums);
            if isempty(blockNums)
                % all filtered out
                return;
            end
            
            topLeftYXs = thumbs.getTopLeftYX(blockNums);
            topMargin = 4;
            topLeftYXs(:,1) = topLeftYXs(:,1)+topMargin;

                        
            leftMargin = (thumbs.BlockSize(2)-thumbs.ThumbnailSize(2))/2;
            topLeftYXs(:,2) = topLeftYXs(:,2) + leftMargin;
            
            textOffset = thumbs.SelectionPatchInset ...
                +thumbs.ThumbnailSize(1)...
                +thumbs.PaddingBetweenImageAndText;
            markSquareSize = thumbs.StatusIndicatorSize;
            topLeftYXs(:,1) = topLeftYXs(:,1) + textOffset;
            
            
            if isequal(color, thumbs.errorColor)
                topLeftX = topLeftYXs(:,2)';
                patchX        = topLeftX;
                patchX(2, :)  = topLeftX+markSquareSize*1/4;
                patchX(3, :)  = topLeftX+markSquareSize*2/4;
                patchX(4, :)  = topLeftX+markSquareSize*3/4;
                patchX(5, :)  = topLeftX+markSquareSize;
                patchX(6, :)  = topLeftX+markSquareSize*3/4;
                patchX(7, :)  = topLeftX+markSquareSize;
                patchX(8, :)  = topLeftX+markSquareSize*3/4;
                patchX(9, :)  = topLeftX+markSquareSize*2/4;
                patchX(10, :) = topLeftX+markSquareSize*1/4;
                patchX(11, :) = topLeftX;
                patchX(12, :) = topLeftX+markSquareSize*1/4;
                
                topLeftY     = topLeftYXs(:,1)';
                patchY       = topLeftY+markSquareSize*1/4;
                patchY(2,:)  = topLeftY;
                patchY(3,:)  = topLeftY+markSquareSize*1/4;
                patchY(4,:)  = topLeftY;
                patchY(5,:)  = topLeftY+markSquareSize*1/4;
                patchY(6,:)  = topLeftY+markSquareSize*2/4;
                patchY(7,:)  = topLeftY+markSquareSize*3/4;
                patchY(8,:)  = topLeftY+markSquareSize;
                patchY(9,:)  = topLeftY+markSquareSize*3/4;
                patchY(10,:) = topLeftY+markSquareSize;
                patchY(11,:) = topLeftY+markSquareSize*3/4;
                patchY(12,:) = topLeftY+markSquareSize*2/4;
            else
                % Mark out the four corners of a square
                topLeftX = topLeftYXs(:,2)';
                patchX       = topLeftX;
                patchX(2, :) = topLeftX+markSquareSize;
                patchX(3, :) = topLeftX+markSquareSize;
                patchX(4, :) = topLeftX;
                
                topLeftY     = topLeftYXs(:,1)';
                patchY       = topLeftY;
                patchY(2, :) = topLeftY;
                patchY(3, :) = topLeftY+markSquareSize;
                patchY(4, :) = topLeftY+markSquareSize;
            end
            
            thumbs.hColorPatchesMap(key) = ...
                patch(patchX, patchY, color,...
                'Parent',thumbs.hAxes,...                
                'EdgeColor', 'none',...
                'Tag',[key,'Patch']);
        end
        
        function deleteAllMarkings(thumbs)
            for k = keys(thumbs.hColorPatchesMap)
                delete(thumbs.hColorPatchesMap(k{1}));
                thumbs.hColorPatchesMap.remove(k{1});
            end            
        end
    end
    
end