classdef  (ConstructOnLoad=true) TreeNode < ...
        ... Framework classes
        matlab.ui.container.internal.model.ContainerModel & ...
        ... Property Mixins
        matlab.ui.control.internal.model.mixin.IconableComponent & ...
        matlab.ui.container.internal.model.mixin.ExpandableComponent
    %
    
    % Do not remove above white space
    % Copyright 2016 The MathWorks, Inc.
    
    properties(Dependent)
        
        Text = getString(message('MATLAB:ui:defaults:treenodeText'));
        NodeData = [];
    end
    
    properties(Access = 'private')
        % Internal properties
        %
        % These exist to provide:
        % - fine grained control to each properties
        % - circumvent the setter, because sometimes multiple properties
        %   need to be set at once, and the object will be in an
        %   inconsistent state between properties being set
        
        PrivateText = getString(message('MATLAB:ui:defaults:treenodeText'));
        PrivateNodeData = [];
    end
    
    properties(Transient, Access = private)
        % Save reference to tree for efficiency. 
        PrivateTree = [];
    end
    properties(Transient, SetAccess = immutable,  GetAccess = ...
            {?matlab.ui.internal.componentframework.services.optional.ControllerInterface,...
            ?matlab.ui.container.Tree, ...
            ?matlab.ui.container.internal.model.mixin.ExpandableComponent,...
            ?matlab.ui.container.internal.model.TreeComponentSelectionStrategy})
        
        % Unique ID to identify the node
        NodeId = "";
    end
    

    properties (Hidden)
        Serializable@matlab.graphics.datatype.on_off = 'on';
    end

    % ---------------------------------------------------------------------
    % Constructor
    % ---------------------------------------------------------------------
    methods
        function obj = TreeNode(varargin)
            %
            
            % Do not remove above white space
            % Override the default values
            
            obj.Type = 'uitreenode';
            
            pvPairs = varargin;
            
            % Handle Node Set
            if numel(pvPairs) >= 2 && strcmp(pvPairs{1}, 'NodeId')
                % Client driven workflow
                nodeId = pvPairs{2};
                validateattributes(nodeId, {'string'}, {'scalar'});
                obj.NodeId = nodeId;
                pvPairs(1:2) = [];
            else
                % Commandline driven workflow
                obj.NodeId = string(java.util.UUID.randomUUID());
            end
            
            % Handle all other property sets
            parsePVPairs(obj,  pvPairs{:});
        end
        
    end
    
    % ---------------------------------------------------------------------
    % Property Getters / Setters
    % ---------------------------------------------------------------------
    methods
        
        function set.Text(obj, newValue)
            
            % Error Checking
            try
                newValue = matlab.ui.control.internal.model.PropertyHandling.validateText(newValue);
            catch %#ok<CTCH>
                messageObj = message('MATLAB:ui:components:invalidTextValue', ...
                    'Text');
                
                % MnemonicField is last section of error id
                mnemonicField = 'invalidText';
                
                % Use string from object
                messageText = getString(messageObj);
                
                % Create and throw exception
                exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(obj, mnemonicField, messageText);
                throw(exceptionObject);
                
            end
            
            % Property Setting
            obj.PrivateText = newValue;
            
            obj.markPropertiesDirty({'Text'});
        end
        
        function value = get.Text(obj)
            value = obj.PrivateText;
        end
        
        % ----------------------------------------------------------------------
        function set.NodeData(obj, newValue)
            % Property Setting
            obj.PrivateNodeData = newValue;
            
            obj.markPropertiesDirty({'NodeData'});
        end
        
        function value = get.NodeData(obj)
            value = obj.PrivateNodeData;
        end
        
    end
    
    methods
        
        function move(obj, targetNode, direction)
            % MOVE - Reposition node adjacent to targetnode
            narginchk(2,3);
            
            if nargin == 3
                validString = validatestring(direction, {'after', 'before'});
            else 
                % Default value is 'after'
                validString = 'after';
            end    
 
            if strcmp(validString, 'after')
                moveCommand = 'moveAfter';
            elseif strcmp(validString, 'before')
                moveCommand = 'moveBefore';                    
            end
            
            try
                % All node related error checking.
                validateMoveArguments(obj, targetNode);
                
                % Capture selection to restore after move
                thisTree = obj.getTree();
                newTree = targetNode.getTree();
              
                cachedSelectedNodes = [];
                if ~isempty(newTree)
                    % The SelectedNodes of the new tree are the ones likely
                    % to get corrupted via reordering. They should be
                    % restored.
                    cachedSelectedNodes = newTree.SelectedNodes;
                end
                
                % doMove assumes valid inputs
                doMove(obj, targetNode, moveCommand);
                
                % Restore selection if doMove was executed successfully
                if ~isempty(cachedSelectedNodes) && ...
                        ~isequal(newTree.SelectedNodes, cachedSelectedNodes)
                    % Set selection only if required to reduce redundant
                    % validation
                    newTree.SelectedNodes = cachedSelectedNodes;                    
                end
                
            catch me
                throw(me);
            end
        end
    end
    methods(Access = 'private')
        function validateMoveArguments(obj, targetNode)
           
            % Do error checking and throw error if necessary
            % Check first if it is a valid node
            if ~all(isa(obj, 'matlab.ui.container.TreeNode'))
            
                % throw error
                messageObj =  message('MATLAB:ui:components:firstArgumentRequiresTreeNode');
                
                % Use string from object
                messageText = getString(messageObj);
                
                error('MATLAB:ui:TreeNode:firstArgumentRequiresTreeNode', messageText);
                
            elseif ~all(isa(targetNode, 'matlab.ui.container.TreeNode'))
            
                % throw error
                messageObj =  message('MATLAB:ui:components:targetRequiresTreeNode');
                
                % Use string from object
                messageText = getString(messageObj);
                
                error('MATLAB:ui:TreeNode:targetRequiresTreeNode', messageText);

            elseif ~isscalar(obj)
                
                % throw error
                messageObj =  message('MATLAB:ui:components:requiresScalarTreeNode');
                
                % Use string from object
                messageText = getString(messageObj);
                
                error('MATLAB:ui:TreeNode:requiresScalarTreeNode', messageText);
                
            elseif ~isscalar(targetNode)
                
                % throw error
                messageObj =  message('MATLAB:ui:components:requiresScalarTargetTreeNode');
                
                % Use string from object
                messageText = getString(messageObj);
                
                error('MATLAB:ui:TreeNode:requiresScalarTargetTreeNode', messageText);
                
             elseif isempty(targetNode.Parent)
                % This if statement assumes that targetNode is scalar which
                % is verified above.
                 
                % throw error
                messageObj =  message('MATLAB:ui:components:targetIsNotParentedTreeNode');
                
                % Use string from object
                messageText = getString(messageObj);
                
                error('MATLAB:ui:TreeNode:targetIsNotParentedTreeNode', messageText);
                
            end
        end
        function doMove(obj, targetNode, direction)
            if (isequal(obj, targetNode))
                % Moving a node above/below itself would not change the
                % children order.
            else
                % Reorder Children
                
                
                existingChildren = allchild(targetNode.Parent);
                if ~isequal(obj.Parent, targetNode.Parent)                   
                    obj.Parent = targetNode.Parent;
                else
                    existingChildren = existingChildren(existingChildren~=obj);
                end
                
                insertIndex = find(existingChildren == targetNode);
                
                if isequal(direction, 'moveBefore')
                    % Child order is inverse of visual order
                    targetNode.Parent.Children = ...
                        [existingChildren(1:insertIndex-1);...
                        obj;...
                        existingChildren(insertIndex:end)];
                elseif isequal(direction, 'moveAfter')
                    % Child order is inverse of visual order
                    targetNode.Parent.Children = ...
                        [existingChildren(1:insertIndex);...
                        obj;...
                        existingChildren(insertIndex+1:end)];
                end
                
            end
        end
        
    end
    % ---------------------------------------------------------------------
    % Custom Display Functions
    % ---------------------------------------------------------------------
    methods(Access = protected)
        
        function names = getPropertyGroupNames(obj)
            % GETPROPERTYGROUPNAMES - This function returns common
            % properties for this class that will be displayed in the
            % curated list properties for all components implementing this
            % class.
            
            names = {'Text',...
                'Icon',...
                'NodeData'};
            
        end
        
        function str = getComponentDescriptiveLabel(obj)
            % GETCOMPONENTDESCRIPTIVELABEL - This function returns a
            % string that will represent this component when the component
            % is displayed in a vector of ui components.
            str = obj.Text;
            
        end
    end
    
    methods(Access = 'protected')
        
        function validateParentAndState(obj, newParent)
            % Validator for 'Parent'
            %
            % Can be extended / overriden to provide additional validation
            
            % Error Checking
            %
            % A valid parent is one of:
            % - a parenting component
            % - empty []
            
            % Only validate if the value is non empty
            %
            % Empty values are acceptible for not having a parent
            if(~isempty(newParent))
                
                if ~(isa(newParent, 'matlab.ui.container.Tree')||...
                        isa(newParent, 'matlab.ui.container.TreeNode'))
                    
                    messageObj = message('MATLAB:ui:components:invalidTreeNodeParent', ...
                        'Parent');
                    
                    % MnemonicField is last section of error id
                    mnemonicField = 'invalidParent';
                    
                    % Use string from object
                    messageText = getString(messageObj);
                    
                    % Create and throw exception
                    exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(obj, mnemonicField, messageText);
                    throw(exceptionObject);
                    
                end
            end
            
            % Clean up old parent
            oldTree = obj.getTree();
            
            newTree = [];
            if ~isempty(newParent)
                newTree = newParent.getTree();
            end
            
            if ~isempty(oldTree) && ~isequal(oldTree, newTree)
                oldTree.handleDescendentRemoved(obj);
                
                % Clean up tree reference.
                obj.PrivateTree = [];
            end            
        end


        function validateChildState(obj, newChild)
            % Validator for 'Child'
            %
            % Can be extended / overriden to provide additional validation
            
            % Error Checking
            %
            % A valid child is one of:
            % - TreeNode
            % - ... and that's it!
            
            % Only validate if the value is non empty
            %
            % Empty values are acceptible for not having a parent
            if(~isempty(newChild))
                
                if ~(isa(newChild, 'matlab.ui.container.TreeNode'))
 
                    messageObj = message('MATLAB:ui:components:invalidTreeOrNodeChild', ...
                        'Parent', class(newChild));
                    
                    % MnemonicField is last section of error id
                    mnemonicField = 'invalidParent';
                    
                    % Use string from object
                    messageText = getString(messageObj);
                    
                    % Create and throw exception
                    exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(obj, mnemonicField, messageText);
                    throwAsCaller(exceptionObject);
                   
                end
            end            
        end

    end
    methods
        function delete(obj)

            tree = obj.getTree();
            
            % Allow tree to handle the node removal
            % This may mutate the SelectedNodes property of the tree
            if ~isempty(tree) && strcmp(tree.BeingDeleted, 'off')
                tree.handleDescendentRemoved(obj);
            end
            
            % Clean up object.
            obj.PrivateTree = [];

        end
    end
    
    methods (Access = private)
        
        function tree = getTree(obj)
            
             % Cache tree reference for future use.
             if isempty(obj.PrivateTree)
                 obj.PrivateTree = ancestor(obj, 'uitree');
             end
             
             tree = obj.PrivateTree;
        end
    end
    
    methods (Access = {?matlab.ui.container.internal.model.ContainerModel, ...
            ?matlab.ui.container.internal.model.mixin.ExpandableComponent})   
        function handleNodeEvent(obj, eventData)
             
            tree = obj.getTree();
            
             % if treenode is not parented to a tree, do not cache actions
             if ~isempty(tree)
                 tree.handleNodeEvent(eventData);
             end

        end     
    end
    
    methods(Access='public', Static=true, Hidden=true)
      function varargout = doloadobj( hObj) 
          % DOLOADOBJ - Graphics framework feature for loading graphics
          % objects
          

          hObj = doloadobj@matlab.ui.control.internal.model.mixin.IconableComponent(hObj);
          varargout{1} = hObj;
      end
   end
end



