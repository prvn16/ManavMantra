classdef Segmentation < handle
    
    % Copyright 2015 The MathWorks, Inc.

    properties
        Name = '';
    end
    
    properties (Dependent=true, SetAccess=private)
        HasUndoItems
        HasRedoItems
        CurrentMaskIsEmpty
        HasUncommittedState
    end
    
    properties (Access=private)
        Normalized
        Dirty
        
        History
        
        hApp
        hSegmentationBrowser
    end
    
    methods
        function self = Segmentation(hApp_)
            self.hApp = hApp_;
            self.History = iptui.internal.segmenter.History(hApp_.getHistoryBrowser());
            self.Dirty = false;
            self.hSegmentationBrowser = hApp_.getSegmentationBrowser();
        end
        
        function mask = getMask(self)
            currentMaskView = self.History.getCurrentMask();
            mask = currentMaskView.getMask();
        end
        
        function serializedHistoryCell = export(self)
            serializedHistoryCell = self.History.export();
        end
        
        function newSegmentation = clone(self)
            newSegmentation = self.deepCopy();
            newSegmentation.History.trimAfterCurrentItem()
        end
        
        function newSegmentation = deepCopy(self)
            newSegmentation = iptui.internal.segmenter.Segmentation(self.hApp);
            newSegmentation.History = self.History.copy();

            newSegmentation.Normalized = self.Normalized;
            newSegmentation.Dirty = true;
            newSegmentation.hSegmentationBrowser = self.hSegmentationBrowser;
        end
        
        function setCurrentHistoryItem(self, historyItemIndex)
            self.History.setCurrentItem(historyItemIndex)
        end
        
        function refreshHistoryBrowser(self)
            self.History.refreshHistoryBrowser()
        end
    end
    
    % Getters/setters
    methods
        function TF = get.HasUndoItems(self)
            TF = ~self.History.IsAtBeginning;
        end
        
        function TF = get.HasRedoItems(self)
            TF = ~self.History.IsAtEnd;
        end
        
        function TF = get.CurrentMaskIsEmpty(self)
            TF = self.History.CurrentMaskIsEmpty;
        end
        
        function TF = get.HasUncommittedState(self)
            TF = self.History.HasUncommittedState;
        end
    end
    
    % Methods to manipulate the history. (Call the app's versions instead.)
    methods (Hidden = true)
        % NOTE: This function is designed to be called by the app. Use the
        % app's addToHistory() method instead of calling this one directly.
        function addToHistory_(self, newMask, description, command)
            tmpMask = iptui.internal.segmenter.MaskView(newMask);
            self.History.addAtCurrent(tmpMask, description, command)
            self.Dirty = true;
            
            self.History.refreshHistoryBrowser()
            
            %TODO: This probably should be happening at the app level, not here.
            self.hApp.scrollHistoryBrowserToEnd()
        end
        
        % NOTE: This function is designed to be called by the app. Use the
        % app's clearTemporaryHistory() method instead of calling this one
        % directly.
        function clearTemporaryHistory_(self)
            self.History.clearTemporaryState()
        end
        
        % NOTE: This function is designed to be called by the app. Use the
        % app's setTemporaryHistory() method instead of calling this one
        % directly.
        function setTemporaryHistory_(self, newMask, description, command)
            tmpMask = iptui.internal.segmenter.MaskView(newMask);
            self.History.setTemporaryState(tmpMask, description, command)
            self.Dirty = true;
        end
        
        % NOTE: This function is designed to be called by the app. It
        % should not be necessary to call this method directly.
        function [mask, description, command] = getTemporaryHistory_(self)
            [mask, description, command] = self.History.getTemporaryState();
        end
        
        % NOTE: This function is designed to be called by the app. Use the
        % app's setCurrentMask() method instead of call this one directly.
        function setCurrentMask_(self, newMask)
            self.History.setCurrentMask(newMask)
        end
    end
end