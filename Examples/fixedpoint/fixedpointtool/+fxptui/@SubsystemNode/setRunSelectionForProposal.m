function setRunSelectionForProposal(this, hDlg, hTag)
% SETRUNSELECTIONFORPROPOSAL Set the run selection made for proposing data types

%   Copyright 2013-2016 The MathWorks, Inc.

    me = fxptui.getexplorer;
    if isempty(me)
        return;
    end      
    appData = SimulinkFixedPoint.getApplicationData(me.getFPTRoot.getHighestLevelParent);
    value = hDlg.getWidgetValue(hTag);
    [runNames, ~] = this.getRunsForProposal;
    run = runNames{value+1};
    
    if isempty(run)
        % Should never hit this condition. Something is really wrong if it
        % does.
        me.SelectedRunForProposal = false;
    else
        me.SelectedRunForProposal = true;
        appData.ScaleUsing = run;
    end
end
