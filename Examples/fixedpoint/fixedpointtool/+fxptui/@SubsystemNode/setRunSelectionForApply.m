function setRunSelectionForApply(this, hDlg, hTag)
% SETRUNSELECTIONFORAPPLY Sets the run selection made for aplying data
%types.

%   Copyright 2013-2016 The MathWorks, Inc.

    me = fxptui.getexplorer;
    if isempty(me)
        return;
    end
    appData = SimulinkFixedPoint.getApplicationData(me.getFPTRoot.getHighestLevelParent);
    value = hDlg.getWidgetValue(hTag);
    [runNames, ~] = this.getRunsWithProposals;
    run = runNames{value+1};
    if isempty(run)
        % Should never hit this condition. Something is really wrong if it
        % does.
        me.SelectedRunForApply = false;
    else
        me.SelectedRunForApply = true;
        appData.ScaleUsing = run;
    end
end
