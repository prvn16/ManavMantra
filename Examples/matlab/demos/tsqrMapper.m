function tsqrMapper(data, info, intermKVStore)
% Mapper function for the TSQRMapReduceExample.

% Copyright 2014 The MathWorks, Inc.

x = data{:,:};
x(any(isnan(x),2),:) = [];% Remove missing values

[~, r] = qr(x,0);

% intermKey = randi(4); % random integer key for partitioning intermediate results
intermKey = computeKey(info, 8);
add(intermKVStore,intermKey, r);

function key = computeKey(info, numPartitions)
% Helper function to generate a key for the tsqrMapper function.

fileSize = info.FileSize; % total size of the underlying data file
partitionSize = fileSize/numPartitions; % size in bytes of each partition
offset = info.Offset; % offset in bytes of the current read

key = ceil(offset/partitionSize);