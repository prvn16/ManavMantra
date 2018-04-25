function this = BAETreeNode(TreeObject)
%BATCHSETTINGTREE Construct a TreeNode object to be shown in the Shortcut Editor.

%   Copyright 2010-2015 The MathWorks, Inc.

this = fxptui.BAETreeNode;
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
    this.PropertyBag = java.util.LinkedHashMap;
    if isa(this.TreeNode,'fxptui.sfchartnode') || isa(this.TreeNode,'fxptui.sfobjectnode')
        addStateflowListeners(this);
    else
        this.BlkListeners = handle.listener(this.daobject, 'ObjectChildAdded', @(s,e)objectadded(this,s,e));
        this.BlkListeners(end+1) = handle.listener(this.daobject, 'ObjectChildRemoved', @(s,e)objectremoved(this,s,e));
        this.BlkListeners(end+1) = handle.listener(this.daobject, 'NameChangeEvent', @(s,e)firehierarchychanged(this));
    end
    if isa(this.TreeNode.daobject,'Simulink.BlockDiagram')
        ed = DAStudio.EventDispatcher;
        this.BlkListeners(end+1) = handle.listener(this.daobject, 'PostSaveEvent', @(s,e)firehierarchychanged(this));
        this.BlkListeners(end+1) = handle.listener(ed, 'DirtyChangedEvent', @(s,e)firehierarchychanged(this));
    end
    if(~TreeObject.isMasked)
        populate(this);
    end

end

%------------------------------------------------------------------------
function subsys = createsubsys(blk)
clz = class(blk);
switch clz
  case 'Simulink.BlockDiagram'
    subsys = fxptui.blkdgmnode;
    subsys.daobject = blk;
  case 'Stateflow.EMChart'
    subsys = fxptui.emlnode;		
    subsys.daobject = blk.up;
  case {'Stateflow.Chart', ...
        'Stateflow.LinkChart', ...
        'Stateflow.TruthTableChart', ...
        'Stateflow.ReactiveTestingTableChart', ...
        'Stateflow.StateTransitionTableChart'}
    subsys = fxptui.sfchartnode;		
    subsys.daobject = blk.up;
  case {'Stateflow.State', ...
        'Stateflow.Box', ...
        'Stateflow.Function', ...
        'Stateflow.EMFunction', ...
        'Stateflow.TruthTable'}
    subsys = fxptui.sfobjectnode;		
    subsys.daobject = blk;
  otherwise
    subsys = fxptui.subsysnode;
    subsys.daobject = blk;	
end

if(isempty(subsys))
	return;
end
subsys.Name = blk.Path;
subsys.CachedFullName = fxptui.getPath(blk.getFullName);
% [EOF]
