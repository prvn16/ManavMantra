classdef ZeroToOneTreeSelectionStrategy < matlab.ui.container.internal.model.TreeComponentSelectionStrategy
    %ZEROTOONETREESELECTIONSTRATEGY Selection strategy for tree when
    %Multiselect of the tree component is 'off'
    
    properties
        MaximumNumberOfSelectedNodes = 1;
    end
    
    methods
        function obj = ZeroToOneTreeSelectionStrategy(tree)
            obj@matlab.ui.container.internal.model.TreeComponentSelectionStrategy(tree);
        end
        
    end
    methods(Access = {  ?matlab.ui.container.internal.model.TreeComponentSelectionStrategy, ... ...
            ?matlab.ui.container.Tree})
        

        function calibratedNodes = calibrateSelectedNodesAfterSelectionStrategyChange(obj)
            % Update SelectedNodes after Multiselect has changed.
            % The maximum size of the selectedNodes array should be 1
            
            calibratedNodes = obj.Tree.SelectedNodes;
            
            if numel(calibratedNodes > 1)
                % If there are more than one selected nodes filter out all
                % but first node.
                calibratedNodes = calibratedNodes(1);
            end
        end
        
        function exceptionObject = getExceptionObject(obj)
            % GETEXCEPTIONOBJECT - object to throw when there
            % are errors setting the SelectedNodes property
            messageObj = message('MATLAB:ui:components:selectedNodesInvalidInputMultiSelectOff', 'Multiselect', 'off', 'SelectedNodes');
            
            % MnemonicField is last section of error id
            mnemonicField = 'selectedNodesInvalidInputMultiSelectOff';
            
            % Use string from object
            messageText = getString(messageObj);
            
            % Create and throw exception
            exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(obj.Tree, mnemonicField, messageText);
            
        end
                
    end
end

