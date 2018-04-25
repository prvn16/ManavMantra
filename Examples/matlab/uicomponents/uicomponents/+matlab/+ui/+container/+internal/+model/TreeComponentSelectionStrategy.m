classdef TreeComponentSelectionStrategy
    %TREECOMPONENTSELECTIONSTRATEGY This object performs validation for the
    %Tree component.  It will be subclassed to allow custom strategies
    %based on the selection state of the tree component.
    
    properties (Abstract)
        MaximumNumberOfSelectedNodes;
    end
    
    properties (Access = 'protected')
        Tree
    end
    
    methods (Abstract, Access = {  ?matlab.ui.container.internal.model.TreeComponentSelectionStrategy, ... ...
            ?matlab.ui.container.Tree})
        
        % returns exception to be thrown when there is an issue with
        % validation of the SelectedNodes
        exceptionObject = getExceptionObject(obj);
        
        % Returns new valid of selected nodes valid after a strategy change
        calibratedNodes = calibrateSelectedNodesAfterSelectionStrategyChange(obj)
    end
    
    methods
        
        function obj = TreeComponentSelectionStrategy(tree)
            obj.Tree = tree;
        end
    end
    
    methods(Access = {  ?matlab.ui.container.internal.model.TreeComponentSelectionStrategy, ... ...
            ?matlab.ui.container.Tree})
        function output = validateSelectedNodes(obj, selectedNodes)
            
            % special check for empty because SelectedNodes is always allowed
            % to be empty, regardless of the size constraints
            if (isequal(selectedNodes, []))
                output = selectedNodes;
                return;
            end
            
            % Remove duplicates from selectedNodes
            selectedNodes = unique(selectedNodes, 'stable');
            
            validateattributes(selectedNodes, ...
                {'matlab.ui.container.TreeNode'}, {'vector'});
            
            validateattributes(numel(selectedNodes), {'numeric'}, ...
                {'<=' obj.MaximumNumberOfSelectedNodes});
            
            nodesAreValid = nodesAreTreeMember(obj.Tree, selectedNodes);
            
            % Assert that all selected nodes are part of the tree hierarchy
            % Customer facing error will be thrown by calling function
            assert(nodesAreValid, 'Some nodes were not part of tree')
            
            % reshape to column
            output = selectedNodes(:);
            
        end    
    end   
end

