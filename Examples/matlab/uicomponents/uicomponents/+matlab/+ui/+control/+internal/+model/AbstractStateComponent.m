classdef (Hidden) AbstractStateComponent < ...
        matlab.ui.control.internal.model.ComponentModel& ...
        matlab.ui.control.internal.model.mixin.EnableableComponent & ...
        matlab.ui.control.internal.model.mixin.VisibleComponent
    
    % Copyright 2011-2015 The MathWorks, Inc.
    
    properties(Dependent)
        Value
        
        Items
        
        ItemsData = [];
    end
    
    properties(NonCopyable, Dependent)
        ValueChangedFcn@matlab.graphics.datatype.Callback = [];
    end
    
    properties(Dependent, ...
            Access = {
            ?matlab.ui.control.internal.model.AbstractStateComponent, ...
            ?appdesservices.internal.interfaces.controller.AbstractController,...
            ?appdesservices.internal.interfaces.controller.AbstractControllerMixin, ...
            } ...
        )
        
        % SelectedIndex:
        % - 1-based index of the selected item among the items in Items
        % - selected index of -1 indicates no selection
        % 
        % For EditableDropDown:         
        % - selected index = the user string if it is a user edit
        % - otherwise, same as general case
        %
        % For ListBox:
        % - for multiple selection, SelectedIndex is an array of 1-based
        % indices. -1 indicates no selection
        % - for single selection, same as general case
        %
        % Set default to no selection since Items is initially empty
        %
        %
        SelectedIndex = -1; 
    end
    
    events(NotifyAccess = {?matlab.ui.control.internal.controller.ComponentController})
        ValueChanged
    end
    
    properties(Access = {...
            ?matlab.ui.control.internal.model.AbstractStateComponent, ...
            ?matlab.ui.control.internal.model.StateComponentSelectionStrategy,...
            ?matlab.ui.control.internal.model.StateComponentValueStrategy,...
            ?appdesservices.internal.interfaces.controller.AbstractController})
        % Internal properties
        %
        % These exist to provide:
        % - fine grained control to each properties
        % - circumvent the setter, beacuse sometimes multiple properties
        %   need to be set at once, and the object will be in an
        %   inconsistent state between properties being set
 
        PrivateItems;
        
        PrivateItemsData = []; 
        
        PrivateSelectedIndex = -1;        
    end        
    
    properties(NonCopyable, Access = {...
            ?matlab.ui.control.internal.model.AbstractStateComponent, ...
            ?matlab.ui.control.internal.model.StateComponentSelectionStrategy,...
            ?matlab.ui.control.internal.model.StateComponentValueStrategy,...
            ?appdesservices.internal.interfaces.controller.AbstractController})
        
        
        PrivateValueChangedFcn@matlab.graphics.datatype.Callback = [];
             
    end
    
    properties(Access = 'protected')
        % 1x2 array indicating the min and max number of items allowed
        % i.e. enforces how big Items can be
        TextSizeConstraints; 
        
        % Value strategy handles the two modes for Value, i.e.
        % - Value is an element of Items if ItemsData is empty
        % - Value is an element if Items if ItemsData is not empty
        %        
        % Default generated in constructor
        ValueStrategy;
    end
    
    properties(Access = {...
            ?matlab.ui.control.internal.model.AbstractStateComponent, ...
            ?matlab.ui.control.internal.model.StateComponentValueStrategy})
        
        % Selection strategy handles the different types of selection,
        % e.g. exactly one item can be selected for drop down
        % e.g. zero to many elements can be selected for listbox in
        % multiselection mode
        %
        % SelectionStrategy is one of the strategy, subclass of 
        % matlab.ui.control.internal.model.StateComponentSelectionStrategy
        %
        % Initialized in the concrete classes
        SelectionStrategy;        
    end
    
    % ---------------------------------------------------------------------
    % Constructor
    % ---------------------------------------------------------------------
    methods        
        function obj = AbstractStateComponent(textSizeConstraints)
            
            narginchk(1,1);
            
            
            % Initialize the Value strategy
            obj.updateValueStrategy();
            
            % Store size constraints
            obj.TextSizeConstraints = textSizeConstraints;
            
            % Wire callbacks
            obj.attachCallbackToEvent('ValueChanged', 'PrivateValueChangedFcn');	             
        end
    end
    
    % ---------------------------------------------------------------------
    % Property Getters / Setters
    % ---------------------------------------------------------------------
    methods
        function set.Value(obj, newValue)  
            
            % validation 
            value = obj.ValueStrategy.validateValue(newValue);
            
            % Update the selected index property
            obj.PrivateSelectedIndex = obj.ValueStrategy.getIndexGivenValue(value);
                  
            % Update the view
            obj.markPropertiesDirty({'SelectedIndex', 'Value'});
            
        end
        
        function value = get.Value(obj)            
            index = obj.SelectedIndex;
            
            value = obj.getValueGivenIndex(index);
        end
        
        
        function set.Items(obj, newText)
                        
            % Error Checking
            try
                newText = matlab.ui.control.internal.model.PropertyHandling.processCellArrayOfStrings(...
                    obj,...
                    'Items', ...
                    newText, ...
                    obj.TextSizeConstraints);
            catch mException
                % Rethrow the same message w/ a specific ID    
                % MnemonicField is last section of error id
                mnemonicField = 'invalidText';
                
                % Use string from object
                messageText = mException.message;
                
                % Create and throw exception
                exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(obj, mnemonicField, messageText);
                throw(exceptionObject);
                
            end
            
            % Store the current value before changing items
            oldValue = obj.Value;
            oldSelectedIndex = obj.SelectedIndex;
            
            % Property Setting
            obj.PrivateItems = newText;
            
            % Update the selected index 
            obj.ValueStrategy.calibrateSelectedIndex(oldValue);
            
            dirtyProperties = {'Items'};
            
            % Update additional properties only if necessary
            if ~isequal(class(oldValue), class(obj.Value)) || ~isequaln(oldValue, obj.Value)
                dirtyProperties(end+1) = {'Value'};
            end
            if ~isequal(oldSelectedIndex, obj.SelectedIndex)
                dirtyProperties(end+1) = {'SelectedIndex'};
            end
            
            % Update the view
            obj.markPropertiesDirty(dirtyProperties);
        end
        
        function value = get.Items(obj)
            value = obj.PrivateItems;
        end
        
        function set.ItemsData(obj, newItemsData)
        
            % Error Checking
            try
                newItemsData =  matlab.ui.control.internal.model.PropertyHandling.processItemsDataInput(...
                    obj,...
                    'ItemsData',...
                    newItemsData,...
                    obj.TextSizeConstraints);
            catch mException
                % Rethrow the same message w/ a specific ID
                % MnemonicField is last section of error id
                mnemonicField = 'invalidItemsData';
                
                % Use string from object
                messageText = mException.message;
                
                % Create and throw exception
                exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(obj, mnemonicField, messageText);
                throw(exceptionObject);
                
            end
            
            % Store the current ItemsData and Value before changing
            % ItemsData
            oldValue = obj.Value;
            oldItemsData = obj.ItemsData;
            oldSelectedIndex = obj.SelectedIndex;
            
            % Property Setting
            obj.PrivateItemsData = newItemsData;
            
            if(xor(isempty(oldItemsData), isempty(newItemsData)))
                % ItemsData changed from empty to non-empty or vice-versa
                % Update the value strategy
                obj.updateValueStrategy();
                
                obj.ValueStrategy.calibrateSelectedIndexAfterValueStrategyChange();
            else
                % There was no change in Value strategy.
                % ItemsData was not empty before and is still not empty.
                % Update the selected index
                obj.ValueStrategy.calibrateSelectedIndex(oldValue);
            end
            
            dirtyProperties = {'ItemsData'};
            
            % Update additional properties only if necessary
            if ~isequal(class(oldValue), class(obj.Value)) || ~isequaln(oldValue, obj.Value)                
                dirtyProperties(end+1) = {'Value'};
            end
            if ~isequal(oldSelectedIndex, obj.SelectedIndex)
                dirtyProperties(end+1) = {'SelectedIndex'};
            end
            
            % Update the view
            obj.markPropertiesDirty(dirtyProperties);
        end
        
        function value = get.ItemsData(obj)
            value = obj.PrivateItemsData;
        end
        
        function set.SelectedIndex(obj, newValue)
            % Property Setting
            obj.PrivateSelectedIndex = newValue;
            obj.markPropertiesDirty({'SelectedIndex', 'Value'});
        end
        
        function value = get.SelectedIndex(obj)
            value = obj.PrivateSelectedIndex;
        end
        
        
        function set.ValueChangedFcn(obj, newValueChangedFcn)
            % Property Setting
            obj.PrivateValueChangedFcn = newValueChangedFcn;
            obj.markPropertiesDirty({'ValueChangedFcn'});
        end
        
        function value = get.ValueChangedFcn(obj)
            value = obj.PrivateValueChangedFcn;
        end
                
    end
    
    methods(Access = 'private')
        
        % Update the Value strategy
        function updateValueStrategy(obj)
            
            % explicitly delete the current value strategy since it has a
            % handle to this object
            delete(obj.ValueStrategy);
            
            if(isempty(obj.PrivateItemsData))
                obj.ValueStrategy = matlab.ui.control.internal.model.SelectedTextValueStrategy(obj);                
            else
                obj.ValueStrategy = matlab.ui.control.internal.model.SelectedDataValueStrategy(obj);               
            end
            
        end
    end
    
    
    methods(Access = {  ?matlab.ui.control.internal.controller.ComponentController, ...
            ?matlab.ui.control.internal.model.AbstractStateComponent ... % grant access to the child classes
            })
       
        function handleItemsChanged(obj, newText)
            % Handle a change in Items from the view, e.g. property editor
            
            oldValue = obj.Value;
            
            % Convert the input to row in case it came as a column
            obj.PrivateItems = newText(:)';
            
            % Update the selected index 
            %
            % SelectedIndex could have changed if Items / ItemsData changed
            % and Value was no longer present and needed to be reset
            obj.ValueStrategy.calibrateSelectedIndex(oldValue);
             
            % Mark properties dirty
            %
            % Value could have changed
            obj.markPropertiesDirty({'Value'});
        end
        
        function handleItemsDataChanged(obj, newItemsData)
            % Handle a change in ItemsData from the view, e.g. property editor
            
            if(~isempty(newItemsData))
                % Convert the input to row in case it came as a column
                % Only convert if the input is not empty because this
                % operation changes the size of the input from 0x0 to 1x0
                newItemsData = newItemsData(:)';
            end
            
            % store the old value
            oldValue = obj.Value;
            oldItemsData = obj.PrivateItemsData;
            
            % update the property
            obj.PrivateItemsData = newItemsData;                        
            
            if(xor(isempty(oldItemsData), isempty(newItemsData)))
                % ItemsData changed from empty to non-empty or vice-versa
                % Update the value strategy
                obj.updateValueStrategy();
            end         
            
            % Update the selected index 
            %
            % SelectedIndex could have changed if Items / ItemsData changed
            % and Value was no longer present and needed to be reset
            obj.ValueStrategy.calibrateSelectedIndex(oldValue);            
            
            % Mark properties dirty
            %
            % Value could have changed
            obj.markPropertiesDirty({'Value'});
        end
        
    end
    
    
    methods(Access = {  ?matlab.ui.control.internal.controller.ComponentController, ...
                        ?matlab.ui.control.internal.model.AbstractStateComponent})
        
       function value = getValueGivenIndex(obj, index)
            % Returns the Value given the index
            
            % defer to the strategy
            value = obj.ValueStrategy.getValueGivenIndex(index);
        end
        
    end
    
    
end

