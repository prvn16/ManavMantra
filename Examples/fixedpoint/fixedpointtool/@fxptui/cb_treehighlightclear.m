function cb_treehighlightclear
%CB_TREEHIGHLIGHTCLEAR Clear highlighting for selected tree node. This is
%purely a testing API

%   Copyright 2014 The MathWorks, Inc.

me = fxptui.getexplorer;
if isempty(me); return; end
selection = me.getSelectedTreeNode;

if isempty(selection);return;end

if ~isa(selection,'fxptui.MATLABFunctionNode')
    fxptui.AbstractTreeNodeActions.selectAndInvoke('unhiliteSystem');
end
