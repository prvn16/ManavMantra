function [tf, value] = isGathered(partitionedArray)
%isGathered Is a partitioned array already gathered.
%   TF = isGathered(PA) returns TRUE if PartitionedArray PA has already been
%   gathered.

% Copyright 2016-2017 The MathWorks, Inc.

if istall(partitionedArray)
    partitionedArray = hGetValueImpl(partitionedArray);
end

tf = isa(partitionedArray, 'matlab.bigdata.internal.lazyeval.LazyPartitionedArray') && ...
    partitionedArray.ValueFuture.IsDone;
if tf
    value = partitionedArray.ValueFuture.Value;
else
    value = [];
end
end
