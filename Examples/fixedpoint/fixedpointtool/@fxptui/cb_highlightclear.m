function cb_highlightclear
%CB_HIGHLIGHTCLEAR Clear highlighting for selected result
%   OUT = CB_HIGHLIGHTCLEAR(ARGS) <long description>

%   Copyright 2007-2014 The MathWorks, Inc.

me =  fxptui.getexplorer;
if isempty(me); return; end
selection = me.getSelectedListNodes;

if isempty(selection)
    fxptui.showdialog('generalnoselection');
    return;
end

if ~isa(selection,'fxptds.MATLABVariableResult')
    fxptds.AbstractActions.selectAndInvoke('unhilite');
end

% [EOF]
