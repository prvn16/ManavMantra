%ArbitraryPartitionStrategy
% A partitioning strategy that allows the execution environment to choose
% partitioning.
%

%   Copyright 2015-2016 The MathWorks, Inc.

classdef (Sealed) ArbitraryPartitionStrategy < matlab.bigdata.internal.executor.PartitionStrategy
    % Overrides of PartitionStrategy properties.
    properties (SetAccess = private)
        DesiredNumPartitions = [];
        
        IsNumPartitionsFixed = false;
        
        IsDatastorePartitioning = false;
        
        IsBroadcast = false;
        
        IsDataReplicated = false;
    end
    
    methods
        % Create a partition object that represents the given partition
        % index.
        function partition = createPartition(~, partitionIndex, numPartitions)
            import matlab.bigdata.internal.executor.SimplePartition;
            partition = SimplePartition(partitionIndex, numPartitions);
        end
    end
end
