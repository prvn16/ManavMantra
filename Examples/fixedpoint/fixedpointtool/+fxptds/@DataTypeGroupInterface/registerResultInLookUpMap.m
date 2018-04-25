function registerResultInLookUpMap(this, result, dataTypeGroup)
    % REGISTERRESULTINLOOKUPMAP this function registers a result
    % (AbstractResult) in the internal reverse look up map to get the group
    % from a result
    
    % Copyright 2016-2017 The MathWorks, Inc.
    
    % register the result to have the group in the map
    % use the unique identifier of the result as key, the data type
    % group as the value
    % NOTE: there is an assumption that the ID needs to be unique, this
    % is a limitation here to use an ID since MATLAB containers cannot
    % have objects as keys
    this.reverseResultLookUp(result.UniqueIdentifier.UniqueKey) = dataTypeGroup;
end