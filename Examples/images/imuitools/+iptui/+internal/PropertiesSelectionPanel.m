% Copyright 2014 The MathWorks, Inc.

classdef PropertiesSelectionPanel < handle
    
    properties
        popup
    end
    
    properties (SetObservable=true)
        SelectedIndices = [];
    end
    
    properties (Access=private)
        checkboxListeners = {};
        checkboxes = {};
        propNames
    end
    
    properties (Dependent=true)
        SelectedValues
    end
    
    methods
        
        %------------------------------------------------------------------
        function self = PropertiesSelectionPanel(propNamesCell)
            
            self.propNames = propNamesCell;
            numProps = numel(propNamesCell);
            
            % Layout parent panel, allocating a row for each property plus
            % a pair of header and footer spacers.
            rowSpec = ['5px, ' repmat('f:p:g, 5dlu, ', [1 numProps]), '5px'];
            panel = toolpack.component.TSPanel(...
                '5px,p:g,5px',...
                rowSpec);
            
            % Put the panel on a tear-off popup.
            self.popup = toolpack.component.TSTearOffPopup(panel);
            
            % Add the checkbox components.
            for idx = 1:numProps
                theProp = propNamesCell{idx};
                hCheckbox = toolpack.component.TSCheckBox(theProp);
                hCheckbox.Name = ['chk' theProp];
                layoutSpec = sprintf('xy(2,%d)', 2*idx);
                panel.add(hCheckbox, layoutSpec)
                
                self.checkboxes{idx} = hCheckbox;
                self.checkboxListeners{idx} = addlistener(hCheckbox, ...
                    'ItemStateChanged', ...
                    @(hObj,evt) updateSelectedIndices(self, idx, hObj, evt) );
            end
        end
        
        %------------------------------------------------------------------
        function names = get.SelectedValues(self)
            if isempty(self.SelectedIndices)
                names = {};
            else
                names = self.propNames(self.SelectedIndices);
            end
        end
        
        %------------------------------------------------------------------
        function set.SelectedValues(self, values)
            
            [~, ~, self.SelectedIndices] = intersect(values, self.propNames);

            for idx = 1:numel(self.propNames)
                hCheckbox = self.checkboxes{idx};

                if ~isempty(find(idx == self.SelectedIndices, 1))
                    hCheckbox.Selected = true;
                else
                    hCheckbox.Selected = false;
                end
            end
        end
        
    end
    
    methods (Access=private)
        
        function updateSelectedIndices(self, idx, ~, evt)
            % Add or remove (de)selected items from the list.
            checked = evt.Source.Selected;
            if (checked)
                self.SelectedIndices = unique([self.SelectedIndices; idx]); % Add and sort.
            else
                self.SelectedIndices = setdiff(self.SelectedIndices, idx);
            end
        end
        
    end
end