function cb_plotdiffinfigure
%CB_PLOTINFIGURE   Callback for "Time Series in Figure" action.

%   Copyright 2006-2014 The MathWorks, Inc.

me =  fxptui.getexplorer;
if isempty(me); return; end
selection = me.getSelectedListNodes;

if isempty(selection)
    fxptui.showdialog('generalnoselection');
    return;
end

if isa(selection,'fxptds.AbstractSimulinkResult')
    fxptds.AbstractActions.selectAndInvoke('plotDifference');
end

% [EOF]
