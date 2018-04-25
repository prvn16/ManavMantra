%SimpleStrategy
% A partition that is based only on a index into the number of partitions.
%

%   Copyright 2015 The MathWorks, Inc.


classdef (Sealed) SimplePartition < handle
    properties (SetAccess = immutable)
        % The index of this partition with the total number of partitions.
        PartitionIndex;
        
        % The number of partitions in the strategy.
        NumPartitions;
    end
    
    methods
        % The main constructor.
        function obj = SimplePartition(partitionIndex, numPartitions)
            assert (isnumeric(partitionIndex) && isscalar(partitionIndex) && partitionIndex > 0 && mod(partitionIndex, 1) == 0);
            assert (isnumeric(numPartitions) && isscalar(numPartitions) && numPartitions > 0 && mod(numPartitions, 1) == 0);
            obj.PartitionIndex = partitionIndex;
            obj.NumPartitions = numPartitions;
        end
    end
end
