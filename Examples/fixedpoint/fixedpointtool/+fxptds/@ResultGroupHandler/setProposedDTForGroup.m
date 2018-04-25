function setProposedDTForGroup(this, result, value)
%% SETPROPOSEDDTFORGROUP runs sets proposedDT for all results in a group
%
% runObj is an instance of fxptds.FPTRun
%
% dtGroup is a char representing a shared group
%
% value is string representing the proposedDT

% Copyright 2016-2017 The MathWorks, Inc.
  
    % if code path is in "non-autoscaling" mode i.e. edits are from GUI
    
        % get all results in the group
        [groupMembers, group] = fxptds.Utils.getGroupResults(result);
        
        % update the final proposed data type for the group
        group.updateFinalProposedDataType(value, this.ProposalSettings);
        
        % Update the result in the model block datasets.
        for mIndex = 1:length(groupMembers)
            fxptds.Utils.updateProposedDTInModelRefDatasets(groupMembers{mIndex}, this.AllDatasets);
        end
end
