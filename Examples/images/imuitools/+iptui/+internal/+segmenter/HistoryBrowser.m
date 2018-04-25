classdef HistoryBrowser < handle
    
    %     Copyright 2015 The MathWorks, Inc.
    
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
    end
    
    properties (Constant = true, Access = private)
        CELLHEIGHT = iptui.internal.segmenter.getThumbnailSize() + 8; %px
    end
    
    methods
        function self = HistoryBrowser(parentHandle, hApp_)
            self.hParent = parentHandle;
            self.hApp = hApp_;
            
            % Thumbnail strip
            self.JImageStrip = javaObjectEDT(...
                com.mathworks.toolbox.images.ImageStrip(self.CELLHEIGHT));
            self.JImageStrip.setjListTag('historyBrowser');

            % Disallow multi-select gestures.
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
        
        function setContent(self, historyCell, selectedRow)
            % Assume for now that historyCell is n-by-4 with these columns:
            % (1) Image thumbnail filename (created from input image)
            % (2) Comment / High-level description
            % (3) Command string
            
            self.CurrentSelection = selectedRow - 1;
            
            % Clear list to avoid possible index-out-of-bounds with prior
            % selection.
            self.JImageStrip.setDataModel([]);
            self.JImageStrip.setSelection([]);
            
            numHistoryEntries = computeNumberOfItemsToDisplay(historyCell);
            data = cell(1, numHistoryEntries);
            for i = 1:numHistoryEntries
                data(i) = {createHistoryEntry(i, historyCell(i,:))};
            end
            
            self.JImageStrip.setDataModel(data);
            self.JImageStrip.redrawList()
            selectedRow = min(selectedRow, numHistoryEntries);
            self.setSelection(selectedRow)
        end
        
        function setSelection(self,rowInds)
            % Convert to 0 based java index
            self.JImageStrip.setSelection(rowInds - 1);
            self.CurrentSelection = rowInds - 1;
        end
        
        function scrollToEnd(self)
            jScrollPane = self.JImageStrip.getScrollPane();
            vsb = jScrollPane.getVerticalScrollBar();
            javaMethodEDT('setValue', vsb, vsb.getMaximum())
        end
        
        function stepBackward(self)
            newIndex = self.CurrentSelection - 1;
            self.setSelection(newIndex + 1);  % 0-based --> 1-based
            cancelled = self.respondToNewSelection(newIndex);
            if (cancelled)
                self.CurrentSelection = newIndex + 1;
                self.setSelection(self.CurrentSelection + 1)
            end
            self.hApp.updateUndoRedoButtons()
        end
        
        function stepForward(self)
            newIndex = self.CurrentSelection + 1;
            self.setSelection(newIndex + 1);  % 0-based --> 1-based
            cancelled = self.respondToNewSelection(newIndex);
            if (cancelled)
                self.CurrentSelection = newIndex - 1;
                self.setSelection(self.CurrentSelection  + 1)
            end
            self.hApp.updateUndoRedoButtons()
        end
    end
    
    % Callbacks
    methods (Access = private)
        function leftClickCallback(self, ~, ~)
            jInds = self.JImageStrip.getSelection();
            
            if (isequal(jInds, self.CurrentSelection))
                return
            end
            
            cancelled = self.respondToNewSelection(jInds);
            if (cancelled)
                jInds = self.CurrentSelection;
                self.JImageStrip.setSelection(jInds)
            end
        end
        
        function cancelled = respondToNewSelection(self, jInds)
            if (isempty(jInds))
                cancelled = false;
                return
            end
            
            if self.hApp.DrawingROI
                cancelled = true;
                return;
            end
            
            if (self.hApp.ActiveContoursIsRunning)
                self.hApp.stopActiveContours()
                wasRunningAC = true;
            else
                wasRunningAC = false;
            end
            
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
                    
                case {'Cancel',''} % Include x button here
                    cancelled = true;
                    return
                end
            end

            cancelled = false;
            
            if (~isequal(jInds, self.CurrentSelection))
                self.CurrentSelection = jInds;
                
                % Committing temporary state above might have moved the
                % selection. Be sure it matches what was clicked.
                if (~isequal(self.JImageStrip.getSelection(), jInds))
                    self.JImageStrip.setSelection(jInds)
                end
            end
            
            self.updateAppFromSelection()
            self.hApp.updateUndoRedoButtons()
        end
        
        function updateAppFromSelection(self)
            self.hApp.setCurrentHistoryItem(self.CurrentSelection + 1);
        end
    end
end

function str = createHistoryEntry(entryNumber, historyCell)

thumbnailFileName = historyCell{1};
comment = historyCell{2};

str = ...
    ['<html>',...
    '<table><tr>',...
    '<td align="center" valign="middle">', sprintf('%d', entryNumber), '</td>', ...
    '<td width="72px" align="center" valign="top"><img src="file:' thumbnailFileName '"/></td>',...
    '<td align="left" valign="middle"><b>', comment, '</b><br /></td>',...
    '</tr>', ...
    '</table>',...
    '</html> '];

end

function numItems = computeNumberOfItemsToDisplay(historyCell)

numItems = size(historyCell, 1);

end
