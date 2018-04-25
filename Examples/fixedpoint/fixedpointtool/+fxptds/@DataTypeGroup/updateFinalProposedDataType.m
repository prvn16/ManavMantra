function updateFinalProposedDataType(this, newDataType, proposalSettings)
   % UPDATEFINALPROPOSEDDATATYPE this function updates the proposed data 
   % type of the group. This API serves the use case where the user updates
   % the proposed data type and the whole group needs to be updated. It is
   % assumed that the new data type coming in this function has already
   % been verified to be a valid data type
   %
   % See also: fxptds.ResultGroupHandler/setProposedDTForGroup
   
   % Copyright 2017 The MathWorks, Inc.
   
   % the final proposed data type should be set during the normal proposal
   % workflow. If the final proposed data type is empty, there should be no
   % update
   if ~isempty(this.finalProposedDataType)
       groupMembers = this.getGroupMembers();
       
       for memberIndex = 1:length(groupMembers)
           % clear out the pre-determined alert levels
           groupMembers{memberIndex}.setAlert('');
           
           if groupMembers{memberIndex}.hasProposedDT && ~groupMembers{memberIndex}.isReadOnly
               
               % Set proposed dt string on the result
               groupMembers{memberIndex}.setProposedDT(newDataType);
           end
           
       end
       
      this.finalProposedDataType = SimulinkFixedPoint.DTContainerInfo(newDataType, []); 
      
      % update alerts for the group
      this.determineWarnings(proposalSettings);
        
      
   end
end