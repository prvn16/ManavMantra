% Copyright 2014 The MathWorks, Inc.

classdef FilterPanel < handle
    properties (Access=private)
        currentSelections = [];
        closeRequestListeners
        hAddButton
        hAddPanel
        
        maxNumSelections
        
        hPanel
        
        hAddButtonListener
        hRemoveButtonListeners
        
        limitsCache
    end
    
    properties
        hPopup
        filterUpdateEvent
    end
    
    properties (Dependent=true)
        numberOfSelections
    end
    
    methods
        %------------------------------------------------------------------
        function self = FilterPanel(limitsCache_)
            self.maxNumSelections = 4;
            self.limitsCache = limitsCache_;
            
            % Create a panel used by the tearoff popup to hold the selections.
            panelLayoutSpecifier = repmat('f:p:g, 3dlu, ', [1 self.maxNumSelections+1]);
            
            self.hPanel = toolpack.component.TSPanel(...
                '5px,p:g,5px',...
                ['5px, ', panelLayoutSpecifier, '5px']);
            
            self.hPopup = toolpack.component.TSTearOffPopup(self.hPanel);
            
            % Create a selection panel and the "Add another" panel.
            self.createAddPanel();
            
            self.filterUpdateEvent = iptui.internal.FilterUpdate();
        end
        
        %------------------------------------------------------------------
        function [filterFcn, filterString] = getSelectionFilterFcn(self, n)
            if (n <= self.numberOfSelections)
                selection = self.currentSelections(n);
                [filterFcn, filterString] = selection.getFilterFunction();
            else
                filterFcn = [];
            end
        end
        
        %------------------------------------------------------------------
        function n = get.numberOfSelections(self)
            n = numel(self.currentSelections);
        end
        
        %------------------------------------------------------------------
        function reset(self)
            for idx = 1:self.numberOfSelections
                selection = self.currentSelections(1);
                self.removeSelection(selection)
            end
            self.addSelection();
        end
        
        %------------------------------------------------------------------
        function TF = hasDefaultSettings(self, n)
            if (n <= self.numberOfSelections)
                selection = self.currentSelections(n);
                TF = selection.hasDefaultValues;
            else
                TF = true;
            end
        end
    end
    
    methods (Access=private)
        function addSelection(self)
            % Create the new selection panel.
            newSelectionPanel = iptui.internal.FilterSelection(self.limitsCache);
            if isempty(self.currentSelections)
                self.currentSelections = newSelectionPanel;
            else
                self.currentSelections(end+1) = newSelectionPanel;
            end

            tmp = addlistener(newSelectionPanel.hCloseRequestEvent, 'closing', ...
                @(~,~) removeSelection(self, newSelectionPanel));
            if isempty(self.hRemoveButtonListeners)
                self.hRemoveButtonListeners = tmp;
            else
                self.hRemoveButtonListeners(end+1) = tmp;
            end
            

            % Move the "Add" panel down one slot.
            self.hPanel.remove(self.hAddPanel)
            placementString = sprintf('xy(2,%d)', 2*numel(self.currentSelections) + 4);
            self.hPanel.add(self.hAddPanel, placementString)
            
            % Add the selection panel to the panel container.
            placementString = sprintf('xy(2,%d)', 2*numel(self.currentSelections) + 2);
            self.hPanel.add(newSelectionPanel.hPanel, placementString)

            addlistener(newSelectionPanel.hSelectionChangeEvent, 'changed', ...
                @(hobj,evt) self.applySelections(hobj, evt) );
            
            self.redraw()
        end
        
        %------------------------------------------------------------------
        function createAddPanel(self)
            assert(~isempty(self.hPanel))
            
            self.hAddPanel = toolpack.component.TSPanel(...
                '5px, f:p:g, 5px',...
                '5px, f:p:g, 5px');

            self.hAddButton = toolpack.component.TSButton(getString(message('images:regionAnalyzer:addButtonLabel')), ...
                toolpack.component.Icon.ADD);
            self.hAddButton.Name = 'btnAddFilter';
            
            self.hAddPanel.add(self.hAddButton, 'xy(2,2)')
            
            self.hPanel.add(self.hAddPanel, 'xy(2,2)')
            
            self.redraw()
            
            addlistener(self.hAddButton, 'ActionPerformed', @(~,~) self.addSelection );
        end
        
        %------------------------------------------------------------------
        function removeSelection(self, affectedObject)
            % Remove a selection from the panel and the list of selections.
            idx = find(self.currentSelections == affectedObject, 1, 'first');
            theSelection = self.currentSelections(idx);
            self.hPanel.remove(theSelection.hPanel)
            self.currentSelections(idx) = [];
            
            % Move the other items up one place.
            numberOfCurrentSelections = numel(self.currentSelections);
            for currentPanel = idx:(numberOfCurrentSelections)
                % Move the item below this to here.
                tmp = self.currentSelections(currentPanel);
                self.hPanel.remove(tmp.hPanel)
                placementString = sprintf('xy(2,%d)', 2*currentPanel+2);
                self.hPanel.add(tmp.hPanel, placementString)
            end
            
            self.hPanel.remove(self.hAddPanel);
            placementString = sprintf('xy(2,%d)', 2*numberOfCurrentSelections+4);
            self.hPanel.add(self.hAddPanel, placementString)
            
            self.redraw()
            
            self.applySelections()
        end
        
        %------------------------------------------------------------------
        function applySelections(self, ~, ~)
            self.filterUpdateEvent.currentSelections = self;
            notify(self.filterUpdateEvent, 'settingsChanged')
        end
        
        %------------------------------------------------------------------
        function redraw(self)
            self.hPopup.Panel.Peer.invalidate();
            self.hPopup.Panel.Peer.revalidate();
            self.hPopup.Panel.Peer.repaint();
            wc = self.hPopup.Peer.getWrappedComponent;
            javaMethodEDT('pack',wc);
        end
    end
end
