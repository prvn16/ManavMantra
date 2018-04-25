function cb_compareruns
%CB_PLOTINFIGURE   Callback for comparing runs.

%   Copyright 2011-2014 The MathWorks, Inc.

me =  fxptui.getexplorer;
if isempty(me); return; end
selection = me.getSelectedListNodes;

if isempty(selection)
    fxptui.showdialog('generalnoselection');
    return;
end

if isa(selection,'fxptds.AbstractSimulinkResult')
    fxptds.AbstractActions.selectAndInvoke('compareRuns');
end
