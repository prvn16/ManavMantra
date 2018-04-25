function setIsAutoSignedness(hDlg, hTag, ~) 
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

switch hTag
    
    case 'propose_signedness' 
        oldval = propSettings.isAutoSignedness; 
        try
            propSettings.isAutoSignedness = logical(val);
        catch e
            propSettings.isAutoSignedness = oldval;
            fxptui.showdialog('defaulttypesetting', val,e.message);            
        end                 
    % no other tag is expected to handle by this function
end
