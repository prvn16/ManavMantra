function setFinalProposedDataType(this, finalProposedDataType, resultsScope, proposalSettings)
    % SETFINALPROPOSEDDATATYPE This function keeps a record of the final proposed data type for the
    % group and propagates the proposal to the members internally.
    % Currently the members are allowed to deviate from the proposal given
    % to the group based on specific conditions (i.e. the group member is
    % outside the system under design).
    
    %   Copyright 2016-2017 The MathWorks, Inc.
    
    groupMembers = this.getGroupMembers();
    
    dataTypeAccepted = false;
    for gIndex = 1:length(groupMembers)
        memberAccepted = this.proposeDataType(...
            resultsScope, ...
            groupMembers{gIndex}, ...
            finalProposedDataType, ...
            proposalSettings);
        
        dataTypeAccepted = dataTypeAccepted || memberAccepted;
    end
    
    % propagate the proposed data type to all the group members internally
    % if at least one of the group members accepted the proposed data
    % type, register the final proposed data type for the group,
    % otherwise the proposed data type was rejected by special handling
    % and hence it should remain empty
    if dataTypeAccepted
                
        % keep a record of the final proposed data type. Comparing the final
        % proposed data type with the initially proposed data type can yield
        % interesting information about the reasoning of the proposal: i.e. in
        % FPGA workflows if a data type with wordlength greater than 128 is
        % proposed initially, it will get trimmed to 128. Comparing the initial
        % with the final will allow us to warn the user about this situation
        % that might cause precision loss or overflows
        this.finalProposedDataType =  SimulinkFixedPoint.DTContainerInfo(tostring(finalProposedDataType), []);
    end
end