function addStateflowListeners(this)
%ADDSTATEFLOWLISTENERS Adds listeners specific to stateflow add/remove

%   Copyright 2011 The MathWorks, Inc.

ed = DAStudio.EventDispatcher;
if isa(this.TreeNode,'fxptui.sfchartnode')
    %listen to EventDispatcher HierarchyChangedEvent for Stateflow add/remove
    this.BlkListeners = handle.listener(ed, 'HierarchyChangedEvent', @(s,e)locfirehierarchychanged(this,s,e));
    this.BlkListeners(end+1)= handle.listener(ed, 'ChildRemovedEvent', @(s,e)locfirehierarchychanged(this,s,e));
    this.BlkListeners(end+1) = handle.listener(this.TreeNode.daobject, 'NameChangeEvent', @(s,e)firepropertychange(this));
else
    this.BlkListeners = handle.listener(ed, 'PropertyChangedEvent', @(s,e)firepropertychange(this));
end

%--------------------------------------------------------
function locfirehierarchychanged(h,s,e) %#ok
if(~isa(h.daobject, 'Simulink.SubSystem'))
  return;
end
%Get the SF object that this node points to.
myobj = fxptui.sfchartnode.getSFChartObject(h.daobject);
%if our chart is not the one who's hierarchy changed, return
if(~isequal(myobj, e.Source)); return; end

children = h.Children;
for idx = 1:numel(children)
  child = children{idx};
  if ~isempty(child)
      disconnect(child);
      unpopulate(child);
      delete(child);
  end
end
h.Children = [];
h.populate;
h.firehierarchychanged;


% [EOF]
