function [runNames, selection] = getRunsWithProposals(this)
%GETRUNSWITHPROPOSALS Get the runs that contain proposals

%   Copyright 2011-2016 The MathWorks, Inc.

    runNames = {};
    selection = '';
    me = fxptui.getexplorer;
    if isempty(me); return; end
    if isempty(this.DAObject)
        return;
    end
    runNames = fxptui.getRunsWithProposalForSystem(this.DAObject.getFullName);
    ds = me.getdataset;    
    if all(cellfun(@isempty, runNames))     
        currentRunName = get_param(me.getFPTRoot.getDAObject.getFullName, 'FPTRunName');
        run = ds.getRun(currentRunName);
        runLocation = {run.getRunName};
    else
        runLocation = runNames{1};
    end
    selection = 0;
    
    % Update the application data with the default selection.
    appData = SimulinkFixedPoint.getApplicationData(me.getFPTRoot.getHighestLevelParent);   
    appData.ScaleUsing = runLocation;
    me.SelectedRunForApply = true;
end

