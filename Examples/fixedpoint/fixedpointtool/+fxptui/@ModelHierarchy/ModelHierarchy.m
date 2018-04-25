classdef ModelHierarchy < handle
    % MODELHIERARCHY Creates and stores the nodes that represent the hierarchy of a simulink top model
    
    % Copyright 2017 The MathWorks, Inc.
    
    properties (SetAccess = private, GetAccess = private)
        BlockDiagram  % Top model
        TopModelNode
        SubModelNode
        ChildParentMap
        AddedTree
        % Create a map so the uniqueIDs can be cleared from the
        % SubsystemCacheMap when the top model is closed.
        UniqueIDMap
    end
    
    methods
        function this = ModelHierarchy(model)
            if nargin < 1
                [msg, identifier] = fxptui.message('incorrectInputArgsModel');
                e = MException(identifier, msg);
                throwAsCaller(e);
            end
            if nargin > 0
                sys = find_system('type','block_diagram','Name',model);
                if isempty(sys)
                    [msg, identifier] = fxptui.message('modelNotLoaded',model);
                    e = MException(identifier, msg);
                    throwAsCaller(e);
                end
            end
            this.BlockDiagram = get_param(model,'Object');
            this.ChildParentMap = containers.Map('KeyType','char','ValueType','any');
            this.UniqueIDMap = containers.Map('KeyType','char','ValueType','any');
        end
    end
    
    methods        
        captureHierarchy(this);
        map = getChildParentCacheMap(this);
        addVariantToParent(this, slVariantObj, slParentObj);
        node = findNode(this, objProp, value);
        node = getTopModelNode(this);
        node = getSubModelNode(this);
        delete(this);
    end
    
    methods (Hidden)
        nodes = generateNodesForMATLABFunction(this, functionID);
        treeStruct = getAddedTreeData(this)
    end
    
    methods(Access = private)
       discoverSystemHierarchy(this, sysObj, sysNode);
       parentID = getParentIdentifier(this, sysObj);
       node = createNode(this, sysObj);
       unpopulate(this, node);
       modelName = getModelNameFromPath(this, path);
       mlfbNodes = resolveMLFBHierarchy(this, mlfbNodes);
       uniqueID = getIdentifierObject(this, sysObj);
       node = createMLFBNode(this, functionID, parentID, parentNode, isDummyID);
       updateDisplayPathOfMLFBNode(this, node);
    end
    
    methods (Static)
        function iconClass = getIconClass(node)
            % return the png file name that is used as an icon. This will
            % be set as iconClass, which will be used in JS.
            splitDisplayIconStr = strsplit(node.getDisplayIcon,'/' );
            splitDisplayIconStr = splitDisplayIconStr(numel(splitDisplayIconStr));
            iconLabel = strsplit(splitDisplayIconStr{1},'.');
            iconClass = iconLabel{1};
        end
        
        function [mlClass, icon] = getIconClassForMATLABFunction
            mlClass = 'MATLABFunction';
            icon = 'Functions2';
        end
        
        function displayPath = getDisplayPathForClient(path)
            % Return the relative display path. This path is used
            % to scope the results in UI when a tree node is selected
            % g1517455         
            displayPath = regexprep(path,'\s:\s\d+$','');
        end
    end
end
