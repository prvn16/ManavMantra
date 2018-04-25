function setProposeForInherited(hDlg, hTag, ~) 
% SETDEFAULTDT Sets the default data type on the application data from the widget

% Copyright 2013-2014 The MathWorks, Inc.

val = hDlg.getWidgetValue(hTag);

% Early return for invalid explorer
% or unexpected widget
me = fxptui.getexplorer;
if isempty(me) || isempty(val)
    return; 
end

appData = SimulinkFixedPoint.getApplicationData(me.getFPTRoot.getHighestLevelParent);
propSettings = appData.AutoscalerProposalSettings; 
oldval = propSettings.ProposeForInherited;

try 
    propSettings.ProposeForInherited = logical(val);
catch e
    propSettings.ProposeForInherited = oldval;
    fxptui.showdialog('defaulttypesetting', val,e.message);
    
end
