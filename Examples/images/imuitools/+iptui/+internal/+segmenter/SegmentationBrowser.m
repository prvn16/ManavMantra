classdef SegmentationBrowser < handle
    
    % Copyright 2015 The MathWorks, Inc.
    
    properties (Hidden = true)
        hParent
        hApp
        
        JImageStrip
        
        JClickCallback
        JUndoCallback
        JRedoCallback
    end
    
    properties (Access = private)
        CurrentSelection = [];  % 0-based
        ThumbnailFilenames = {};
        CurrentDetailsCell = {};
    end
    
    properties (Constant = true, Access = private)
        CELLHEIGHT = iptui.internal.segmenter.getThumbnailSize() + 8; %px
    end
    
    methods
        function self = SegmentationBrowser(parentHandle, hApp_)
            self.hParent = parentHandle;
            self.hApp = hApp_;
            
            % Thumbnail strip
            self.JImageStrip = javaObjectEDT(...
                com.mathworks.toolbox.images.ImageStrip(self.CELLHEIGHT));
            self.JImageStrip.setjListTag('segmentationBrowser');
            
            % Disallow multi-select gestures
            self.JImageStrip.setSelectionMode('single');
            
            jScrollPane = self.JImageStrip.getScrollPane();
            jScrollPane.setAlignmentX(java.awt.Component.LEFT_ALIGNMENT);
            parentHandle.add(jScrollPane);
            
            % Wire up MATLAB callbacks to left click on jlist
            hSelectionCallback  = handle(self.JImageStrip.getSelectionCallback);
            self.JClickCallback = ...
                handle.listener(hSelectionCallback,...
                'delayed', @self.leftClickCallback);

            % Undo/redo events from the Java image strip.
            hUndoCallback = handle(self.JImageStrip.getUndoCallback);
            hRedoCallback = handle(self.JImageStrip.getRedoCallback);
            self.JUndoCallback = ...
                handle.listener(hUndoCallback, ...
                'delayed', @hApp_.undoHandler);
            self.JRedoCallback = ...
                handle.listener(hRedoCallback, ...
                'delayed', @hApp_.redoHandler);
        end
        
        function setContent(self, segmentationDetailsCell, selectedRow)
            self.CurrentSelection = selectedRow - 1;
            self.CurrentDetailsCell = segmentationDetailsCell;
            
            self.updateBrowserContent(segmentationDetailsCell, selectedRow)
            
            self.cleanupThumbnails()
            self.ThumbnailFilenames = segmentationDetailsCell(:,1);
        end
        
        function setSelection(self, rowIndex)
            % Convert to 0 based java index
            self.JImageStrip.setSelection(rowIndex - 1);
            self.CurrentSelection = rowIndex - 1;
            
            self.hApp.refreshHistoryBrowser()
        end
        
        function selection = getSelection(self)
            selection = self.CurrentSelection + 1;
        end
        
        function delete(self)
            self.cleanupThumbnails()
        end
        
        function updateActiveThumbnail(self, newThumbnailFilename)
            listIndex = self.CurrentSelection + 1;
            try
                delete(self.CurrentDetailsCell{listIndex, 1})
            catch
                % Don't worry about thumbnails that can't be deleted.
            end
            
            self.CurrentDetailsCell{listIndex, 1} = newThumbnailFilename;
            
            self.updateBrowserContent(self.CurrentDetailsCell, ...
                listIndex)
            self.ThumbnailFilenames{listIndex} = newThumbnailFilename;
        end
        
        function scrollToEnd(self)
            jScrollPane = self.JImageStrip.getScrollPane();
            vsb = jScrollPane.getVerticalScrollBar();
            javaMethodEDT('setValue', vsb, vsb.getMaximum())
        end
    end
    
    % Callbacks
    methods (Access = private)
        function leftClickCallback(self, varargin)
            jInds = self.JImageStrip.getSelection();
            
            if (isequal(jInds, self.CurrentSelection))
                return
            end
            
            if (self.hApp.ActiveContoursIsRunning)
                self.hApp.stopActiveContours()
                wasRunningAC = true;
            else
                wasRunningAC = false;
            end
            
            % If there is uncommitted history, ask the user if they want to
            % apply changes before returning to the main tab.
            if (self.hApp.CurrentSegmentation.HasUncommittedState || wasRunningAC)
                buttonName = questdlg(...
                    getString(message('images:imageSegmenter:uncommitedStateQuestion')), ...
                    getString(message('images:imageSegmenter:uncommitedStateTitle')));
                
                switch (buttonName)
                case 'Yes'
                    self.hApp.applyCurrentTabSettings()
                    self.hApp.returnToSegmentTab()
                    
                case 'No'
                    self.hApp.clearTemporaryHistory()
                    self.hApp.returnToSegmentTab()
                    
                case 'Cancel'
                    jInds = self.CurrentSelection;
                    self.JImageStrip.setSelection(jInds)
                    return
                end
            end
            
            % If a different segmentation has been selected, update the
            % history view and mask view.
            if (~isequal(jInds, self.CurrentSelection))
                self.CurrentSelection = jInds;
                self.hApp.Session.ActiveSegmentationIndex = jInds + 1;
                self.hApp.refreshHistoryBrowser()
                
                theSegmentation = self.hApp.Session.CurrentSegmentation();
                self.hApp.updateScrollPanelCommitted(theSegmentation.getMask())
                self.hApp.updateModeOnSegmentationChange()
                
                self.hApp.scrollHistoryBrowserToEnd()
                
                % Committing temporary state above might have moved the
                % selection. Be sure it matches what was clicked.
                if (~isequal(self.JImageStrip.getSelection(), jInds))
                    self.JImageStrip.setSelection(jInds)
                end
            end
            
            self.hApp.updateUndoRedoButtons()
        end
        
        function cleanupThumbnails(self)
            orig_state = warning('off','all');
            numThumbnails = numel(self.ThumbnailFilenames);
            for p = 1:numThumbnails
                try
                    delete(self.ThumbnailFilenames{p})
                catch
                    % Don't worry about thumbnails that can't be deleted.
                end
            end
            warning(orig_state);
        end
        
        function updateBrowserContent(self, detailsCell, selectedRow)
            % Clear list to avoid possible index-out-of-bounds with prior
            % selection.
            self.JImageStrip.setDataModel([]);
            self.JImageStrip.setSelection([]);
            
            numSegmentations = size(detailsCell, 1);
            data = cell(1, numSegmentations);
            for i = 1:numSegmentations
                data(i) = {createSegmentationListEntry(i, detailsCell(i,:))};
            end
            
            self.JImageStrip.setDataModel(data);
            self.JImageStrip.redrawList()
            self.setSelection(selectedRow)
        end
    end
end

function str = createSegmentationListEntry(segmentationNumber, segmentationDetailsCell)

thumbnailFileName = segmentationDetailsCell{1};
segmentationName = segmentationDetailsCell{2};

str = ...
    ['<html>',...
    '<table><tr>',...
    '<td align="center" valign="middle">', sprintf('%d', segmentationNumber), '</td>', ...
    '<td width="72px" align="center" valign="top"><img src="file:' thumbnailFileName '"/></td>',...
    '<td align="left" valign="middle"><b>', segmentationName, '</b><br /></td>',...
    '</tr>', ...
    '</table>',...
    '</html> '];
end
