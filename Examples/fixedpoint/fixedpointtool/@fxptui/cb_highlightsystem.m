function cb_highlightsystem
%CB_HIGHLIGHTSYSTEM highlights selected system in model

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.

me = fxptui.getexplorer;
if ~isempty(me)
    mdl = me.getTopNode.getDAObject;
    mdl.hilite('off');
end
fxptui.AbstractTreeNodeActions.selectAndInvoke('hiliteSystem');
% [EOF]