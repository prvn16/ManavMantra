function registerGroupInLookUpMap(this, dataTypeGroup)
    % REGISTERGROUPINLOOKUPMAP this internal function registers all group
    % members in the internal reverse look up map. Using the reverse look up
    % map we have an indirect mapping of the composite elements of a group
    % (results) to the parent class (data type group) while honoring the
    % constraint that the children do not know about their parent
    
    % Copyright 2016 The MathWorks, Inc.
    
    % get the group members
    groupMembers = dataTypeGroup.getGroupMembers();
    
    % for all group members, add them to the look up
    for indx = 1:length(groupMembers)
        
        % register the current group member in the map to point to the
        % corresponding data type group
        this.registerResultInLookUpMap(groupMembers{indx}, dataTypeGroup);
    end
end