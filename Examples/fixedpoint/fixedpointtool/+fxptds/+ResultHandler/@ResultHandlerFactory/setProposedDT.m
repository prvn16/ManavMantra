function setProposedDT(this, result, value, updateModelBlocksAndAlerts)
%% SETPROPOSEDDT runs sets proposedDT for a result
%
% result is an instance of fxptds.AbstractResult
%
% value is string representing the proposeddt of the result

% Copyright 2016 The MathWorks, Inc.
    
    % Set proposed dt of the result with input value 
    result.setProposedDT(value);
    
    % if result is editable, update model blocks datasets and update alerts
    if updateModelBlocksAndAlerts
        % ProposalSettings are empty when appData is empty
        % appData is fetched from model context is which empty for data
        % objects
        if ~isempty(this.ProposalSettings)
            % reset the alert level 
            result.setAlert('');
            
            % get proposal diagnostics interface
            proposalDiagnosticsInterface = SimulinkFixedPoint.ProposalDiagnosticInterface.getInterface(this.ProposalSettings);
            
            % get the alert level for the result (no group)
            alertLevel = proposalDiagnosticsInterface.getResultAlertLevel(result, fxptds.DataTypeGroup.empty());
            
            % set the alert level on the result
            result.setAlert(lower(char(alertLevel)));
        end
        
        % Update the result in the model block.
        fxptds.Utils.updateProposedDTInModelRefDatasets(result, this.AllDatasets);
    end
end
