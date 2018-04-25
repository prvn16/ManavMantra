classdef (Hidden) ZeroToManySelectionStrategy < matlab.ui.control.internal.model.StateComponentSelectionStrategy
    % ZeroToManySelectionStrategy
    %
    % Selection strategy for state components where zero or many items
    % can be selected at a time
    % e.g. Listbox in multi selection mode
    
    methods
        function obj = ZeroToManySelectionStrategy(stateComponentInstance)
            obj = obj@matlab.ui.control.internal.model.StateComponentSelectionStrategy(stateComponentInstance);
        end
    end
    
    methods(Access = {  ?matlab.ui.control.internal.model.StateComponentSelectionStrategy, ...
            ?matlab.ui.control.internal.model.StateComponentValueStrategy, ...
            ?matlab.ui.control.internal.model.AbstractStateComponent})
        
        % Update the selected index after the strategy has been
        % changed to this strategy
        function calibrateSelectedIndexAfterSelectionStrategyChange(~)
            % The component must have switched from the strategy allowing
            % zero to one selection to this one.
            % Any selection in the zero to one strategy is still valid in
            % this one, so no need to change selected index
            
            % no-op
        end
        
        % Updates the selected index as a result of ItemsData being set
        % to some non-empty value (while it was empty before)
        function calibrateSelectedIndexAfterSwitchToDataSpace(obj)
            
            % current selected index
            currentIndex = obj.Component.PrivateSelectedIndex;
            
            % currentIndex can be an array
            if(length(currentIndex) == 1 && currentIndex == -1)
                % no selection, no need to change selected index
                return;
            end
            
            % If there is a current selection, only change it if it is no
            % longer valid.
            % Valid indices are those with elements in both Items and
            % ItemsData
            maxValidIndex = min(length(obj.Component.PrivateItems), length(obj.Component.PrivateItemsData));
            if(any(currentIndex <= maxValidIndex))
                index = currentIndex(currentIndex <= maxValidIndex);
            else
                index = 1;
            end
            obj.Component.PrivateSelectedIndex = index;
            
        end
        
        % Updates the selected index as a result of Items being changed.
        % This method assumes we were and still are in the text space, i.e.
        % ItemsData was and is still empty
        function calibrateSelectedIndexInTextSpace(obj, currentSelectedText)
            
            % current selected index
            currentIndex = obj.Component.PrivateSelectedIndex;
            
            % currentIndex can be an array
            if((length(currentIndex) == 1 && currentIndex == -1) || ...
                    isempty(obj.Component.PrivateItems))
                % Either:
                % - there was previously no selection
                % - or, items is now empty
                % selected index is -1
                obj.Component.PrivateSelectedIndex = -1;
                return
            end
            
            % Check if Value items are present in Items
            areElementPresent = cellfun(@(x) matlab.ui.control.internal.model.PropertyHandling.isElementPresent(obj.Component.PrivateItems, x), currentSelectedText);
            
            if(any(areElementPresent))
                % keep the subset of indices representing the value still
                % present in Items
                index = obj.getIndexGivenSelectedText(currentSelectedText);
            else
                % pick the first element in Items
                index = 1;
            end
            
            obj.Component.PrivateSelectedIndex = index;
        end
        
        % Updates the selected index as a result of Items or ItemsData
        % being changed. This method assumes we were and still are in the
        % data space, i.e. ItemsData was and is still not empty.
        function calibrateSelectedIndexInDataSpace(obj, currentSelectedData)
            
            % current selected index
            currentIndex = obj.Component.PrivateSelectedIndex;
            
            % currentIndex can be an array
            if((length(currentIndex) == 1 && currentIndex == -1) || ...
                    isempty(obj.Component.PrivateItems))
                % Either:
                % - there was previously no selection
                % - or, items is now empty
                % selected index is -1
                obj.Component.PrivateSelectedIndex = -1;
                return
            end
            
            % Find the indices of the current selected data in new ItemsData
            index = obj.getIndexGivenSelectedData(currentSelectedData);
            
            maxValidIndex = min(length(obj.Component.PrivateItems), length(obj.Component.PrivateItemsData));
            if(isempty(index) || all(index > maxValidIndex))
                % Either the current selected data are not found in the new
                % ItemsData or they no longer have corresponding
                % elements in Items
                index = 1;
            else
                % Keep the elements that have corresponding elements in
                % Items
                index = index(index <= maxValidIndex);
            end
            
            obj.Component.PrivateSelectedIndex = index;
        end
        
        % Validate that Value is an element of Items
        function newValue = validateValuePresentInItems(obj, newValue)
            
            % Is newValueData the empty cell {}?            
            if(isempty(newValue)  && isa(newValue, 'cell'))
                % {} is always valid, it indicates no selection
                return;
            end
            
            % In multiselect mode, Value must be a cell
            if ~iscell(newValue)
               newValue = {newValue};
               
            end
            
            % Error checking
            if isempty(obj.Component.PrivateItems)
                % If newValue was {}, it was already handled above.  Any
                % other value is invalid if Items is empty
                % If Items is empty in multiselection mode, the Value
                % must be {}
                
                messageObj = message('MATLAB:ui:components:valueNotEmptyCell', ...
                    'Value', 'Items');
                
                % MnemonicField is last section of error id
                mnemonicField = 'valueNotEmptyCell';
                
                % Use string from object
                messageText = getString(messageObj);
                
                % Create and throw exception
                exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(obj.Component, mnemonicField, messageText);
                throw(exceptionObject);
                
            else
                % Both newValue and Items are not empty
                % Verify that all the elements in newValue are in Items
                
                areElementPresent = cellfun(@(x) matlab.ui.control.internal.model.PropertyHandling.isElementPresent(obj.Component.PrivateItems, x), newValue);
                
                if(~all(areElementPresent) )
                    messageObj = message('MATLAB:ui:components:valueNotCellInText', ...
                        'Value', 'Items');
                    
                    % MnemonicField is last section of error id
                    mnemonicField = 'valueNotCellInText';
                    
                    % Use string from object
                    messageText = getString(messageObj);
                    
                    % Create and throw exception
                    exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(obj.Component, mnemonicField, messageText);
                    throw(exceptionObject);
                end
                
                % All the elements are present in Items (are thus all elements
                % are strings), or newValue is the empty cell {}.
                % Verify that each element in newValue appears at max as
                % many times that the string appears in Items
                [isValid, ~] = matlab.ui.control.internal.model.PropertyHandling.validateSubset(obj.Component.PrivateItems, newValue);
                if(~isValid)
                    messageObj = message('MATLAB:ui:components:notASubset', ...
                        'Value', 'Items', 'Items', 'ItemsData');
                    
                    % MnemonicField is last section of error id
                    mnemonicField = 'notASubset';
                    
                    % Use string from object
                    messageText = getString(messageObj);
                    
                    % Create and throw exception
                    exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(obj.Component, mnemonicField, messageText);
                    throw(exceptionObject);
                end
                
                
            end
        end
        
        function newValueData = validateValuePresentInItemsData(obj, newValueData)
            % Validate that Value is a subset of ItemsData
            % ItemsData can be either an array or cell array
            
            % Is newValueData the empty cell {}?
            isValueEmpty = isempty(newValueData) && isa(newValueData, 'cell');
            
            if(isValueEmpty)
                % {} is always valid, it indicates no selection
                return;
            end
            
            if(isempty(obj.Component.PrivateItems) && ~isValueEmpty)
                % If Text is empty in multiselection mode, the Value
                % must be {}
                messageObj = message('MATLAB:ui:components:valueNotEmptyCell', ...
                    'Value', 'Items');
                
                % MnemonicField is last section of error id
                mnemonicField = 'valueNotEmptyCell';
                
                % Use string from object
                messageText = getString(messageObj);
                
                % Create and throw exception
                exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(obj.Component, mnemonicField, messageText);
                throw(exceptionObject);
            else
                
                % Items are not empty and newValue is not {}
                
                % Value must be elements of ItemsData that have
                % corresponding elements in Items
                
                % Store a local copy so we can modify it
                itemsData = obj.Component.PrivateItemsData;
                
                % Do validation with the part of ItemsData that has corresponding
                % elements in Items
                if(length(obj.Component.PrivateItemsData) > length(obj.Component.PrivateItems))
                    % If there are more elements in ItemsData than in Items,
                    % only keep the elements up to length of Items
                    itemsData = itemsData(1:length(obj.Component.PrivateItems));
                end
                
                % Value must be a cell with elements in (truncated)
                % ItemsData
                if(iscell(obj.Component.PrivateItemsData))
                    areElementsPresent = cellfun(@(x) matlab.ui.control.internal.model.PropertyHandling.isElementPresent(itemsData, x), newValueData);
                else
                    areElementsPresent = arrayfun(@(x) matlab.ui.control.internal.model.PropertyHandling.isElementPresent(itemsData, x), newValueData);
                end
                
                if(~all(areElementsPresent))
                    messageObj = message('MATLAB:ui:components:notASubset', ...
                        'Value', 'ItemsData', 'ItemsData', 'Items');
                    
                    % MnemonicField is last section of error id
                    mnemonicField = 'notASubset';
                    
                    % Use string from object
                    messageText = getString(messageObj);
                    
                    % Create and throw exception
                    exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(obj.Component, mnemonicField, messageText);
                    throw(exceptionObject);
                end
                
                % All the elements are present in ItemsData
                % Verify that each element in newValueData appears at max as
                % many times as it appears in TextData
                [isValid, ~] = matlab.ui.control.internal.model.PropertyHandling.validateSubset(itemsData, newValueData);
                if(~isValid)
                    messageObj = message('MATLAB:ui:components:notASubset', ...
                        'Value', 'ItemsData',  'ItemsData', 'Items');
                    
                    % MnemonicField is last section of error id
                    mnemonicField = 'notASubset';
                    
                    % Use string from object
                    messageText = getString(messageObj);
                    
                    % Create and throw exception
                    exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(obj.Component, mnemonicField, messageText);
                    throw(exceptionObject);
                end
            end
            
        end
        
        function value = getSelectedTextGivenIndex(obj, index)
            % Returns the selected text given the index array
            
            if(index == -1)
                % no selection
                value = {};
            else
                % text of the selected item
                value = obj.Component.PrivateItems(index);
            end
        end
        
        function value = getSelectedDataGivenIndex(obj, index)
            % Returns the selected data given the index array
            
            if(index == -1)
                % no selection
                value = {};
            else
                                
               % ItemsData is an array
               value = obj.Component.PrivateItemsData(index);               
            end
        end
        
        function status = isNothingSelected(obj, value)
            % There is only no selection if
            % 1: the Value is an empty cell
            % 2: The Items are empty
            status = (isempty(value) && isa(value, 'cell')) || isempty(obj.Component.PrivateItems);
        end
        
        function index = getIndexGivenSelectedText(obj, value)
            % Returns the index in text of the element value
            
            index = [];
            
            % Copies of text to manage duplicates
            remainingText = obj.Component.PrivateItems;
            % Keep track of the real indices in text
            remainingIndices = 1:length(obj.Component.PrivateItems);
            
            for k = 1:length(value)
                thisValue = value{k};
                
                % Find the corresponding text
                ind = find(cellfun(@(x) isequal(x, thisValue), remainingText), 1);
                
                if(~isempty(ind))
                    % this value was found
                    
                    % get the real index from remainingIndices since we are
                    % removing elements from text
                    index(end+1) = remainingIndices(ind);
                    
                    % Remove the elements from remainingText so that
                    % if there are duplicates, the next ones are picked
                    remainingText(ind) = [];
                    % keep remainingIndices in sync
                    remainingIndices(ind) = [];
                end
            end
            
        end
        
        function index = getIndexGivenSelectedData(obj, valueData)
            % Returns the index in ItemsData of the element valuedata
            
            % Update Value to the corresponding text
            index = [];
            
            % Copies of TextData to manage duplicates
            remainingTextData = obj.Component.PrivateItemsData;
            % Keep track of the real indices in textdata
            remainingIndices = 1:length(obj.Component.PrivateItemsData);
            
            for k = 1:length(valueData)
                if(iscell(valueData))
                    thisValueData = valueData{k};
                else
                    thisValueData = valueData(k);
                end
                
                % Find the corresponding text
                if(iscell(remainingTextData))
                    ind = find(cellfun(@(x) isequal(x, thisValueData), remainingTextData), 1);
                else
                    ind = find(arrayfun(@(x) isequal(x, thisValueData), remainingTextData), 1);
                end
                
                if(~isempty(ind))
                    % get the real index from remainingIndices since we are
                    % removing elements from text
                    index(end+1) = remainingIndices(ind);
                    
                    % Remove the elements from remainingText so that
                    % if there are duplicates, the next ones are picked
                    remainingTextData(ind) = [];
                    % keep remainingIndices in sync
                    remainingIndices(ind) = [];
                end
            end
        end
    end
end

