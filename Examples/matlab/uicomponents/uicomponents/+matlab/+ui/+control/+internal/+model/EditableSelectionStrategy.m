classdef (Hidden) EditableSelectionStrategy <  matlab.ui.control.internal.model.ExactlyOneSelectionStrategy
    % EditableSelectionStrategy
    %
    % Concrete strategy class for component for which the selection is
    % either picked from the list of items, or edited by the user
    % e.g. DropDown with Editable = true
    
    methods
        function obj = EditableSelectionStrategy(stateComponentInstance)
            obj = obj@matlab.ui.control.internal.model.ExactlyOneSelectionStrategy(stateComponentInstance);
        end
    end
    
    methods(Access = {  ?matlab.ui.control.internal.model.StateComponentSelectionStrategy, ...
            ?matlab.ui.control.internal.model.StateComponentValueStrategy, ...
            ?matlab.ui.control.internal.model.AbstractStateComponent})
        
        % Update the selected index after the strategy has been
        % changed to this strategy
        function calibrateSelectedIndexAfterSelectionStrategyChange(~)
            % The component must have switched from the strategy allowing
            % exactly one selection to this one
            % Keep the selection as is.
            
            % no-op
        end
        
        % Updates the selected index as a result of ItemsData being set
        % to some non-empty value (while it was empty before)
        function calibrateSelectedIndexAfterSwitchToDataSpace(obj)
            
            % Determine whether the selected index is a string.
            isSelectedIndexAString = matlab.ui.control.internal.model.PropertyHandling.isString(obj.Component.PrivateSelectedIndex);
            
            % If selected index is a string, it is a user edit. Do not
            % change it.
            if(~isSelectedIndexAString)
                % an item was selected
                calibrateSelectedIndexAfterSwitchToDataSpace@matlab.ui.control.internal.model.ExactlyOneSelectionStrategy(obj);
            end
        end
        
        % Updates the selected index as a result of Items being changed.
        % This method assumes we were and still are in the text space, i.e.
        % ItemsData was and is still empty
        function calibrateSelectedIndexInTextSpace(obj, currentSelectedText)
            
            % Determine whether the selected index is a string.
            isSelectedIndexAString = matlab.ui.control.internal.model.PropertyHandling.isString(obj.Component.PrivateSelectedIndex);
            
            % If selected index is a string, it is a user edit. Do not
            % change it
            if(~isSelectedIndexAString)
                % an item was selected
                calibrateSelectedIndexInTextSpace@matlab.ui.control.internal.model.ExactlyOneSelectionStrategy(obj, currentSelectedText);
            end
        end
        
        
        % Updates the selected index as a result of Items or ItemsData
        % being changed. This method assumes we were and still are in the
        % data space, i.e. ItemsData was and is still not empty.
        function calibrateSelectedIndexInDataSpace(obj, currentSelectedData)
            
            % Determine whether the selected index is a string.
            isSelectedIndexAString = matlab.ui.control.internal.model.PropertyHandling.isString(obj.Component.PrivateSelectedIndex);
            
            % If selected index is a string, it is a user edit. Do not
            % change it
            if(~isSelectedIndexAString)
                % an item was selected
                calibrateSelectedIndexInDataSpace@matlab.ui.control.internal.model.ExactlyOneSelectionStrategy(obj, currentSelectedData);
            end
        end
        
        
        % Validate that Value is an element of Items
        function newValue = validateValuePresentInItems(obj, newValue)
            
            % Determine whether value is a string.
            isValueAString = matlab.ui.control.internal.model.PropertyHandling.isString(newValue);
            
            % If Value is a string, it is valid. It corresponds to a user
            % edit.
            if(~isValueAString)
                % Value is not a user edit, it must be a selection
                
                newValue = validateValuePresentInItems@matlab.ui.control.internal.model.ExactlyOneSelectionStrategy(obj, newValue);
            end
            
        end
        
        % Validate that Value is an element of ItemsData
        function newValueData = validateValuePresentInItemsData(obj, newValueData)
            
            % Determine whether value is a string.
            isValueAString = matlab.ui.control.internal.model.PropertyHandling.isString(newValueData);
            
            % If Value is a string, it is valid. It corresponds to a user
            % edit.
            if(~isValueAString)
                % Value is not a user edit, it must be a selection
                
                newValueData = validateValuePresentInItemsData@matlab.ui.control.internal.model.ExactlyOneSelectionStrategy(obj, newValueData);
            end
        end
        
        
        
        % Returns the selected text given the selected index
        function value = getSelectedTextGivenIndex(obj, index)
            
            isSelectedIndexAString = matlab.ui.control.internal.model.PropertyHandling.isString(index);
            
            if(isSelectedIndexAString)
                % user input
                value = index;
            else
                % an item is selected
                value = getSelectedTextGivenIndex@matlab.ui.control.internal.model.ExactlyOneSelectionStrategy(obj, index);
            end
            
        end
        
        % Returns the selected data given the selected index
        function value = getSelectedDataGivenIndex(obj, index)
            
            isSelectedIndexAString = matlab.ui.control.internal.model.PropertyHandling.isString(index);
            
            if(isSelectedIndexAString)
                % user input
                value = index;
            else
                % an item is selected
                value = getSelectedDataGivenIndex@matlab.ui.control.internal.model.ExactlyOneSelectionStrategy(obj, index);
            end
        end
        
        function status = isNothingSelected(obj, value)
            % The value is almost always something valid because validation
            % on the input has been done before this code is reached.
            
            % The only scenario where 'nothing' is selected is when the
            % Items are empty, the Value has been set to some user edited
            % value, then the 'Value' is programmatically reset to {}.
            % This is a rare edge case.
            status = isempty(obj.Component.Items) && isempty(value) && iscell(value);
        end
        
        % Returns the selected index given the selected text
        function index = getIndexGivenSelectedText(obj, value)
            % GETINDEXGIVENSELECTEDTEXT
            % value is assumed to be a valid value.  If it is not found
            % in the array, index will be empty
            
            index = getIndexGivenSelectedText@matlab.ui.control.internal.model.ExactlyOneSelectionStrategy(obj, value);
            
            % Determine whether value is a string.
            isValueAString = matlab.ui.control.internal.model.PropertyHandling.isString(value);
            
            if(isempty(index) && isValueAString)
                % The value was not found in Items, or Items was empty
                % it is an edit
                % set the selected index to the custom string
                % In the editable strategy, if Items is empty, value is not
                % necessarily empty, it can be a user edit. Set index to
                % value if that's the case.
                index = value;
            end
            
        end
        
        % Returns the selected index given the selected data
        function index = getIndexGivenSelectedData(obj, value)
            
            index = getIndexGivenSelectedData@matlab.ui.control.internal.model.ExactlyOneSelectionStrategy(obj, value);
            
            % Whether  value is an element of Items
            isInItems = matlab.ui.control.internal.model.PropertyHandling.isElementPresent(obj.Component.PrivateItems, value);
            
            % Whether value is a string.
            isValueAString = matlab.ui.control.internal.model.PropertyHandling.isString(value);
            
            if(isInItems)
                % User entered a string that matches one of the element in
                % Items. Consider this a selection. We convert the user
                % entered string to the data corresponding to the 'selected
                % item'
                index = obj.getIndexGivenSelectedText(value);
                
            elseif(isempty(index) && isValueAString)               
                % User entered a custom string that is not in ItemsData or Items
                % It is an edit, set the index to the custom string
                % In the editable strategy, if Items is empty, value is not
                % necessarily empty, it can be a user edit. Set index
                % to value if that's the case.
                
                index = value;
            end
        end
    end
    
end

