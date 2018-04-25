function this = BAESubMdlNode(TreeObject)
%BATCHSETTINGTREE Construct a TreeNode object to be shown in the Shortcut Editor.

%   Copyright 2010-2012 The MathWorks, Inc.

this = fxptui.BAESubMdlNode;

% assert TreeObject is a block diagram object

if ~isempty(TreeObject)
    this.TreeNode = createsubsys(TreeObject);
    try
        this.DataTypeOverride = get_param(this.TreeNode.daobject.getFullName,'DataTypeOverride');
    catch e %#ok
        this.DataTypeOverride =  'UseLocalSettings';
    end
    try
        this.MinMaxOverflowLogging = get_param(this.TreeNode.daobject.getFullName,'MinMaxOverflowLogging');
    catch e %#ok
        this.MinMaxOverflowLogging = 'UseLocalSettings';
    end
    try
        this.DataTypeOverrideAppliesTo = get_param(this.TreeNode.daobject.getFullName,'DataTypeOverrideAppliesTo');
    catch e %#ok
        this.DataTypeOverrideAppliesTo = 'AllNumericTypes';
    end
    
    this.daobject = this.TreeNode.daobject;

    this.Parent = [];
    
    % add all event listeners
    this.BlkListeners = handle.listener(this.daobject, 'ObjectChildAdded', @(s,e)objectadded(this,s,e));
    this.BlkListeners(end+1) = handle.listener(this.daobject, 'ObjectChildRemoved', @(s,e)objectremoved(this,s,e));
    this.BlkListeners(end+1) = handle.listener(this.daobject, 'NameChangeEvent', @(s,e)firehierarchychanged(this));  
    
    this.BlkListeners(end+1) = handle.listener(this.daobject, 'CloseEvent', @(s,e)locdestroy(this));
    this.BlkListeners(end+1) = handle.listener(this.daobject, 'PostSaveEvent', @(s,e)firehierarchychanged(this));
    ed = DAStudio.EventDispatcher;
    this.BlkListeners(end+1) = handle.listener(ed, 'DirtyChangedEvent', @(s,e)firehierarchychanged(this));

    populate(this);

end

%------------------------------------------------------------------------
function subsys = createsubsys(blk)

subsys = fxptui.blkdgmnode;
subsys.daobject = blk;

subsys.Name = blk.Path;
subsys.CachedFullName = fxptui.getPath(blk.getFullName);

%------------------------------------------------------------------------
function locdestroy(h)
% This is to handle cases where the model is closed
baexplr = fxptui.BAExplorer.getBAExplorer;

if ~isequal(h, baexplr.getTopNode)
   % do nothing if it is top model
   allChildren = baexplr.getRoot.children;
   for idx = 1:length(allChildren)
       if isequal(allChildren(idx), h)
           allChildren(idx) = [];
           break;
       end
   end
   baexplr.getRoot.children = allChildren;
end

% [EOF]
