function maxTimeReducer(~, intermValsIter, outKVStore)
% Copyright 2014 The MathWorks, Inc.

maxElaspedTime = -inf;
while hasnext(intermValsIter)
    maxElaspedTime = max(maxElaspedTime, getnext(intermValsIter));
end
add(outKVStore, 'MaxElaspedTime', maxElaspedTime);
end