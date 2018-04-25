%HadoopDatastorePartition
% A partition that is based on the Hadoop special-case form of partitioning
% on a file-based datastore.
%
% This has the ability to construct a datastore for the current partition.

%   Copyright 2015-2017 The MathWorks, Inc.

classdef (Sealed) HadoopDatastorePartition < handle
    properties (SetAccess = immutable)
        % The index of this partition with the total number of partitions.
        PartitionIndex;
        
        % The number of partitions in the strategy.
        NumPartitions;
    end
    
    properties (GetAccess = private, SetAccess = immutable)
        % The original datastore used to create this partition.
        OriginalDatastore;
        
        % If a Hadoop split was used to create this partition, this is that
        % split.
        HadoopSplit;
    end
    
    methods
        %CREATEDATASTORE Create a datastore containing all of the data
        %associated with this partition.
        function ds = createDatastore(obj)
            import matlab.bigdata.BigDataException;
            try
                ds = copy(obj.OriginalDatastore);
                matlab.io.datastore.internal.shim.initializeDatastore(ds, obj.HadoopSplit);
            catch err
                matlab.bigdata.internal.throw(err, 'IncludeCalleeStack', true);
            end
        end
    end
    
    methods
        % The main constructor.
        function obj = HadoopDatastorePartition(partitionIndex, numPartitions, originalDatastore, hadoopSplit)
            assert (isnumeric(partitionIndex) && isscalar(partitionIndex) && partitionIndex > 0 && mod(partitionIndex, 1) == 0);
            assert (isnumeric(numPartitions) && isscalar(numPartitions) && numPartitions > 0 && mod(numPartitions, 1) == 0);
            obj.PartitionIndex = partitionIndex;
            obj.NumPartitions = numPartitions;
            obj.OriginalDatastore = originalDatastore;
            obj.HadoopSplit = hadoopSplit;
        end
    end
end
