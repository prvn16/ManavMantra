function addlisteners(h)
%ADDLISTENERS  adds listeners to this object

%   Author(s): G. Taillefer
%   Copyright 2006-2010 The MathWorks, Inc.

h.listeners = handle.listener(h.daobject, 'NameChangeEvent', @(s,e)firepropertychange(h));
h.listeners(2) = handle.listener(h.daobject, findprop(h.daobject, 'MinMaxOverflowLogging'), 'PropertyPostSet', @(s,e)locpropertychange(e,h));
h.listeners(3) = handle.listener(h.daobject, findprop(h.daobject, 'DataTypeOverride'), 'PropertyPostSet', @(s,e)locpropertychange(e,h));
ed = DAStudio.EventDispatcher;
%listen to EventDispatcher HierarchyChangedEvent for Stateflow add/remove
h.listeners(4) = handle.listener(ed, 'HierarchyChangedEvent', @(s,e)lochierarchychanged(s,e,h));
h.listeners(5) = handle.listener(ed, 'ChildRemovedEvent', @(s,e)lochierarchychanged(s,e,h));
%--------------------------------------------------------------------------
function locpropertychange(ed,h)
% Update the display icons in the tree hierarchy.
h.firehierarchychanged;

%--------------------------------------------------------------------------
function lochierarchychanged(s,e,h)
if(~isa(h.daobject, 'Simulink.SubSystem'))
  return;
end
%Get the SF object that this node points to.
myobj = fxptui.sfchartnode.getSFChartObject(h.daobject);
%if our chart is not the one who's hierarchy changed, return
if(~isequal(myobj, e.Source)); return; end

% Get the previously selected node to reselect the node after the tree
% hierarchy is built. 
me = fxptui.getexplorer;
daobj = [];
selected_node = me.imme.getCurrentTreeNode;
% Cache the daobject to find the selected node later on since the selected
% node might be destroyed if it is part of the SF hierarchy.
if isa(selected_node,'fxptui.abstractnode')
    daobj = selected_node.daobject;
end
items = h.hchildren.values.toArray;
for idx = 1:numel(items)
    blk = items(idx);
    if(isempty(blk))
        continue;
    end
    hBlk = handle(blk);
    blk.releaseReference;
    unpopulate(hBlk);
    delete(hBlk);
end

h.hchildren.clear;
h.populate;

% Get the previously selected node after the tree is re-populated. If the
% selected node is valid, that means it was not part of the SF hierarchy.
if ~isempty(daobj) && ~isa(selected_node,'fxptui.abstractnode')
    selected_node = findPrevSelection(h, daobj);
end

% reselect the previously selected node if valid
if isa(selected_node,'fxptui.abstractnode')
    me.imme.selectTreeViewNode(selected_node);
else
    % Select the stateflow chart object to refresh the Dialog view.
    me.imme.selectTreeViewNode(h);
end
h.firehierarchychanged;

%-----------------------------------------------------------------
function selected_node = findPrevSelection(h, daobj)

selected_node = [];
items = h.hchildren.values.toArray;
for idx = 1:numel(items)
    blk = items(idx);
    if(isempty(blk))
        continue;
    end
    hBlk = handle(blk);
    if isequal(hBlk.daobject, daobj)
        selected_node = hBlk;
        break;
    else
        selected_node = findPrevSelection(hBlk, daobj);
    end
    if isa(selected_node,'fxptui.abstractnode'); break; end
end
% [EOF]
