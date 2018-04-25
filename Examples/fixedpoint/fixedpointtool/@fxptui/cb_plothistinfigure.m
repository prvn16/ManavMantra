function cb_plothistinfigure
%CB_PLOTHISTINFIGURE   Callback for "Histogram in Figure" action.

%   Copyright 2006-2014 The MathWorks, Inc.

me =  fxptui.getexplorer;
if isempty(me); return; end
selection = me.getSelectedListNodes;

if isempty(selection)
    fxptui.showdialog('generalnoselection');
    return;
end

if isa(selection,'fxptds.AbstractSimulinkResult') || isa(selection, 'fxptds.MATLABExpressionResult')
    fxptds.AbstractActions.selectAndInvoke('plotHistogram');
end

% [EOF]
