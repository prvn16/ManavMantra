classdef  (ConstructOnLoad=true) Tree < ...
        ... Framework classes
        matlab.ui.container.internal.model.ContainerModel & ...
        ... Property Mixins
        matlab.ui.control.internal.model.mixin.EnableableComponent & ...
        matlab.ui.control.internal.model.mixin.EditableComponent & ...
        matlab.ui.control.internal.model.mixin.VisibleComponent & ...
        matlab.ui.control.internal.model.mixin.FontStyledComponent & ...
        matlab.ui.control.internal.model.mixin.BackgroundColorableComponent & ...
        matlab.ui.control.internal.model.mixin.PositionableComponent & ...
        matlab.ui.container.internal.model.mixin.ExpandableComponent
    %
    
    % Do not remove above white space
    % Copyright 2016 The MathWorks, Inc.
    
    properties(Dependent)
        
        SelectedNodes = [];
        Multiselect@matlab.graphics.datatype.on_off = 'off';
    end
    
    properties(NonCopyable, Dependent)
        % Callbacks
        SelectionChangedFcn@matlab.graphics.datatype.Callback;
        NodeExpandedFcn@matlab.graphics.datatype.Callback;
        NodeCollapsedFcn@matlab.graphics.datatype.Callback;
        NodeTextChangedFcn@matlab.graphics.datatype.Callback;
    end
    
    properties(Transient, Access = ...
            {?matlab.ui.internal.componentframework.services.optional.ControllerInterface,...
            ?matlab.ui.container.Tree, ...
            ?matlab.ui.container.internal.model.mixin.ExpandableComponent,...
            ?matlab.ui.container.internal.model.TreeComponentSelectionStrategy})
        
        % ID idenfitying the tree component
        NodeId = "#";
    end
    
    properties(Access = {?appdesservices.internal.interfaces.controller.AbstractController})
        % Internal properties
        %
        % These exist to provide:
        % - fine grained control to each properties
        % - circumvent the setter, because sometimes multiple properties
        %   need to be set at once, and the object will be in an
        %   inconsistent state between properties being set
        
        PrivateSelectedNodes = [];
    end
    
    properties(Access = 'private')
        % Internal properties
        %
        % These exist to provide:
        % - fine grained control to each properties
        % - circumvent the setter, because sometimes multiple properties
        %   need to be set at once, and the object will be in an
        %   inconsistent state between properties being set
        
        PrivateMultiselect@matlab.graphics.datatype.on_off = 'off';
                
        % Strategy to handle differences in behavior based on Multiselect
        SelectionStrategy
    end
    
    properties(NonCopyable, Access = 'private')
         
        % Callbacks
        PrivateSelectionChangedFcn@matlab.graphics.datatype.Callback;
        PrivateNodeExpandedFcn@matlab.graphics.datatype.Callback;
        PrivateNodeCollapsedFcn@matlab.graphics.datatype.Callback;
        PrivateNodeTextChangedFcn@matlab.graphics.datatype.Callback;
    end
     
    properties (Transient, Access = ...
            {?appdesservices.internal.interfaces.controller.AbstractController})
        QueuedActionToView = cell.empty;
    end

    properties (Hidden)
        Serializable@matlab.graphics.datatype.on_off = 'on';
    end
    
    events(NotifyAccess = {?matlab.ui.control.internal.controller.ComponentController})
        SelectionChanged;
        NodeExpanded;
        NodeCollapsed;
        NodeTextChanged;
    end
    
    % ---------------------------------------------------------------------
    % Constructor
    % ---------------------------------------------------------------------
    methods
        function obj = Tree(varargin)
            %
            
            % Do not remove above white space
            % Override the default values
            
            defaultPosition = [20, 20, 150, 300];
            obj.PrivateOuterPosition = defaultPosition;
            obj.PrivateInnerPosition = defaultPosition;
            obj.Editable = 'off';
            
            obj.updateSelectionStrategy();
            
            obj.Type = 'uitree';
            
            % Wire callbacks
            obj.attachCallbackToEvent('SelectionChanged', 'PrivateSelectionChangedFcn');
            obj.attachCallbackToEvent('NodeExpanded', 'PrivateNodeExpandedFcn');
            obj.attachCallbackToEvent('NodeCollapsed', 'PrivateNodeCollapsedFcn');
            obj.attachCallbackToEvent('NodeTextChanged', 'PrivateNodeTextChangedFcn');
            
            parsePVPairs(obj,  varargin{:});
        end
        
        
        % ----------------------------------------------------------------------
        function set.Multiselect(obj, newValue)
            
            % Property Setting
            obj.PrivateMultiselect = newValue;
            
            % Update selection strategy
            obj.updateSelectionStrategy();
            
            % Change in multiselect may result in change of SelectedNodes
            calibratedNodes = obj.SelectionStrategy.calibrateSelectedNodesAfterSelectionStrategyChange();
            
            if isequal(obj.SelectedNodes, calibratedNodes)
                obj.markPropertiesDirty({'Multiselect'});
            else
                doSetSelectedNodes(obj, calibratedNodes);
                obj.markPropertiesDirty({'Multiselect', 'SelectedNodes'});
            end
        end
        
        function value = get.Multiselect(obj)
            value = obj.PrivateMultiselect;
        end
        
        % ----------------------------------------------------------------------
        function set.SelectedNodes(obj, newValue)
            
            try
                newValue = obj.SelectionStrategy.validateSelectedNodes(newValue);
            catch
                
                % Create and throw exception
                exceptionObject = obj.SelectionStrategy.getExceptionObject();
                throw(exceptionObject);
            end
            
            % Property Setting
            doSetSelectedNodes(obj, newValue);
            
            obj.markPropertiesDirty({'SelectedNodes'});
        end
        
        function value = get.SelectedNodes(obj)
            value = obj.PrivateSelectedNodes;
        end
        
        % ----------------------------------------------------------------------
        function set.SelectionChangedFcn(obj, newValue)
            % Property Setting
            obj.PrivateSelectionChangedFcn = newValue;
            
            obj.markPropertiesDirty({'SelectionChangedFcn'});
        end
        
        function value = get.SelectionChangedFcn(obj)
            value = obj.PrivateSelectionChangedFcn;
        end
        
        % ----------------------------------------------------------------------
        function set.NodeExpandedFcn(obj, newValue)
            % Property Setting
            obj.PrivateNodeExpandedFcn = newValue;
            
            obj.markPropertiesDirty({'NodeExpandedFcn'});
        end
        
        function value = get.NodeExpandedFcn(obj)
            value = obj.PrivateNodeExpandedFcn;
        end
        % ----------------------------------------------------------------------
        function set.NodeCollapsedFcn(obj, newValue)
            % Property Setting
            obj.PrivateNodeCollapsedFcn = newValue;
            
            obj.markPropertiesDirty({'NodeCollapsedFcn'});
        end
        
        function value = get.NodeCollapsedFcn(obj)
            value = obj.PrivateNodeCollapsedFcn;
        end
        % ----------------------------------------------------------------------
        function set.NodeTextChangedFcn(obj, newValue)
            % Property Setting
            obj.PrivateNodeTextChangedFcn = newValue;
            
            obj.markPropertiesDirty({'NodeTextChangedFcn'});
        end
        
        function value = get.NodeTextChangedFcn(obj)
            value = obj.PrivateNodeTextChangedFcn;
        end
    end
    
    methods
        
        function scroll(obj, scrollTarget)
            % SCROLL - Scroll tree to target
            narginchk(2, 2);
            scrollTarget = convertStringsToChars(scrollTarget);
            
            validTargets = {'top', 'bottom'};
            
            % Do error checking and throw error if necessary
            % Check first if it is a valid node
            if (isa(scrollTarget, 'matlab.ui.container.TreeNode') && isscalar(scrollTarget) ...
                    && obj.nodesAreTreeMember(scrollTarget)) ...
                    ... Or is enum values 'top', 'bottom'
                    || ischar(scrollTarget) &&...
                    any(startsWith(validTargets, scrollTarget,'IgnoreCase', true))
                
                if isa(scrollTarget, 'matlab.ui.container.TreeNode')
                
                    target = scrollTarget.NodeId;
                else
                    
                    % Value is 'top' or 'bottom'
                    target = string(...
                        validTargets(...
                            startsWith(validTargets, scrollTarget,'IgnoreCase', true)...
                           )...
                        );                    
                end
                
                if isempty(obj.Controller)
                    
                    % cast to string to make api uniform on view
                    eventData = {'scroll', target};
                    
                    obj.handleNodeEvent(eventData);
                else
                                        
                    % Forward scroll to view
                    obj.Controller.scroll(target);
                end
            else
                % throw error
                messageObj =  message('MATLAB:ui:components:invalidTreeScrollTarget', 'top', 'bottom');
                
                % Use string from object
                messageText = getString(messageObj);
                
                error('MATLAB:ui:Tree:invalidTreeScrollTarget', messageText);
                
                
            end
        end
        
    end
    
    methods(Access = private)
        
        % Update the Selection Strategy property
        function updateSelectionStrategy(obj)
            if(strcmp(obj.PrivateMultiselect, 'on'))
                obj.SelectionStrategy = matlab.ui.container.internal.model.ZeroToManyTreeSelectionStrategy(obj);
            else
                obj.SelectionStrategy = matlab.ui.container.internal.model.ZeroToOneTreeSelectionStrategy(obj);
            end
        end
        
        function doSetSelectedNodes(obj, newValue)
            % Update SelectedNodes value without marking it dirty.
            % This is generally done to consolidate dirty events.
            % Property Setting
            obj.PrivateSelectedNodes = newValue;
            
        end
    end
    methods(Access = {?matlab.ui.container.internal.controller.TreeController,...
            ?matlab.ui.container.internal.controller.TreeNodeController})
        
        function nodes = getNodesById(obj, nodeIds)
            % GETNODESBYID -  Returns node object in tree given id
            %
            %Note: There is minimal validation here because it is assumed
            %the nodeIds all represent nodes in the tree.  Generally this
            %method will be called after selection has changed on the client
            %and it is assumed the client is providing accurate information.
            
            % Find all descendent
            allTreeNodes = findall(allchild(obj));
            
            % Create matching list of Ids
            allTreeNodeIds = [allTreeNodes.NodeId];
            
            % Find indicies of nodes where the id matches the nodeIds
            [~,IA,~] = intersect(allTreeNodeIds,nodeIds);
            
            % Return corresponding nodes
            nodes = allTreeNodes(IA);
            
            
        end
        
    end
    
    methods (Access = {?matlab.ui.container.internal.model.TreeComponentSelectionStrategy})
        function nodesAreMembers = nodesAreTreeMember(obj, treeNodes)
            % NODESARETREEMEMBER - Returns true if the treeNode entered are
            % all members of the tree, otherwise it returns false
            
            % Validation that the nodes are within the hierarchy
            allTreeNodes = findall(allchild(obj));
            
            if ~isempty(allTreeNodes)
                % Search for empty uninitialized NodeId values
                nodeIds = [treeNodes.NodeId];
                
                % Use NodeId to validate selectedNodes because it is faster
                % Operating on Ids is faster than operating on MCOS objects
                allIds = [allTreeNodes.NodeId];
                
                % Note: ismember was fastest validation technique compared with
                % using setxor and setdiff.
                nodesAreMembers = all(ismember(nodeIds, allIds));
            else
                
                % If the tree has no descendents, then the treeNode
                % provided is not a member
                nodesAreMembers = false;
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
            
            names = {'SelectedNodes',...
                'Multiselect',...
                'SelectionChangedFcn'};
            
        end
        
        function str = getComponentDescriptiveLabel(obj)
            % GETCOMPONENTDESCRIPTIVELABEL - This function returns a
            % string that will represent this component when the component
            % is displayed in a vector of ui components.
            
            
            % There's no strong property in Tree representing the visual
            % for the component, so always use Tag as description.
            str = obj.Tag;
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
    
    methods (Access = {?matlab.ui.container.internal.model.ContainerModel, ...
            ?matlab.ui.container.internal.model.mixin.ExpandableComponent})
        function handleNodeEvent(obj, eventData)
            obj.QueuedActionToView{end+1} = eventData;
        end
    end
    
    methods(Access = private)
        
        function filterQueuedActions(obj, id)
            
            assert(isscalar(id), 'Argument id is expected to be scalar')
            % Search list from end because we might delete entry
            for index = numel(obj.QueuedActionToView): -1: 1
               
                if any(strcmp(obj.QueuedActionToView{index}{1}, {'scroll', 'expand', 'collapse'}))
                   % Remove id from Target
                   obj.QueuedActionToView{index}{2} = ...
                           obj.QueuedActionToView{index}{2}(...
                           obj.QueuedActionToView{index}{2}~=id);
                   if isempty(obj.QueuedActionToView{index}{2})
                       % Remove event from array if it has no target.
                       obj.QueuedActionToView(index) = [];
                   end
                end
            end
        end
    end
    
    methods(Access = {?matlab.ui.container.TreeNode})
        function handleDescendentRemoved(obj, treeNode)
            
            if ~isempty(obj.QueuedActionToView)
                
                nodesToRemove = findall(treeNode);
                nodeIds = [nodesToRemove.NodeId];
                
                for id = nodeIds
                    obj.filterQueuedActions(id);
                end
                
                if numel(treeNode.Parent.Children) == 1 % only child is the deleted node
                    obj.filterQueuedActions(treeNode.Parent.NodeId);
                end
                
            end
            
            if ~isempty(obj.SelectedNodes)
                allRemovedTreeNodes = findall(treeNode);
                
                removedNodeIds = [allRemovedTreeNodes.NodeId];
                
                if isempty(obj.SelectedNodes)
                    isSelectedAndRemoved = false;
                else
                    selectedNodeIds = [obj.SelectedNodes.NodeId];
                    % Find SelectedNodes array that are being removed
                    
                    isSelectedAndRemoved = ismember(selectedNodeIds, removedNodeIds);
                end
                              
                % Check if treeNode was selected as optimization
                if any(isSelectedAndRemoved)
                    % Remove deleted node from selected Nodes array
                    nodeArray = obj.SelectedNodes(~isSelectedAndRemoved);
                    
                    if isempty(nodeArray)
                        % Empty representation for SelectedNodes
                        obj.SelectedNodes = [];
                    else
                        obj.SelectedNodes = nodeArray;
                    end
                    
                    
                    % Public setter for SelectedNodes will mark it dirty
                end
            end
        end
        
        function tree = getTree(obj)
             
             % TreeNodes use getTree generically in their code.
             tree = obj;
        end
     end
end



