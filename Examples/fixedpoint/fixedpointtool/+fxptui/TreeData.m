classdef TreeData < handle
    % TREEDATA Class definition to create the model hierarchy for a given
    % model.
    
    % Copyright 2014-2017 The MathWorks, Inc.
    
    properties (SetAccess = private, GetAccess = private)
        Model
    end
    
    methods
        function this = TreeData(model)
            if nargin > 0
                sys = find_system('type','block_diagram','Name',model);
                if isempty(sys)
                    [msg, identifier] = fxptui.message('modelNotLoaded',model);
                    e = MException(identifier, msg);
                    throwAsCaller(e);
                else
                    this.Model = get_param(model, 'Object');
                end
            end
        end
        
        function treeData = getHierarchyData(this, level, showAllConstructs, modelHierarchy)
            % Returns the model hierarchy information in form of a struct
            % along with the parent & children information.
            
            allModelNodes = [modelHierarchy.getTopModelNode modelHierarchy.getSubModelNode];
            count = 1;
            treeData(1:numel(allModelNodes)) = struct('Models',[],'children',[],'TopModel',[]);
            for i = 1:numel(allModelNodes)
                modelNode = allModelNodes(i);
                dataObj = this.getSystemHierarchy(modelNode.Object, modelHierarchy, level, showAllConstructs);
                if (level == 0 && numel(modelNode.getChildren) > 0 ||...
                        numel(dataObj) > 500)
                    modelNode.HasChildren = true;
                    modelNode.ItemFullyLoaded = false;
                    dataObj = [];
                end               
                modelData = this.convertToStruct(modelNode);
                treeData(count).Models = modelData;
                treeData(count).children = this.convertToStruct(dataObj);
                treeData(count).TopModel = this.Model.getFullName;
                count = count + 1;
            end
        end
        
        function treeData =  getChildren(this, sysObj, level, showAllConstructs, modelHierarchy)
            % Gets the children for the specified system depending on
            % levels specified.
            treeDataObj = this.getSystemHierarchy(sysObj, modelHierarchy, level, showAllConstructs);
            treeData = this.convertToStruct(treeDataObj);
        end
    end
    
    methods(Hidden)
        function setModel(this, modelName)
            sys = find_system('type','block_diagram','Name',modelName);
            if isempty(sys)
                [msg, identifier] = fxptui.message('modelNotLoaded',modelName);
                e = MException(identifier, msg);
                throwAsCaller(e);
            else
                this.Model = get_param(modelName, 'Object');
            end
        end
        
        function model = getModel(this)
            model = this.Model;
        end
        
        function map = generateMapping(~)
            % Get complete tree information with all nodes. Map each child
            % to its parent. Only called from FPT Web code path
            
            map = containers.Map('KeyType','char','ValueType','any');
            fptInstance = fxptui.FixedPointTool.getExistingInstance;
            if ~isempty(fptInstance)
                modelHierarchy = fptInstance.getModelHierarchy;
                map = modelHierarchy.getChildParentCacheMap;
            end
        end
        
        function hierarchyStruct = generateParentChildMapping(this, resultUniqueID)
            % Given a result's unique ID, generate the mapping between its
            % child and parent. This is exclusively used to add MATLAB
            % function nodes to the tree after data collection since that
            % is when we have that information available. 
            % Only called from FPT web code path
            hierarchyStruct = struct([]);            
            if isa(resultUniqueID, 'fxptds.MATLABFunctionIdentifier')
                functionID = resultUniqueID;               
                fptInstance = fxptui.FixedPointTool.getExistingInstance;
                chNodes = fptInstance.getModelHierarchy.generateNodesForMATLABFunction(functionID);
                hierarchyStruct = this.convertToStruct(chNodes);
            end
        end
    end
    
    methods(Access = private)
         function [children, hasChildren] = getSystemHierarchy(this, bdObj, modelHierarchy, level, showAllConstructs)
            % Returns the children of a given Simulink system. Filter out
            % Model Refernce blocks and Stateflow states, objects under the
            % chart as they are not valid for conversion in isolation
            children = [];
            hasChildren = false;
            if isempty(bdObj) ; return; end
            % Find the tree node that contains the object passed in.            
            systemTreeNode = modelHierarchy.findNode('Object', bdObj);
            node = systemTreeNode;
            idxToRemove = [];
            if isinf(level)                
                children = [children this.unrollTree(node)];                
            else
                for p = 1:level
                    newChildren = [];
                    for k = 1:numel(node)
                        node(k).ItemFullyLoaded = true;                        
                        ch = node(k).getChildren;
                        if ~showAllConstructs
                            if fxptds.isStateflowChartObject(node(k).Object)
                                ch = this.getSupportedChildrenUnderStateflowChart(node(k));
                                node(k).HasChildren = false;
                            end
                        end
                        if ~isempty(ch) 
                            node(k).HasChildren = false;
                            if ~node(k).IsUnderMask                                                        
                                node(k).HasChildren = true;
                            end
                            node(k).ItemFullyLoaded = true;
                            newChildren = [newChildren(:); ch(:)];
                        end
                    end 
                    node = newChildren;
                    if (p == level)
                        % The last node doesn't get to process its children
                        for i = 1:numel(node)
                            node(i).ItemFullyLoaded = false;
                        end
                    end
                    children = [children(:); newChildren(:)];
                end
            end
            for m = 1:numel(children)
                parentNode = children(m).getParent;
                parentNode.HasChildren = true;   
                % If the child is no longer valid, remove it from the tree
                if children(m).isNodeStale()
                    idxToRemove = [idxToRemove m]; %#ok<*AGROW>
                    parentNode.HasChildren = false;
                end
                % remove child if it is under a mask and the masked parent
                % is different from itself (it itself isn't masked)
                if children(m).IsUnderMask                    
                    if ~isequal(children(m).MaskedParent, children(m).Object) || ...
                            (parentNode.IsUnderMask)
                        idxToRemove = [idxToRemove m];
                        parentNode.HasChildren = false;
                    end
                end
                % This happens when the parent is a linked subsystem. Its
                % children will be parented to the library and not the
                % linked instance.
                if ~isequal(children(m).ParentIdentifier, parentNode.Identifier)
                    idxToRemove = [idxToRemove m];
                    parentNode.HasChildren = false;
                end

                if showAllConstructs
                    isChildUnsupported = false;
                    isParentUnsupported = false;
                else
                    isChildUnsupported = this.isUnsupportedChild(children(m).Object);
                    isParentUnsupported = this.isUnsupportedChild(children(m).getParent.Object);
                end
                % If the child is unsupported
                if isChildUnsupported
                    idxToRemove = [idxToRemove m];
                    parentNode.HasChildren = false;
                end
                % If the parent of the child is unsupported
                if isParentUnsupported
                    parent = parentNode;
                    while this.isUnsupportedChild(parent.Object)
                        parent = parent.getParent;
                    end
                    % Create a new node to represent the child node
                    % since we need to point to a different parent
                    % without corrupting the existing data. Don't add this
                    % node to the hierarchy. The client will use the
                    % identifier property to link parent & children.
                    childCopy = children(m).createDeepCopy;
                    children(m) = childCopy;
                    children(m).ParentIdentifier = parent.Identifier;
                end
            end
            children(idxToRemove) = [];
            numChildren = numel(children);
            % Update the HasChildren property on the parent of final children
            for i = 1:numChildren
                parentNode = children(i).getParent;    
                % parentNode can be empty when copies of nodes are made
                % based on unsupported nodes
                if ~isempty(parentNode)
                    parentNode.HasChildren = true;
                end
            end
            hasChildren = numChildren > 0;
            % parentNode was from the loop here
            systemTreeNode.HasChildren = hasChildren;
        end
         
        function data = unrollTree(this, nodes)
            % Get all chilren from the specified nodes. Depth = inf.
            data = [];
            for i = 1:numel(nodes)
                node = nodes(i);
                children = node.getChildren;
                if ~isempty(children)
                    for k = 1:numel(children)
                        data = [data children(k)];
                    end
                    data = [data this.unrollTree(children)];
                end
            end
        end
        
        function [uniqueID, isMasked] = getParentIdentifier(~, blkObj, showAllConstructs)
            % The parent property should match with the
            % identifier generation. For example,
            % identifiers retain the new line characters in
            % the name and hence the parent string should
            % also retain the new line characters in the
            % string. This will help resolve it to the
            % Simulink entity when needed.
            
            if nargin < 3
                showAllConstructs = true;
            end
            
            bdObj = blkObj;
            [isMasked, parent] = fxptui.isUnderMaskedSubsystem(blkObj);
            if isMasked
                bdObj = parent;
            end
            
            ah = fxptds.SimulinkDataArrayHandler;
            if isa(bdObj,'Stateflow.Object') && ~fxptds.isStateflowChartObject(bdObj)
                if showAllConstructs
                    inp.Object = bdObj;
                    uniqueID = ah.getUniqueIdentifier(inp);
                else
                    % Skip the stateflow object and parent
                    % directly to the chart in case we are
                    % filtering those objects
                    inp.Object = bdObj.Chart;
                    uniqueID = ah.getUniqueIdentifier(inp);
                end
            else
                inp.Object = bdObj;
                uniqueID = ah.getUniqueIdentifier(inp);
            end
        end
        
        function treeData = convertToStruct(~, treeDataObj)
            % Convert to structure to send to the client.
            treeData = struct([]);
            if ~isempty(treeDataObj)
                treeData = treeDataObj(1).convertToStruct;
            end
            for i = 2:numel(treeDataObj)
                treeData(i) = treeDataObj(i).convertToStruct;
            end
        end                               
        
        function children = getSupportedChildrenUnderStateflowChart(this, treeNode)
            % Get only the supported children under Stateflow chart.
            % For example, stateflow state is not a supported child for SUD tree.
           children = this.unrollTree(treeNode);
           unsupportedChild = arrayfun(@(child)this.isUnsupportedChild(child.Object), children);
           children = children(~unsupportedChild);
        end
        
        function b = isUnsupportedChild(~, child)
            b = isa(child,'Simulink.ModelReference') || ...
                (isa(child,'Stateflow.Object') && ~fxptds.isStateflowChartObject(child)) || ...
                isa(child, 'fxptds.MATLABFunctionIdentifier');
            
        end               
    end      
end

% LocalWords:  modelnotfound FPT
