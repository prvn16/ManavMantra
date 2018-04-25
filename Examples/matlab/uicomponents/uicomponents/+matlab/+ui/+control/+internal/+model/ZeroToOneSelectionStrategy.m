classdef (Hidden) ZeroToOneSelectionStrategy < matlab.ui.control.internal.model.ExactlyOneSelectionStrategy
    % ZeroToOneSelectionStrategy
    % 
    % Selection strategy for state components where zero or one item
    % can be selected at a time
    % e.g. Listbox in single selection mode
        
    methods
        function obj = ZeroToOneSelectionStrategy(stateComponentInstance)
            obj = obj@matlab.ui.control.internal.model.ExactlyOneSelectionStrategy(stateComponentInstance);
        end
    end
    
    methods(Access = {  ?matlab.ui.control.internal.model.StateComponentSelectionStrategy, ...
                        ?matlab.ui.control.internal.model.StateComponentValueStrategy, ...
                        ?matlab.ui.control.internal.model.AbstractStateComponent})
        
        % Update the selected index after the strategy has been
        % changed to this strategy
        function calibrateSelectedIndexAfterSelectionStrategyChange(obj)
            % The component must have switched from the strategy allowing zero
            % to multiple selection to this strategy. 
            % Thus, SelectedIndex is currently an array or -1 (no selection)            
            
            % current selected index
            currentIndex = obj.Component.PrivateSelectedIndex;
            
            if(length(currentIndex) > 1)                
                % pick the first one
                obj.Component.PrivateSelectedIndex = currentIndex(1);
            end
        end
        
        % Updates the selected index as a result of Items being changed.
        % This method assumes we were and still are in the text space, i.e.
        % ItemsData was and is still empty
        function calibrateSelectedIndexInTextSpace(obj, currentSelectedText)
            % In this strategy, it is ok to have no selection 
            % so we check for that case before deferring to super
            % g1293460
            
            % current selected index
            currentIndex = obj.Component.PrivateSelectedIndex;
            
            if(currentIndex == -1)
                % There was previously no selection
                % In this strategy, it is ok to have no selection so 
                % selected index remains -1
                obj.Component.PrivateSelectedIndex = -1;
                return
            end
            
            calibrateSelectedIndexInTextSpace@matlab.ui.control.internal.model.ExactlyOneSelectionStrategy(obj, currentSelectedText);                        
        end
        
        % Updates the selected index as a result of Items or ItemsData
        % being changed. This method assumes we were and still are in the
        % data space, i.e. ItemsData was and is still not empty.
        function calibrateSelectedIndexInDataSpace(obj, currentSelectedData)
            % In this strategy, it is ok to have no selectino
            % so we check for that case before deferring to super
            % g1293460
            
            % current selected index
            currentIndex = obj.Component.PrivateSelectedIndex;
            
            if(currentIndex == -1)
                % There was previously no selection
                % In this strategy, it is ok to have no selection so 
                % selected index remains -1
                obj.Component.PrivateSelectedIndex = -1;
                return
            end
            
            calibrateSelectedIndexInDataSpace@matlab.ui.control.internal.model.ExactlyOneSelectionStrategy(obj, currentSelectedData);
            
        end
        
        % Validate that Value is an element of Items
        function newValue = validateValuePresentInItems(obj, newValue)
            
            if(isempty(newValue) && iscell(newValue))
                % {} is always valid, it indicates no selection
                return;
            end
            
                
            try
                
                % value is not empty, it must be a selection
                newValue = validateValuePresentInItems@matlab.ui.control.internal.model.ExactlyOneSelectionStrategy(obj, newValue);
            catch me
                
                if endsWith(me.identifier, 'valueNotInText') &&...
                    ~(ischar(newValue) || isscalar(newValue) && isstring(newValue))
                    % For element is not present error, do one layer of
                    % analysis to send a descriptive message.  It is
                    % assumed this component has a Multiselect property...
                    % Listbox is currently the only component using this
                    
                    messageObj = message('MATLAB:ui:components:scalarItemInSingleSelect', ...
                        'Value');
                    
                    % MnemonicField is last section of error id
                    mnemonicField = 'scalarItemInSingleSelect';
            
                    % Use string from object
                    messageText = getString(messageObj);
                    
                    % Create and throw exception
                    exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(obj.Component, mnemonicField, messageText);
                    throw(exceptionObject);
                    
                else
                    throw(me)
                end
            end                    
        end
        
        function newValueData = validateValuePresentInItemsData(obj, newValueData)
            % Validate that Value is an element of ItemsData in single selection mode
            
            isValueEmpty = isempty(newValueData) && isa(newValueData, 'cell');
            
            % If value is empty, it is valid, it indicates no selection
            if(~isValueEmpty)
                % Value is not empty, it must be an element of ItemsData
                newValueData = validateValuePresentInItemsData@matlab.ui.control.internal.model.ExactlyOneSelectionStrategy(obj, newValueData);
            end
            
        end
        
        function status = isNothingSelected(obj, value)
            % Since value is either a member of the drop down or provided
            % by the user as an edit, there is never a situation where
            % there is no selection.
            status = (isempty(value) && isa(value, 'cell') || ...
                isNothingSelected@matlab.ui.control.internal.model.ExactlyOneSelectionStrategy(obj, value));
        end
    end    
end

