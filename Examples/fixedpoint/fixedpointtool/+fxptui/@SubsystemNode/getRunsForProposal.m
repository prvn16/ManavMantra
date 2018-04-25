function [runNames, selection] = getRunsForProposal(this)
% GETRUNNAMESFORPROPOSAL Gets the run names and the selected run for proposal.

% Copyright 2013-2016 The MathWorks, Inc.
    
   
    runNames = {};
    selection = '';
    me = fxptui.getexplorer;
    if isempty(me)
        return;
    end
    if isempty(this.getDAObject)
        return;
    end
    runNames = fxptui.getRunsForProposalForSystem(this.getDAObject.getFullName);
    ds = me.getdataset;   
    if all(cellfun(@isempty, runNames))
        currentRunName = get_param(me.getFPTRoot.getDAObject.getFullName, 'FPTRunName');
        run = ds.getRun(currentRunName);
        runNames = {run.getRunName};
    end
    
    selection = 0;
    % Update the application data based on the default selection.
    appData = SimulinkFixedPoint.getApplicationData(me.getFPTRoot.getDAObject.getFullName);
    appData.ScaleUsing = runNames{1};
    me.SelectedRunForProposal = true;
end
