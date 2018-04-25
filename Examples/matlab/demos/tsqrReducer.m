function tsqrReducer(intermKey, intermValIter, outKVStore)
% Reducer function for the TSQRMapReduceExample.

% Copyright 2014 The MathWorks, Inc.

x = [];

while (intermValIter.hasnext)
    x = [x;intermValIter.getnext];
end
% Note that this approach assumes the concatenated intermediate values fit
% in memory. Consider increasing the number of reduce tasks (increasing the
% number of partitions in the tsqrMapper) and adding more iterations if it
% does not fit in memory.

[~, r] =qr(x,0);

outKVStore.add(intermKey,r);