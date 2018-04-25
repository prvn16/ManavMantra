function countFlightsReducer(intermKeysIn, intermValsIter, outKVStore)
%countFlightsReducer Reducer function for mapreduce to count flights

% Copyright 2014 The MathWorks, Inc.

daysSinceEpoch = days(datetime(2008,12,31) - datetime(1987,10,1))+1;
dayArray = zeros(daysSinceEpoch, 1);

while hasnext(intermValsIter)
    dayArray = dayArray + getnext(intermValsIter);
end
add(outKVStore, intermKeysIn, dayArray);
end