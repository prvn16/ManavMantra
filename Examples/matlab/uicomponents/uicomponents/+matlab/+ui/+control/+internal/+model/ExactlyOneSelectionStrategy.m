classdef (Hidden) ExactlyOneSelectionStrategy < matlab.ui.control.internal.model.StateComponentSelectionStrategy
    % ExactlyOneSelectionStrategy
    %
    % Concrete strategy class for component that can have one and only one
    % item selected at a time
    % e.g. DropDown, DiscreteKnob
    
    methods
        function obj = ExactlyOneSelectionStrategy(stateComponentInstance)
            obj = obj@matlab.ui.control.internal.model.StateComponentSelectionStrategy(stateComponentInstance);
        end
    end
    
    methods(Access = {  ?matlab.ui.control.internal.model.StateComponentSelectionStrategy, ...
            ?matlab.ui.control.internal.model.StateComponentValueStrategy, ...
            ?matlab.ui.control.internal.model.AbstractStateComponent})
        
        % Update the selected index after the strategy has been
        % changed to this strategy
        function calibrateSelectedIndexAfterSelectionStrategyChange(obj)
            % The component must have switched from the
            % EditableSelectionStrategy to this one
            
            currentIndex = obj.Component.PrivateSelectedIndex;
            
            isSelectedIndexAString = matlab.ui.control.internal.model.PropertyHandling.isString(currentIndex);
            
            % Selected index only needs to be udpated if it was a user
            % input
            if(isSelectedIndexAString)
                
                if(isempty(obj.Component.PrivateItems))
                    % Items is empty, so no selection
                    index = -1;
                else
                    % pick the first
                    index = 1;
                end
                
                obj.Component.PrivateSelectedIndex = index;
            end
        end
        
        % Updates the selected index as a result of ItemsData being set
        % to some non-empty value (while it was empty before)
        function calibrateSelectedIndexAfterSwitchToDataSpace(obj)
            
            % current selected index
            currentIndex = obj.Component.PrivateSelectedIndex;
            
            if(currentIndex == -1)
                % no selection, no need to change selected index
                return;
            end
            
            % If there is a current selection, only change it if it is no
            % longer valid.
            % Valid indices are those with elements in both Items and
            % ItemsData
            maxValidIndex = min(length(obj.Component.PrivateItems), length(obj.Component.PrivateItemsData));
            if(currentIndex > maxValidIndex)
                % The index is no longer valid, set the selected item to
                % the first item
                obj.Component.PrivateSelectedIndex = 1;
            end
            
        end
        
        % Updates the selected index as a result of Items being changed.
        % This method assumes we were and still are in the text space, i.e.
        % ItemsData was and is still empty
        function calibrateSelectedIndexInTextSpace(obj, currentSelectedText)
            % Re-calibrate selected index such that Value remains an element
            % of Items after Items has changed
            % The current selected text is passed in as input since it is a
            % dependent property, and obj.Value would return the value
            % given the new value of Items
            
            if(isempty(obj.Component.PrivateItems))
                % Items is now empty
                obj.Component.PrivateSelectedIndex = -1;
                return
            end
            
            % is Value an element of the new Items?
            isElementPresent = matlab.ui.control.internal.model.PropertyHandling.isElementPresent(obj.Component.PrivateItems, currentSelectedText);
            
            if(isElementPresent)
                % Value is an element of the new Items,
                % update the selected index accordingly since Value
                % might be at a different index in the new Items
                index = obj.getIndexGivenSelectedText(currentSelectedText);
            else
                % Value is not an element of the new Items,
                % update the selected index to the first element
                index = 1;
            end
            
            obj.Component.PrivateSelectedIndex = index;
        end
        
        % Updates the selected index as a result of Items or ItemsData
        % being changed. This method assumes we were and still are in the
        % data space, i.e. ItemsData was and is still not empty.
        function calibrateSelectedIndexInDataSpace(obj, currentSelectedData)
            % Calibrate selected index such that the currently selected
            % data is the same if it is in the new ItemsData.
            % If not, pick the first element
            % The currently selected data is passed in because as a
            % dependent property, it might no longer be retrievable if
            % ItemsData was changed
            
            if(isempty(obj.Component.PrivateItems))
                % Items is now empty
                obj.Component.PrivateSelectedIndex = -1;
                return
            end
            
            % Find the index of the current Value in new ItemsData
            index = obj.getIndexGivenSelectedData(currentSelectedData);
            
            maxValidIndex = min(length(obj.Component.PrivateItems), length(obj.Component.PrivateItemsData));
            if (isempty(index) || index > maxValidIndex )
                % Either current Value not found in new ItemsData or
                % was found but has no corresponding element in Items.
                % Reset to the first element
                index = 1;
            end
            
            obj.Component.PrivateSelectedIndex = index;
        end
        
        % Validate that Value is an element of Items
        function newValue = validateValuePresentInItems(obj, newValue)
            
            % If newValue is a 1x1 cell, that may be acceptable if the 
            % contents are a valid string. Remove the contents from the
            % cell and allow the newValue to do the subsequent validation.
            if iscell(newValue) && numel(newValue) == 1
                newValue = newValue{1};
            end
            
            % Error checking
            if(isempty(obj.Component.PrivateItems))
                % If Items is empty, the Value should be {}
                isValueEmpty = isempty(newValue) && iscell(newValue);
                
                if(~isValueEmpty)
                    messageObj = message('MATLAB:ui:components:valueNotEmptyCell', ...
                        'Value', 'Items');
                    
                    % MnemonicField is last section of error id
                    mnemonicField = 'valueNotEmpty';
                    
                    % Use string from object
                    messageText = getString(messageObj);
                    
                    % Create and throw exception
                    exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(obj.Component, mnemonicField, messageText);
                    throw(exceptionObject);
                end
                
            else
                % Check whether the new value is in Items
                isValueInItems = matlab.ui.control.internal.model.PropertyHandling.isElementPresent(obj.Component.PrivateItems, newValue);
                
                if(~isValueInItems)
                    messageObj = message('MATLAB:ui:components:elementNotPresent', ...
                        'Value', 'Items');
                    
                    % MnemonicField is last section of error id
                    mnemonicField = 'valueNotInText';
                    
                    % Use string from object
                    messageText = getString(messageObj);
                    
                    % Create and throw exception
                    exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(obj.Component, mnemonicField, messageText);
                    throw(exceptionObject);
                    
                end
            end
        end
        
        % Validate that Value is an element of ItemsData
        function newValueData = validateValuePresentInItemsData(obj, newValueData)
            
            % Error checking
            if(isempty(obj.Component.PrivateItems))
                % If Items is empty, the Value should be {}
                isValueEmpty = isempty(newValueData) && iscell(newValueData);
                
                if(~isValueEmpty)
                    messageObj = message('MATLAB:ui:components:valueNotEmptyCell', ...
                        'Value', 'Items');
                    
                    % MnemonicField is last section of error id
                    mnemonicField = 'valueNotEmpty';
                    
                    % Use string from object
                    messageText = getString(messageObj);
                    
                    % Create and throw exception
                    exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(obj.Component, mnemonicField, messageText);
                    throw(exceptionObject);
                    
                    
                end
                
            else
                % Both Items and ItemsData are not empty
                
                % Value must be an element of ItemsData that has a
                % corresponding element in Items
                maxValidIndex = min(length(obj.Component.PrivateItems), length(obj.Component.PrivateItemsData));
                
                if(iscell(obj.Component.PrivateItemsData))
                    index = find(cellfun(@(x) isequal(x, newValueData), obj.Component.PrivateItemsData));
                else
                    index = find(arrayfun(@(x) isequal(x, newValueData), obj.Component.PrivateItemsData));
                end
                
                if(isempty(index))
                    % The value is not in ItemsData
                    messageObj = message('MATLAB:ui:components:elementNotPresent', ...
                        'Value', 'ItemsData');
                    
                    % MnemonicField is last section of error id
                    mnemonicField = 'valueNotInItemsData';
                    
                    % Use string from object
                    messageText = getString(messageObj);
                    
                    % Create and throw exception
                    exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(obj.Component, mnemonicField, messageText);
                    throw(exceptionObject);
                    
                elseif(index > maxValidIndex)
                    % The value is in ItemsData but that element has no
                    % corresponding element in Items
                    messageObj = message('MATLAB:ui:components:valueDataNotWithinLengthOfText', ...
                        'Value', 'ItemsData', 'Items');
                    
                    % MnemonicField is last section of error id
                    mnemonicField = 'valueNotWithinLengthOfText';
                    
                    % Use string from object
                    messageText = getString(messageObj);
                    
                    % Create and throw exception
                    exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(obj.Component, mnemonicField, messageText);
                    throw(exceptionObject);
                end
                
                
            end
        end
        
        
        % Returns the selected text given the selected index
        function value = getSelectedTextGivenIndex(obj, index)
            
            if(index == -1)
                % no selection
                value = {};
            else
                % text of the selected item
                value = obj.Component.PrivateItems{index};
            end
        end
        
        % Returns the selected data given the selected index
        function value = getSelectedDataGivenIndex(obj, index)
            
            if(index == -1)
                % no selection
                value = {};
            else
                % data of the selected item
                if(iscell(obj.Component.PrivateItemsData))
                    value = obj.Component.PrivateItemsData{index};
                else
                    value = obj.Component.PrivateItemsData(index);
                end
            end
            
        end
        
        function status = isNothingSelected(obj, value)
            % If PrivateItems are empty, nothing can be selected.
            status = isempty(obj.Component.PrivateItems);
        end
        
        % Returns the selected index given the selected text
        function index = getIndexGivenSelectedText(obj, value)
            % GETINDEXGIVENSELECTEDTEXT
            % value is assumed to be a valid value.  If it is not found
            % in the array, index will be empty
            
            % Find the index of the newValue in Text
            % If there are duplicates, the first one is picked
            index = find(cellfun(@(x) isequal(x, value), obj.Component.PrivateItems), 1);
            
        end
        
        % Returns the selected index given the selected data
        function index = getIndexGivenSelectedData(obj, valueData)
            
            % Find the index of valueData in ItemsData
            % If there are duplicates, pick the first one
            if(iscell(obj.Component.PrivateItemsData))
                index = find(cellfun(@(x) isequal(x, valueData), obj.Component.PrivateItemsData), 1);
            else
                index = find(arrayfun(@(x) isequal(x, valueData), obj.Component.PrivateItemsData), 1);
            end
            
        end
        
    end
    
end

