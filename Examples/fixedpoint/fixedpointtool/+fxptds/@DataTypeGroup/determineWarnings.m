function determineWarnings(this, proposalSettings)
    % DETERMINEWARNINGS this function operates on the members of a group
    % to collect the alert levels and warnings based on the proposal
    % workflow. Each member is tested against business rules imposed by the
    % Fixed Point Tool and helpful comments for the user are generated for
    % each member. The group will consolidate this information and provide
    % a way to propagate warnings or alerts if necessary. Currently, there
    % is a mechanism to propagate error warnings within a group. If a group
    % member indicates an error, then the whole group assumes the same
    % error and hence all the members of the group inherit the same error
    
    % Copyright 2016 The MathWorks, Inc.
    
    % get proposal diagnostics interface
    proposalDiagnosticsInterface = SimulinkFixedPoint.ProposalDiagnosticInterface.getInterface(proposalSettings);
    
    % initialize group alert level to green
    groupAlertLevel = SimulinkFixedPoint.ProposalDiagnostics.AlertLevelsEnum.Green;
    
    % get group members
    groupMembers = this.getGroupMembers();
    
    if numel(groupMembers) > 1
        % get the alert level for the group (not for individual results)
        groupAlertLevel = proposalDiagnosticsInterface.getGroupAlertLevel(this);
    end
    
    % intialize all alerts for the members
    allMembersAlerts = SimulinkFixedPoint.ProposalDiagnostics.AlertLevelsEnum.empty(0,numel(groupMembers));
    for memberIndex = 1:numel(groupMembers)
        allMembersAlerts(memberIndex) =  proposalDiagnosticsInterface.getResultAlertLevel(groupMembers{memberIndex}, this);
    end
    
    % get the final alert level
    finalAlertLevel = SimulinkFixedPoint.ProposalDiagnostics.AlertLevelsEnum.max([groupAlertLevel allMembersAlerts]);
    
    % if the final alert level is of the highest level, propagate the
    % highest level to every member
    if finalAlertLevel == SimulinkFixedPoint.ProposalDiagnostics.AlertLevelsEnum.Red
       allMembersAlerts = repmat(finalAlertLevel, 1, numel(groupMembers));
    end
    
    % propagate the alert level to the members
    this.propagateAlertLevel(allMembersAlerts);
    
end



