function setDefaultContainerForFloatOrInherit(hDlg, hTag, ~) 
% SETDEFAULTDT Sets the default data type on the application data from the widget

% Copyright 2013-2014 The MathWorks, Inc.

val = hDlg.getWidgetValue(hTag);

% Early return for empty widget value
if isempty(val)
    return; 
end

me = fxptui.getexplorer;
appData = SimulinkFixedPoint.getApplicationData(me.getFPTRoot.getHighestLevelParent);
propSettings = appData.AutoscalerProposalSettings; 

% call back to handle data type mis-match on property and ddg widget
switch hTag
           
    case 'edit_def_wl'
        propSettings.DefaultWordLength = int32(str2double(val));
        
    case 'edit_def_fl'
        propSettings.DefaultFractionLength = int32(str2double(val));
               
    case 'scale_selection'
        propSettings.isWLSelectionPolicy = ~logical(val);

    % no other tag is expected to handle by this function
end
