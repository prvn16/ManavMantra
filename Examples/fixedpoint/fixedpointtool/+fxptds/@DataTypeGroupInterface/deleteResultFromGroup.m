function deleteResultFromGroup(this, result)
    % DELETERESULTFROMGROUP function is an API exposed in the data type
    % group interface to facilitate the delete workflow that exists in the
    % Fixed Point Tool workflows. The API accepts a result object, looks up
    % the corresponding group via the reverse look up map, and calls the
    % delete operation on the appropriate group
    
    % Copyright 2016 The MathWorks, Inc.
    
    if this.reverseResultLookUp.isKey(result.getUniqueIdentifier.UniqueKey)
        % get the corresponding group for the result
        group = this.reverseResultLookUp(result.getUniqueIdentifier.UniqueKey);
        
        % remove the member from the group
        group.deleteMember(result);
    end
    
end