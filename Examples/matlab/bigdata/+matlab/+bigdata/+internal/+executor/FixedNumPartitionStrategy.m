%FixedNumPartitionStrategy
% A partitioning strategy based only on a total desired number of
% partitions.
%

%   Copyright 2015-2016 The MathWorks, Inc.

classdef (Sealed) FixedNumPartitionStrategy < matlab.bigdata.internal.executor.PartitionStrategy
    % Overrides of PartitionStrategy properties.
    properties (SetAccess = private)
        DesiredNumPartitions;
        
        IsNumPartitionsFixed = true;
        
        IsDatastorePartitioning = false;
        
        IsBroadcast = false;
        
        IsDataReplicated;
    end
    
    methods
        % The main constructor.
        function obj = FixedNumPartitionStrategy(numPartitions)
            assert (isnumeric(numPartitions) && isscalar(numPartitions) && numPartitions > 0 && mod(numPartitions, 1) == 0);
            obj.DesiredNumPartitions = numPartitions;
            obj.IsDataReplicated = (numPartitions == 1);
        end
        
        % Create a partition object that represents the given partition
        % index.
        function partition = createPartition(obj, partitionIndex, numPartitions)
            import matlab.bigdata.internal.executor.SimplePartition;
            if nargin >= 3
                assert (isequal(numPartitions, obj.DesiredNumPartitions));
            end
            partition = SimplePartition(partitionIndex, obj.DesiredNumPartitions);
        end
    end
end
