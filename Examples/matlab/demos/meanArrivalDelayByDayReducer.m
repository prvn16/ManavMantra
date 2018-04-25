function meanArrivalDelayByDayReducer(intermKey, intermValIter, outKVStore)
% Reducer function for the MeanByGroupMapReduceExample.

% Copyright 2014 The MathWorks, Inc.

n = 0;
s = 0;

% get all sets of intermediate results
while hasnext(intermValIter)
    intermValue = getnext(intermValIter);
    n = n + intermValue(1);
    s = s + intermValue(2);
end

% accumulate the sum and count
mean = s/n;
% add results to the output datastore
add(outKVStore,intermKey,mean);