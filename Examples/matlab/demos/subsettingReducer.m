function subsettingReducer(~, intermValList, outKVStore)
% Reducer function for the SubsettingMapReduceExample 

% Copyright 2014 The MathWorks, Inc.

% get all intermediate results from the list
outVal = {};

while hasnext(intermValList)
    outVal = [outVal; getnext(intermValList)];
end
% Note that this approach assumes the concatenated intermediate values (the
% subset of the whole data) fit in memory.
    
add(outKVStore, 'Null', outVal);