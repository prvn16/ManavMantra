function setCollectedRange(hDlg, hTag, ~) 
% SETDEFAULTDT Sets the default data type on the application data from the widget

% Copyright 2013-2016 The MathWorks, Inc.

val = hDlg.getWidgetValue(hTag);

% Early return for invalid explorer
% or unexpected widget
me = fxptui.getexplorer;
if isempty(me) || isempty(val)
    return; 
end

appData = SimulinkFixedPoint.getApplicationData(me.getFPTRoot.getHighestLevelParent);
oldval1 = appData.AutoscalerProposalSettings.isUsingDerivedMinMax;
oldval2 = appData.AutoscalerProposalSettings.isUsingSimMinMax;

try
    appData.AutoscalerProposalSettings.isUsingDerivedMinMax = (val == 2) || (val==0);
    appData.AutoscalerProposalSettings.isUsingSimMinMax = (val == 1) || (val == 0);
catch
    appData.AutoscalerProposalSettings.isUsingDerivedMinMax = oldval1;
    appData.AutoscalerProposalSettings.isUsingSimMinMax = oldval2;    
end