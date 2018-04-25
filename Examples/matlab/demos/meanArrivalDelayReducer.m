function meanArrivalDelayReducer(intermKey, intermValIter, outKVStore)
% Reducer function for the MeanMapReduceExample.

% Copyright 2014 The MathWorks, Inc.

% intermKey is 'PartialCountSumDelay'
count = 0;
sum = 0;
while hasnext(intermValIter)
   countSum = getnext(intermValIter);
   count = count + countSum(1);
   sum = sum + countSum(2);
end

meanDelay = sum/count;

% The key-value pair added to outKVStore will become the output of mapreduce 
add(outKVStore,'MeanArrivalDelay',meanDelay);