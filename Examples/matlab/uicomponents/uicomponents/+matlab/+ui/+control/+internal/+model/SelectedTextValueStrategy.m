classdef (Hidden) SelectedTextValueStrategy < matlab.ui.control.internal.model.StateComponentValueStrategy
    % SelectedTextValueStrategy
    % 
    % Concrete strategy class for Value returning the text of the selected
    % option, i.e. Value is an element of Items.
    % This strategy is used when ItemsData is empty
    
    methods
        function obj = SelectedTextValueStrategy(stateComponentInstance)
            obj = obj@matlab.ui.control.internal.model.StateComponentValueStrategy(stateComponentInstance);
        end
    end
    
    methods(Access = {  ?matlab.ui.control.internal.model.StateComponentValueStrategy, ...
                        ?matlab.ui.control.internal.model.AbstractStateComponent})
        
        % Update selected index after the value strategy got changed to
        % this one such that the selected index remains valid
        function calibrateSelectedIndexAfterValueStrategyChange(~)
            % The value strategy got changed to this one, which means that
            % ItemsData got set to empty. No change of selected index needed
            
            % no-op
        end
        
        % Update selected index after Items or ItemsData was changed.
        % This method assumes that there was no change in Value Strategy. 
        function calibrateSelectedIndex(obj, currentValue)
            obj.Component.SelectionStrategy.calibrateSelectedIndexInTextSpace(currentValue);
        end
        
        % Validator for the Value property        
        function value = validateValue(obj, newValue)
            % Convert string value to char only when ItemsData is empty.
            newValue = convertStringsToChars(newValue);
            value = obj.Component.SelectionStrategy.validateValuePresentInItems(newValue);
        end
        
        % Returns the selected index given the Value
        function index = getIndexGivenValue(obj, value)
            
            hasNoSelection = obj.Component.SelectionStrategy.isNothingSelected(value);
            
            if hasNoSelection
                index = -1;
            else
                index =  obj.Component.SelectionStrategy.getIndexGivenSelectedText(value);
            end
        end
    
        % Returns the Value given the selected index
        function value = getValueGivenIndex(obj, index) 
            value = obj.Component.SelectionStrategy.getSelectedTextGivenIndex(index);
        end

    end
    
end
