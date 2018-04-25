%DatastorePartitionStrategy
% A partitioning strategy based on partitioning a datastore directly.
%
% This strategy allows the execution environment to decide the partitioning
% based on the provided datastore.
%

%   Copyright 2015-2017 The MathWorks, Inc.

classdef (Sealed) DatastorePartitionStrategy < matlab.bigdata.internal.executor.PartitionStrategy
    properties (SetAccess = immutable)
        % The datastore object associated with this strategy.
        Datastore;
        
        % A boolean property that is true if and only if the underlying
        % datastore is partitionable.
        IsPartitionable;
    end
    
    % Overrides of PartitionStrategy properties.
    properties (SetAccess = private)
        DesiredNumPartitions = [];
        
        IsNumPartitionsFixed = false;
        
        IsDatastorePartitioning = true;
        
        IsBroadcast = false;
        
        IsDataReplicated = false;
    end

    methods
        % The main constructor.
        function obj = DatastorePartitionStrategy(ds)
            obj.Datastore = ds;
            obj.IsPartitionable = matlab.io.datastore.internal.shim.isPartitionable(ds);
            if obj.IsPartitionable
                % The result of numpartitions can be 0 if there exists no
                % underlying data. We bound it because we need to have at
                % least 1 partition for type propagation to work correctly.
                try
                    obj.DesiredNumPartitions = max(numpartitions(obj.Datastore), 1);
                catch err
                    matlab.bigdata.internal.throw(err, 'IncludeCalleeStack', true);
                end
            else
                obj.DesiredNumPartitions = 1;
            end
        end
        
        function partition = createPartition(obj, partitionIndex, numPartitions, hadoopSplit)
            import matlab.bigdata.internal.executor.DatastorePartition;
            import matlab.bigdata.internal.executor.HadoopDatastorePartition;
            import matlab.bigdata.internal.executor.NonPartitionableDatastorePartition;
            if nargin < 3
                numPartitions = obj.DesiredNumPartitions;
            end
            if nargin >= 4
                assert(matlab.io.datastore.internal.shim.isHadoopFileBased(obj.Datastore), ...
                    'Assertion failed: Attempted to initialize a non-Hadoop datastore with a Hadoop split.');
                partition = HadoopDatastorePartition(partitionIndex, numPartitions, obj.Datastore, hadoopSplit);
            elseif obj.IsPartitionable
                partition = DatastorePartition(partitionIndex, numPartitions, obj.Datastore);
            else
                assert(numPartitions == 1, ...
                    'Assertion failed: Attempted to initialize a non-partitionable datastore with multiple partitions.');
                partition = NonPartitionableDatastorePartition(obj.Datastore);
            end
        end
    end
end
