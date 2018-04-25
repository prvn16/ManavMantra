classdef (Hidden) SelectedDataValueStrategy < matlab.ui.control.internal.model.StateComponentValueStrategy
    % SelectedDataValueStrategy
    %
    % Concrete strategy class for Value returning the data of the selected
    % option, i.e. Value is an element of ItemsData
    % This strategy is used when ItemsData is empty
    
    methods
        function obj = SelectedDataValueStrategy(stateComponentInstance)
            obj = obj@matlab.ui.control.internal.model.StateComponentValueStrategy(stateComponentInstance);
        end
    end
    
    methods(Access = {  ?matlab.ui.control.internal.model.StateComponentValueStrategy, ...
            ?matlab.ui.control.internal.model.AbstractStateComponent})
        
        
        % Update selected index after the value strategy got changed to
        % this one such that the selected index remains valid
        function calibrateSelectedIndexAfterValueStrategyChange(obj)
            obj.Component.SelectionStrategy.calibrateSelectedIndexAfterSwitchToDataSpace();
        end
        
        % Update selected index after Items or ItemsData was changed.
        % This method assumes that there was no change in Value Strategy.
        function calibrateSelectedIndex(obj, currentValue)
            obj.Component.SelectionStrategy.calibrateSelectedIndexInDataSpace(currentValue);
        end
        
        % Validator for the Value property
        function value = validateValue(obj, newValue)
            value = obj.Component.SelectionStrategy.validateValuePresentInItemsData(newValue);
        end
        
        % Returns the selected index given the Value
        % Returns -1 if no selection is possible because of component
        % configuration
        function index = getIndexGivenValue(obj, value)
            hasNoSelection = obj.Component.SelectionStrategy.isNothingSelected(value);
            
            if hasNoSelection
                index = -1;
            else
                index =  obj.Component.SelectionStrategy.getIndexGivenSelectedData(value);              
            end
            
        end
        
        % Returns the Value given the selected index
        function value = getValueGivenIndex(obj, index)
            value = obj.Component.SelectionStrategy.getSelectedDataGivenIndex(index);
        end
    end
    
end
