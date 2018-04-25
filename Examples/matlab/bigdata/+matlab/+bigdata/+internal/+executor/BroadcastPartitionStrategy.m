%BroadcastPartitionStrategy
% A partitioning strategy specifically for broadcast output.
%
% This will always consist of a single partition.

%   Copyright 2015-2017 The MathWorks, Inc.

classdef (Sealed) BroadcastPartitionStrategy < matlab.bigdata.internal.executor.PartitionStrategy
    % Overrides of PartitionStrategy properties.
    properties (SetAccess = private)
        DesiredNumPartitions = 1;
        
        IsNumPartitionsFixed = false;
        
        IsDatastorePartitioning = false;
        
        IsBroadcast = true;
        
        IsDataReplicated = true;
    end
    
    methods
        function partition = createPartition(~, partitionIndex, numPartitions)
            import matlab.bigdata.internal.executor.SimplePartition;
            assert(partitionIndex == 1, ...
                'Assertion failed: Attempted to initialize a broadcast partition with partition index not equal to 1.');
            if nargin >= 3
                assert(numPartitions == 1, ...
                    'Assertion failed: Attempted to initialize a broadcast partition with number of partitions not equal to 1.');
            end
            partition = SimplePartition(1, 1);
        end
    end
end
