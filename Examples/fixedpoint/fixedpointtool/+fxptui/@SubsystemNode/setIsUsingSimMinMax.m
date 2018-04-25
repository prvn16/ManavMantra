function setIsUsingSimMinMax(hDlg, hTag, source) 
% SETDEFAULTDT Sets the default data type on the application data from the widget

% Copyright 2013-2016 The MathWorks, Inc.

val = hDlg.getWidgetValue(hTag);

if isa(source, 'DAStudio.DAObjectProxy')
    source = source.getMCOSObjectReference;
end
% identify the root model node from the GUI
me = fxptui.getexplorer;
if isempty(me); return; end

appData = SimulinkFixedPoint.getApplicationData(me.getFPTRoot.getHighestLevelParent);
oldval = appData.AutoscalerProposalSettings.isUsingSimMinMax;

if isempty(val)
    boolIsUsingSimMinMax = oldval;
else
    
    boolIsUsingSimMinMax = (val == 1);
end


appData.AutoscalerProposalSettings.isUsingSimMinMax = boolIsUsingSimMinMax;
end
