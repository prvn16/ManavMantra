function groupMembers = getGroupMembers(this)
    % GETGROUPMEMBERS This function returns a cell array that contains all the references
    % to the group members. We get the values of the internal map that we
    % keep all the registered members.
	
    %   Copyright 2016 The MathWorks, Inc.
    
    % get all the values from the map that contains references to the group
    % members
    groupMembers = this.members.values();
end