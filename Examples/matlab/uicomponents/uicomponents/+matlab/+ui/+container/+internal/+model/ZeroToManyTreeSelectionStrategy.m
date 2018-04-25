classdef ZeroToManyTreeSelectionStrategy < matlab.ui.container.internal.model.TreeComponentSelectionStrategy
    %ZEROTOONETREESELECTIONSTRATEGY Selection strategy for tree when
    %Multiselect of the tree component is 'on'
    
    properties
        MaximumNumberOfSelectedNodes = Inf;
    end
    
    methods

        function obj = ZeroToManyTreeSelectionStrategy(tree)
            obj@matlab.ui.container.internal.model.TreeComponentSelectionStrategy(tree);
        end
    end
        methods(Access = {  ?matlab.ui.container.internal.model.TreeComponentSelectionStrategy, ... ...
            ?matlab.ui.container.Tree})
        
        % Update the selected index after the strategy has been
        % changed to this strategy
        function calibratedNodes = calibrateSelectedNodesAfterSelectionStrategyChange(obj)
            % The component must have switched from the strategy allowing
            % zero to one selection to this one.
            % Any selection in the zero to one strategy is still valid in
            % this one, so no need to change selected index
            
            calibratedNodes = obj.Tree.SelectedNodes;
        end
        
        function exceptionObject = getExceptionObject(obj)
            % GETEXCEPTIONOBJECT - object to throw when there
            % are errors setting the SelectedNodes property
            
            
            messageObj = message('MATLAB:ui:components:selectedNodesInvalidInputMultiSelectOn', 'Multiselect', 'on', 'SelectedNodes');
            
            % MnemonicField is last section of error id
            mnemonicField = 'selectedNodesInvalidInputMultiSelectOn';
            
            % Use string from object
            messageText = getString(messageObj);
            
            % Create and throw exception
            exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(obj.Tree, mnemonicField, messageText);
            
        end
        
        
    end
end

