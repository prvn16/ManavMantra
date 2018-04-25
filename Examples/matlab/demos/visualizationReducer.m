function visualizationReducer(~, intermValList, outKVStore)
% get all intermediate results from the intermediate store

if hasnext(intermValList)
    outVal = getnext(intermValList);
else
    outVal = [];
end

while hasnext(intermValList)
    outVal = outVal + getnext(intermValList);
end
    
add(outKVStore, 'Null', outVal);