function tf = isBroadcast(partitionedArray)
%isBroadcast Is a partitioned array a broadcasted scalar or array
%   TF = isBroadcast(PA) returns TRUE if PartitionedArray PA is a known
%   scalar or broadcasted array.

% Copyright 2017 The MathWorks, Inc.

if istall(partitionedArray)
    partitionedArray = hGetValueImpl(partitionedArray);
end

if isa(partitionedArray, 'matlab.bigdata.internal.PartitionedArray')
    tf = isa(partitionedArray, 'matlab.bigdata.internal.lazyeval.LazyPartitionedArray') ...
        && partitionedArray.PartitionMetadata.Strategy.IsBroadcast;
else
    % Not partitioned, so must be broadcast
    tf = true;
end
