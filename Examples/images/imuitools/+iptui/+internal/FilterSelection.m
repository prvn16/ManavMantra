% Copyright 2014 The MathWorks, Inc.

classdef FilterSelection < handle
    properties
        hPanel
        hCloseRequestEvent
        hSelectionChangeEvent
    end
    
    properties (Access=private, SetObservable=true)
        limitsCache
    end
    
    properties (Access=private)
        hPropCombo
        hOpCombo
        hValueOneSpinner
        hValueTwoSpinner
        hAndLabel
        
        hRemoveButton
        hCloseRequestListener
        
        twoPropModeTF
        
        minLimit  % The theoretical minimum for this filter.
        maxLimit  % The theoretical maximum for this filter.
        prevMinValue  % Filter value before any events. 
        prevMaxValue  % Filter value before any events. 
        relationalOp
        filterProp
        
        filterControlListenersArray
    end
    
    methods       
        %------------------------------------------------------------------
        function self = FilterSelection(limitsCache_)
            %FilterSelection  Create panel for selecting region property
            %limits
            
            tagRoot = iptui.internal.filterTagGenerator();
            
            self.limitsCache = limitsCache_;
            
            % The panel containing all the components...
            self.hPanel = toolpack.component.TSPanel(...
                '5px, 50dlu, 7dlu, 50dlu, 7dlu, 40dlu, 4dlu, f:p:g, 4dlu, 40dlu, 7dlu, f:p, 5px', ...
                '5px, f:p:g, 5px');
            self.hPanel.Name = tagRoot;
            
            % xy(2,2) = Prop combobox
            % xy(4,2) = relationalOp combobox
            % xy(6,2) = Min spinner
            % xy(8,2) = "and"
            % xy(10,2) = Max spinner
            % xy(12,2) = remove button
            
            % Regular buttons...
            [propNames, numForDisplay] = iptui.internal.getPropNames();
            self.hPropCombo = toolpack.component.TSComboBox(propNames(1:numForDisplay));
            self.hPropCombo.Name = [tagRoot '_PropCombo'];
            self.hPanel.add(self.hPropCombo, 'xy(2,2)')
            
            self.hOpCombo = toolpack.component.TSComboBox({getString(message('images:regionAnalyzer:between')), '==', '>', '>=',  '<=', '<'});
            self.hOpCombo.Name = [tagRoot '_OpCombo'];
            self.hPanel.add(self.hOpCombo, 'xy(4,2)')
            
            % In order to make sure spinners can hold floating point numbers,
            % at least one dummy value should not be an integer at time of
            % spinner creation.
            self.hValueOneSpinner = toolpack.component.TSSpinner(0, 1, 0, 0.5);
            self.hValueOneSpinner.Name = [tagRoot '_ValueOneSpinner'];
            self.hPanel.add(self.hValueOneSpinner, 'xy(6,2)')
            
            self.hAndLabel = toolpack.component.TSLabel(getString(message('images:regionAnalyzer:and')));
            
            self.hValueTwoSpinner = toolpack.component.TSSpinner(0, 1, 1, 0.5);
            self.hValueTwoSpinner.Name = [tagRoot '_ValueTwoSpinner'];
            self.enableTwoSpinnerMode()
            
            currentlySelectedProp = self.hPropCombo.SelectedItem;
            limits = self.limitsCache.getPropLimits(currentlySelectedProp);
            self.minLimit = limits(1);
            self.maxLimit = limits(2);
            self.prevMinValue = self.minLimit;
            self.prevMaxValue = self.maxLimit;
            
            self.setSpinnerLimits(limits)
            
            self.filterControlListenersArray = addlistener(self.hPropCombo, ...
                'ActionPerformed', @(hobj,evt) onPropertyComboChange(self, hobj, evt));
            self.filterControlListenersArray(2) = addlistener(self.hOpCombo, ...
                'ActionPerformed', @(hobj,evt) onRelationalOpComboChange(self, hobj, evt));
            self.filterControlListenersArray(3) = addlistener(self.hValueOneSpinner, ...
                'StateChanged', @(hobj,evt) onMinChange(self, hobj, evt));
            self.filterControlListenersArray(4) = addlistener(self.hValueTwoSpinner, ...
                'StateChanged', @(hobj,evt) onMaxChange(self, hobj, evt));
            
            % Remove button...
            self.hRemoveButton = toolpack.component.TSButton('', toolpack.component.Icon.CLOSE);
            self.hRemoveButton.Name = [tagRoot '_RemoveButton'];
            self.hPanel.add(self.hRemoveButton, 'xy(12,2)')

            self.hCloseRequestEvent = iptui.internal.SelectionCloseRequested();
            self.hCloseRequestListener = addlistener(self.hRemoveButton, 'ActionPerformed', @(hobj,evt) onRemovePress(self,hobj,evt) );
            
            self.hSelectionChangeEvent = iptui.internal.SelectionChanged();
            
            % Initialize properties from components' values.
            self.filterProp = self.hPropCombo.SelectedItem;
            self.relationalOp = self.hOpCombo.SelectedItem;
            
            % Add decoration.
            addTitledBorderToPanel(self.hPanel, '')
            
            addlistener(self.limitsCache, 'cacheUpdates', 'PostSet', @(~,~) self.onCacheChange);
        end
    
        %------------------------------------------------------------------
        function [filterFcn, filterString] = getFilterFunction(self)
            if (self.twoPropModeTF)
                limits = [self.prevMinValue self.prevMaxValue];
                limitsString = sprintf('[%.9g, %.9g]', limits(1), limits(2));
            else
                v = self.prevMinValue;
                switch (self.relationalOp)
                case '=='
                    limits = [v, v];
                    limitsString = sprintf('[%.9g, %.9g]', limits(1), limits(2));
                case '<='
                    limits = [-inf, v];
                    limitsString = sprintf('[%.9g, %.9g]', limits(1), limits(2));
                case '>='
                    limits = [v, inf];
                    limitsString = sprintf('[%.9g, %.9g]', limits(1), limits(2));
                case '<'
                    limits = [-inf, v - eps(v)];
                    limitsString = sprintf('[-Inf, %.9g - eps(%.9g)]', limits(2), limits(2));
                case '>'
                    limits = [v + eps(v), inf];
                    limitsString = sprintf('[%.9g + eps(%.9g), Inf]', limits(1), limits(1));
                otherwise
                    assert(false, 'Internal error - Bad relational operator')
                end
            end
            
            filterFcn = @(img) bwpropfilt(img, self.filterProp, limits);
            
            filterString = sprintf('%%s = bwpropfilt(%%s, ''%s'', %s);', ...
                self.filterProp, limitsString);
        end

        %------------------------------------------------------------------
        function TF = hasDefaultValues(self)
            TF = isequal([self.prevMinValue, self.prevMaxValue], ...
                [self.minLimit, self.maxLimit]);
        end
    end
    
    methods (Access=private)
        %------------------------------------------------------------------
        function onRemovePress(self, ~, ~)
            notify(self.hCloseRequestEvent, 'closing')
        end
        
        %------------------------------------------------------------------
        function onPropertyComboChange(self, hobj, ~)
            % Disable other control's listeners to prevent unnecessary
            % recomputations.
            setListenersEnabled(self.filterControlListenersArray, false)
            
            newProp = hobj.SelectedItem;
            self.filterProp = newProp;
            
            limits = self.limitsCache.getPropLimits(newProp);
            self.setSpinnerLimits(limits)
         
            setListenersEnabled(self.filterControlListenersArray, true)
            
            notify(self.hSelectionChangeEvent, 'changed')
        end
        
        %------------------------------------------------------------------
        function setSpinners(self, hSpinner, minValue, maxValue, currentValue)
            setListenersEnabled(self.filterControlListenersArray, false)

            hSpinner.Minimum = minValue;
            hSpinner.Maximum = maxValue;
            hSpinner.Value = currentValue;
            
            if isequal([minValue, maxValue], [0 1])
                step = 0.05;
            else
                step = 1;
            end

            hSpinner.StepSize = step;
            
            setListenersEnabled(self.filterControlListenersArray, true)
        end
        
        %------------------------------------------------------------------
        function setSpinnerLimits(self, limits)

            setListenersEnabled(self.filterControlListenersArray, false)

            low = limits(1);
            high = limits(2);
            
            self.minLimit = low;
            self.maxLimit = high;
            self.prevMinValue = low;
            self.prevMaxValue = high;

            self.setSpinners(self.hValueOneSpinner, low, high, low)
            self.setSpinners(self.hValueTwoSpinner, low, high, high)
            
            setListenersEnabled(self.filterControlListenersArray, true)
        end
        
        %------------------------------------------------------------------
        function updateSpinnerLimits(self, newLimits)
            
            setListenersEnabled(self.filterControlListenersArray, false)

            newLow = newLimits(1);
            newHigh = newLimits(2);
            
            % Preserve "set to min/max" attribute when updating limits.
            minIsPegged = (self.minLimit == self.prevMinValue);
            maxIsPegged = (self.maxLimit == self.prevMaxValue);
            
            if (minIsPegged)
                self.minLimit = newLow;
                self.prevMinValue = newLow;
            else
                self.minLimit = newLow;
                self.prevMinValue = max(newLow, self.prevMinValue);
            end
            
            if (maxIsPegged)
                self.maxLimit = newHigh;
                self.prevMaxValue = newHigh;
            else
                self.maxLimit = newHigh;
                self.prevMaxValue = min(newHigh, self.prevMaxValue);
            end
            
            % Ensure minLimit <= prevMinValue <= prevMaxValue <= maxLimit.
            if (self.prevMinValue < self.minLimit)
                self.prevMinValue = self.minLimit;
            end
            
            if (self.prevMaxValue > self.maxLimit)
                self.prevMaxValue = self.maxLimit;
            end
            
            if (self.prevMinValue > self.prevMaxValue)
                self.prevMinValue = self.prevMaxValue;  % This should never happen.
            end            
            
            % Update the spinners' states.
            self.setSpinners(self.hValueOneSpinner, self.minLimit, self.maxLimit, self.prevMinValue)
            self.setSpinners(self.hValueTwoSpinner, self.minLimit, self.maxLimit, self.prevMaxValue)
            
            setListenersEnabled(self.filterControlListenersArray, true)
        end
        
        %------------------------------------------------------------------
        function onRelationalOpComboChange(self, hobj, ~)
            %disp('onRelationalOpComboChange')
            
            self.relationalOp = hobj.SelectedItem;
            
            if (hobj.SelectedIndex==1 || hobj.SelectedIndex==0) 
                % SelectedIndex 0 is for 'between' operation on Japanese locale
                % win32 machines
                % SelectedIndex 1 is for 'between' operation elsewhere
                % (g1110926)
                self.enableTwoSpinnerMode()
            else %For other relational operations
                self.enableOneSpinnerMode()
            end
            
            self.redraw()
            
            notify(self.hSelectionChangeEvent, 'changed')
        end
        
        %------------------------------------------------------------------
        function onMinChange(self, hobj, ~)
            %disp('onMinChange')
            
            if (hobj.Value == self.prevMinValue)
                return
            elseif (hobj.Value > self.prevMaxValue)
                hobj.Value = self.prevMaxValue;
            end
            
            self.prevMinValue = hobj.Value;
            
            notify(self.hSelectionChangeEvent, 'changed')
        end
        
        %------------------------------------------------------------------
        function onMaxChange(self, hobj, ~)
            %disp('onMaxChange')
            
            if (hobj.Value == self.prevMaxValue)
                return
            elseif (hobj.Value < self.prevMinValue)
                hobj.Value = self.prevMinValue;
            end
            
            self.prevMaxValue = hobj.Value;
            
            notify(self.hSelectionChangeEvent, 'changed')
        end

        %------------------------------------------------------------------
        function enableOneSpinnerMode(self)
            self.hPanel.remove(self.hAndLabel)
            self.hPanel.remove(self.hValueTwoSpinner)
            self.twoPropModeTF = false;
        end
        
        %------------------------------------------------------------------
        function enableTwoSpinnerMode(self)
            self.hPanel.add(self.hAndLabel, 'xy(8,2)')
            self.hPanel.add(self.hValueTwoSpinner, 'xy(10,2)')
            self.twoPropModeTF = true;
        end
        
        %------------------------------------------------------------------
        function redraw(self)
            self.hPanel.Peer.invalidate();
            self.hPanel.Peer.revalidate();
            self.hPanel.Peer.repaint();
        end
        
        %------------------------------------------------------------------
        function onCacheChange(self)
            setListenersEnabled(self.filterControlListenersArray, false)

            myProp = self.hPropCombo.SelectedItem;
            newLimits = self.limitsCache.getPropLimits(myProp);
            
            self.updateSpinnerLimits(newLimits)
            
            setListenersEnabled(self.filterControlListenersArray, true)
        end
    end
end


function addTitledBorderToPanel(panel,title)

titledBorder = javaMethodEDT('createTitledBorder','javax.swing.BorderFactory',title);
javaObjectEDT(titledBorder);
panel.Peer.setBorder(titledBorder);
end


function setListenersEnabled(listenerArray, TF)

for idx = 1:numel(listenerArray)
    listenerArray(idx).Enabled = TF;
end
end
