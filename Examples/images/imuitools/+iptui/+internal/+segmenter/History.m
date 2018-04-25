classdef History < handle
    
    % Copyright 2015-2016 The MathWorks, Inc.
    
    properties (Access=private)
        CurrentItem = 0;
        Descriptions = {};
        Masks = {};
        CommandList = {};
        MaskIsEmptyList = [];
        
        hHistoryBrowser
        ThumbnailFilenames = {};
        
        PendingDescription = '';
        PendingMask = [];
        PendingCommand = '';
    end
    
    properties (Dependent, SetAccess = private)
        IsEmpty
        IsAtBeginning
        IsAtEnd
        CurrentMaskIsEmpty
        HasUncommittedState
    end
    
    methods
        function self = History(hHistoryBrowser_)
            self.hHistoryBrowser = hHistoryBrowser_;
        end
        
        function delete(self)
            self.hHistoryBrowser.setSelection([])
            self.hHistoryBrowser.setContent([],[])
            self.cleanupAllThumbnails()
        end
        
        function copiedSelf = copy(self)
            copiedSelf = iptui.internal.segmenter.History(self.hHistoryBrowser);

            copiedSelf.Descriptions = self.Descriptions;
            copiedSelf.Masks = self.Masks;
            copiedSelf.CommandList = self.CommandList;
            copiedSelf.MaskIsEmptyList = self.MaskIsEmptyList;
            
            copiedSelf.CurrentItem = self.CurrentItem;
            
            numThumbnails = numel(self.ThumbnailFilenames);
            for index = 1:numThumbnails
                copiedSelf.ThumbnailFilenames{index} = ...
                    iptui.internal.segmenter.createThumbnail(self.Masks{index}.getMask());
            end
        end
        
        function refreshHistoryBrowser(self)
            cellRepresentation = self.convertToCellArray();
            self.hHistoryBrowser.setContent(cellRepresentation, self.CurrentItem)
        end
        
        function addAtCurrent(self, newMaskView, description, command)
            self.trimAfter(self.CurrentItem)
            
            self.CurrentItem = self.CurrentItem + 1;
            
            idx = self.CurrentItem;
            self.Descriptions{idx} = description;
            self.Masks{idx} = newMaskView;
            self.MaskIsEmptyList(idx) = newMaskView.isempty();
            
            self.ThumbnailFilenames{idx} = ...
                iptui.internal.segmenter.createThumbnail(newMaskView.getMask());
            
            self.CommandList{idx} = command;
        end
        
        function setTemporaryState(self, newMask, description, command)
            self.PendingMask = newMask;
            self.PendingDescription = description;
            self.PendingCommand = command;
        end
        
        function [mask, description, command] = getTemporaryState(self)
            mask = self.PendingMask;
            description = self.PendingDescription;
            command = self.PendingCommand;
        end
        
        function clearTemporaryState(self)
            self.PendingMask = [];
            self.PendingDescription = '';
            self.PendingCommand = '';
        end
        
        function setCurrentMask(self, newMask)
            % History.setTemporaryState() should have
            % been called before History.setCurrentMask()
            assert(~isequal(self.PendingMask,[]));
            self.PendingMask.updateMask(newMask);
        end
        
        function setCurrentItem(self, indexOfNewCurrentItem)
            assert(indexOfNewCurrentItem <= numel(self.Masks))
            
            self.CurrentItem = indexOfNewCurrentItem;
        end
        
        function mask = getCurrentMask(self)
            if ~isequal(self.PendingMask,[])
                mask = self.PendingMask;
            else
                % PendingMask hasn't been initialized
                mask = self.Masks{self.CurrentItem};
            end
        end
        
        function mask = getMask(self, indexIntoHistory)
            assert(indexIntoHistory <= numel(self.Masks))
            
            mask = self.Masks{indexIntoHistory};
        end
        
        function serializedHistoryCell = export(self)
            n = self.CurrentItem;
            serializedHistoryCell = [self.Descriptions(1:n)', self.CommandList(1:n)'];
        end
        
        function trimAfterCurrentItem(self)
            self.trimAfter(self.CurrentItem)
        end
    end
    
    % Dependent property getters/setters
    methods
        function TF = get.IsEmpty(self)
            TF = self.CurrentItem == 0;
        end
        
        function TF = get.IsAtBeginning(self)
            TF = self.CurrentItem <= 1;
        end
        
        function TF = get.IsAtEnd(self)
            TF = self.CurrentItem == numel(self.Descriptions);
        end
        
        function TF = get.CurrentMaskIsEmpty(self)
            if (self.CurrentItem > 0)
                TF = self.MaskIsEmptyList(self.CurrentItem);
            else
                TF = true;
            end
        end
        
        function TF = get.HasUncommittedState(self)
            TF = ~isequal(self.PendingMask,[]);
        end
    end
    
    methods (Access=private)
        function trimAfter(self, lastItemToKeep)
            firstToClear = lastItemToKeep + 1;
            
            self.Descriptions(firstToClear:end) = [];
            self.Masks(firstToClear:end) = [];
            self.MaskIsEmptyList(firstToClear:end) = [];
            self.CommandList(firstToClear:end) = [];
            
            self.cleanupThumbnailsAfter(lastItemToKeep)
            
            if (self.CurrentItem > numel(self.Descriptions))
                self.CurrentItem = numel(self.Descriptions);
            end
        end
        
        function cleanupAllThumbnails(self)
            self.cleanupThumbnailsAfter(0)
        end
        
        function cleanupThumbnailsAfter(self, index)
            origWarnState = warning();
            warning('off', 'MATLAB:DELETE:FileNotFound')
            warning('off', 'MATLAB:DELETE:Permission')
            
            numThumbnails = numel(self.ThumbnailFilenames);
            for p = (index + 1):numThumbnails
                deleteFile(self.ThumbnailFilenames{p});
            end
            
            self.ThumbnailFilenames((index + 1):end) = [];
            
            warning(origWarnState)
        end
        
        function cellRepresentation = convertToCellArray(self)
            numberOfEntries = numel(self.Descriptions);
            cellRepresentation = cell(numberOfEntries, 3);
            
            for idx = 1:numberOfEntries
                cellRepresentation{idx, 1} = self.ThumbnailFilenames{idx};
                cellRepresentation{idx, 2} = self.Descriptions{idx};
                cellRepresentation{idx, 3} = self.CommandList{idx};
            end
        end
    end

    % Debugging
    methods
        function dump(self)
            fprintf('Current item: %d\n', self.CurrentItem);
            
            numItems = max(numel(self.Descriptions), numel(self.CommandList));
            fprintf('Number of items: %d\n', numItems);
            
            % Print regular items
            for p = 1:numItems
                fprintf('  Item %d\n', p);
                if (p > numel(self.Descriptions))
                    fprintf('    Description: NULL!!!!\n');
                else
                    fprintf('    Description: %s\n', self.Descriptions{p});
                end
                
                if (p > numel(self.CommandList))
                    fprintf('    Command: NULL!!!!\n');
                elseif (iscell(self.CommandList{p}))
                    n = numel(self.CommandList{p});
                    fprintf('    Command: %d-by-1 cell\n', n);
                    for subCommand = 1:n
                        fprintf('      %s\n', self.CommandList{p}{subCommand});
                    end
                else
                    fprintf('    Command: %s\n', self.CommandList{p});
                end
                fprintf('    Mask empty? %s\n', self.logical2str(self.MaskIsEmptyList(p)));
                fprintf('    Thumbnail file: %s\n', self.ThumbnailFilenames{p});
            end
            
            % Print temporary / uncommitted items.
            fprintf('  Pending item\n');
            fprintf('    Description: %s\n', self.PendingDescription);
            if (iscell(self.PendingCommand))
                n = numel(self.PendingCommand);
                fprintf('    Command: %d-by-1 cell\n', n);
                for subCommand = 1:n
                    fprintf('      %s\n', self.PendingCommand{subCommand});
                end
            else
                fprintf('    Command: %s\n', self.PendingCommand);
            end
            
            fprintf('\n');
        end
        
        function str = logical2str(self, TF) %#ok<INUSL>
            if TF
                str = 'TRUE';
            else
                str = 'FALSE';
            end
        end
    end
end
        
function deleteFile(filename)
    try
        if (~isempty(filename))
            delete(filename)
        end
    catch
        % Don't worry about thumbnails that can't be deleted.
    end
end
