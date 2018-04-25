function successfulProposal = proposeDataType(this, resultsScope, result, proposedDataType, proposalSettings)
    % PROPOSEDATATYPE function provides best precision data types for fixed
    % point workflows. The function operates on a single member of a data
    % type group and uses information coming from the individual result and
    % the group it belongs to in order to calculate the best precision
    % scaling data type.
	
    %   Copyright 2016-2017 The MathWorks, Inc.
    
    % currently each member is allowed to deviate internally from the
    % proposal that the group has decided. These special cases of behavior
    % are captured in a special handling function that decided whether or
    % not a member needs to deviate from the grouped proposal.
    % NOTE: this functionality needs to be abstracted out into a behavioral
    % pattern that will be able to be customized for different kinds of
    % groups (i.e. single precision groups may have different needs for
    % this kind of deviation)
    specialHandlingDT = this.specialHandlingForResults(resultsScope, result, proposedDataType, proposalSettings);
    
    % if the result needs to deviate from the group proposal, the special
    % handling functionality will provide the alternative proposal for the
    % particular result. If the result does not need to deviate, the
    % special handling data type will be empty. In this case, we apply the
    % proposed data type that came from the group
    if isempty(specialHandlingDT)
        result.setProposedDT(proposedDataType);
        
        % if at least one member of the group accepted the proposal, then
        % the proposal was succesful
        successfulProposal = true;
    else
        
        % if the result needs to deviate from the group data type we apply
        % the special handling data type
        result.setProposedDT(specialHandlingDT);
        
        % if none of the group members accepted the proposal based on
        % special handling (i.e. locked, outside system under design etc.)
        % then the proposal is deemed as not successful. This will cause
        % the final proposed data type of the group to remail empty, even
        % if we had an initial proposal. 
        successfulProposal = false;
    end
end