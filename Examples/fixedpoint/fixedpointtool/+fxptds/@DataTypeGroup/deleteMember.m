function deleteMember(this, result)
    % DELETEMEMBER this function provides a public API to remove a member of
    % the group.
    
    % Copyright 2016 The MathWorks, Inc.
    
    % NOTE: (1) When a group member is deleted, the group properties will
    % NOT get updated. This is based on the assumptions of usage for group
    % formation and member deletion. In case the user selects to delete a
    % block from the model, which could cause a group member deletion, the
    % only active use case for the group is the result details of the rest
    % of the group members. In this scenario, the ranges of the group are
    % justifying the given proposal for the rest of the group members. The
    % proposal does not get updated at group member deletion event and hence
    % the ranges should support the explanation for the proposed data type.
    
    % NOTE: (2) The basic assumption of this function is that the result will be
    % valid until this point so that the unique identifier will still be
    % valid. The client of the delete functionality should ensure that the
    % result is not invalid before calling the deletion from the interface.
    % If this assumption is violated, the function will simply error out
    % exactly at the point where we read the unique key from the unique
    % identifier
    
    % if the member is part of the group, proceed to perform deletion
    % operations, otherwise error out
    if this.members.isKey(result.getUniqueIdentifier.UniqueKey)
        
        % remove member from the internal map of members
        this.members.remove(result.getUniqueIdentifier.UniqueKey);
    else
        DAStudio.error('SimulinkFixedPoint:autoscaling:invalidMemberDeletion');
    end
    
end