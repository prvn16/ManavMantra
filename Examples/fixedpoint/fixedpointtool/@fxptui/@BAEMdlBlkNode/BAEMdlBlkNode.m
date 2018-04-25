function this = BAEMdlBlkNode(TreeObject)
%BAEMDLBLKNODE Construct a model reference block TreeNode object to be shown in the Shortcut Editor.

%   Copyright 2010-2015 The MathWorks, Inc.

this = fxptui.BAEMdlBlkNode;

% assert TreeObject is a block diagram object

if ~isempty(TreeObject)
    this.TreeNode = createsubsys(TreeObject);
    subModelName = this.TreeNode.daobject.ModelName; 
    try
        this.DataTypeOverride = get_param(subModelName,'DataTypeOverride');
    catch e %#ok
        this.DataTypeOverride =  'UseLocalSettings';
    end
    try
        this.MinMaxOverflowLogging = get_param(subModelName,'MinMaxOverflowLogging');
    catch e %#ok
        this.MinMaxOverflowLogging = 'UseLocalSettings';
    end
    try
        this.DataTypeOverrideAppliesTo = get_param(subModelName,'DataTypeOverrideAppliesTo');
    catch e %#ok
        this.DataTypeOverrideAppliesTo = 'AllNumericTypes';
    end
    
    % object should points to model block or sub-model? 
    this.daobject = this.TreeNode.daobject;
    this.modelName = subModelName; 
    this.Parent = [];
    
    % add all event listeners
    this.BlkListeners = handle.listener(this.daobject, 'ObjectChildAdded', @(s,e)objectadded(this,s,e));
    this.BlkListeners(end+1) = handle.listener(this.daobject, 'ObjectChildRemoved', @(s,e)objectremoved(this,s,e));
    this.BlkListeners(end+1) = handle.listener(this.daobject, 'NameChangeEvent', @(s,e)firehierarchychanged(this));
    ed = DAStudio.EventDispatcher;
    this.BlkListeners(end+1) = handle.listener(ed,'PropertyChangedEvent', @(s,e)locpropertychange(this,s,e));
    
    % should keep populating? 
%     populate(this);

end

%------------------------------------------------------------------------
function subsys = createsubsys(blk)

subsys = fxptui.mdlrefnode;
subsys.daobject = blk;

subsys.Name = blk.Path;
subsys.CachedFullName = fxptui.getPath(blk.getFullName);

%--------------------------------------------------------------------------
function locpropertychange(h,~,e)


if eq(e.Source, h.daobject)
    isSrcProtectedModel = strcmpi(e.Source.ProtectedModel, 'on');
    if ~isequal(e.Source.ModelName, h.modelName)
        bae = fxptui.BAExplorer.getBAExplorer;
        root = bae.getRoot;
        if ~isSrcProtectedModel           
            try
                load_system(e.Source.ModelName)
                mdlObj = get_param(e.Source.ModelName,'Object');
                mdlNode = find(root,'daobject',mdlObj, '-isa','fxptui.BAETreeNode'); %#ok<*GTARG>
                if isempty(mdlNode)
                    addNodeToTree(bae, mdlObj);
                end
                curNewModel = e.Source.ModelName;
            catch exception
                % Model is probably not on path. Ignore and continue
                curNewModel = [];
            end
        else
            curNewModel = [];
        end
        try
            % Unpopulate the old model if it is not referenced anywhere
            [refMdls, ~] = find_mdlrefs(bae.getTopNode.daobject.getFullName);
            if isempty(intersect(refMdls,h.modelName))
                removeModelNodes(bae,h.modelName);
            end
        catch exception %#ok<*NASGU>
            % One of the models is not on path.
            foundMdlBlkUsage = checkModelInUse(root, h.modelName);
            if ~foundMdlBlkUsage
                mdlBlks = find(root,'-isa','fxptui.BAETreeNode','modelName',h.modelName);
                if numel(mdlBlks == 1)
                    removeModelNodes(bae,h.modelName);
                end
            end
        end
        if ~isempty(h.modelName) && root.SubMdlToBlkMap.isKey(h.ModelName)
            mdlblks = root.SubMdlToBlkMap.getDataByKey(h.modelName);
            newlist = [];
            % remove this block from the list
            for i = 1:length(mdlblks)
                if ~isequal(mdlblks(i), h)
                    if isempty(newlist)
                        newlist = mdlblks(i);
                    else
                        newlist(end+1) = mdlblks(i); %#ok<AGROW>
                    end
                end
            end
            if isempty(newlist)
                root.SubMdlToBlkMap.deleteDataByKey(h.modelName);
            else
                root.SubMdlToBlkMap.insert(h.modelName, newlist);
            end
        end
        h.modelName = curNewModel;
        if ~isempty(find_system(0,'type','block_diagram','Name',e.Source.ModelName)) 
            root.SubMdlToBlkMap.insert(h.modelName, h);
            mdlObj = get_param(h.modelName,'Object');
            mdlNode = find(root,'daobject',mdlObj, '-isa','fxptui.BAETreeNode');
            % Set the properties to match the properties of the new model.
            h.DataTypeOverride = mdlNode.DataTypeOverride;
            h.MinMaxOverflowLogging = mdlNode.MinMaxOverflowLogging;
            h.DataTypeOverrideAppliesTo = mdlNode.DataTypeOverrideAppliesTo;
        end
    end
    h.firepropertychange;
    h.firehierarchychanged;
end

%-------------------------------------------------------------------------
function modelNames = getModelNames(bae, child)
modelNames = {};
if isa(child.daobject,'Simulink.ModelReference')
    modelNames = {child.daobject.ModelName};
    mdlObj = get_param(modelNames{1},'Object');
    child = find(bae.getRoot,'daobject',mdlObj, '-isa','fxptui.BAETreeNode');
end
ch = child.getHierarchicalChildren;
for i = 1:length(ch)
    modelNames = [modelNames, getModelNames(bae, ch(i))]; %#ok<AGROW>
end

%--------------------------------------------------------------------
function removeModelNodes(bae,mdlName)

isLoaded =  ~isempty(find_system(0, 'type', 'block_diagram', 'Name', mdlName));
if ~isLoaded; return; end
bd = get_param(mdlName,'Object');
mdlNode = find(bae.getRoot,'daobject',bd, '-isa','fxptui.BAETreeNode'); %#ok<*GTARG>
children = mdlNode.getHierarchicalChildren;
modelNames = {};
for i = 1:length(children)
    modelNames = [modelNames, getModelNames(bae, children(i))]; %#ok<AGROW>
end
if ~isempty(mdlNode)
    removeChild(bae.getRoot, mdlNode);
end
for i = 1:length(modelNames)
    mdlObj = get_param(modelNames{i},'Object');
    mdlNode = find(bae.getRoot,'daobject',mdlObj, '-isa','fxptui.BAETreeNode');
    if ~isempty(mdlNode)
        removeChild(bae.getRoot, mdlNode);
    end
end
    % [EOF]
