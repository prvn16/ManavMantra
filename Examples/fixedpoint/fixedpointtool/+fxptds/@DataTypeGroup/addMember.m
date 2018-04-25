function addMember(this, result)
    % ADDMEMBER This function provides an aggregation layer for the group, regarding
    % the group members. We keep a dictionary (map) of all the members,
    % where the value is the reference to the AbstractResult member and the
    % key is the string representation of the unique identifier of the
    % member. This function makes sure not to register results that we
    % already registered in the past.
	
    %   Copyright 2016-2017 The MathWorks, Inc.
    
    % get the unique identifier of the member
    % NOTE: currently there is a limitation on the unique keys if they come
    % from different data sets. There is a possibility of having clashes
    % between IDs that belong in different data sets. This issue should be
    % addressed in the future integration of a universal run for the data
    % typing engine. As of now this limitation is not an issue since we are
    % only processing results that come from a single run object. 
    memberKey = result.UniqueIdentifier.UniqueKey;
    
    % if the member is already registered, do not try to register it a
    % second time
    if ~this.members.isKey(memberKey)
        this.members(memberKey) = result;
        
        % use the common gateway registration interface to extract
        % information from the newly added member
        for index = 1:length(this.registrationInterface)
            this.registrationInterface{index}.register(this, result);
        end
    end
end