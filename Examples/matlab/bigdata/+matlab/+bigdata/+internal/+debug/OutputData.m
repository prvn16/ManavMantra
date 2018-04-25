%OutputData
% The outputs passed to an OutputHandler object.

%   Copyright 2017 The MathWorks, Inc.

classdef (Sealed) OutputData < handle
    properties
        % The ExecutionTask corresponding to this output.
        Task;
        
        % The partition index corresponding to this output.
        PartitionIndex;
        
        % The number of partitions for this task.
        NumPartitions
        
        % Whether this chunk is the last output of this partition.
        IsLastChunk;
        
        % The actual output.
        Output;
    end
end
