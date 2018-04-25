%PartitionStrategy
% The interface for classes that represent a partitioning strategy.
%
% A partitioning strategy tells the execution environment how a particular
% piece of execution or output should be partitioned. The different
% strategies modify how much control the execution environment has over the
% partitioning and with what information about the partition should be
% given to the data processor factory from ExecutionTask.
%

%   Copyright 2015-2017 The MathWorks, Inc.

classdef (Abstract) PartitionStrategy < handle
    properties (Abstract, SetAccess = private)
        % The default total number of partitions. This is allowed to be
        % empty.
        DesiredNumPartitions
        
        % A flag that indicates whether DesiredNumPartitions is the only
        % allowed value for number of partitions.
        IsNumPartitionsFixed
        
        % A flag that indicates whether the partitioning is based on an
        % underlying datastore.
        IsDatastorePartitioning
        
        % A flag that indicates whether the data will be explicitly
        % broadcasted to every partition.
        IsBroadcast;
        
        % A flag that indicates whether all data will be accessible by
        % every partition. This is true if the data is broadcasted or there
        % is only a single partition.
        IsDataReplicated;
    end
    
    methods (Abstract)
        % Create a partition object that represents the given partition
        % index.
        %
        %  partition = obj.createPartition(partitionIndex) creates a
        %  datastore based on the default desired partitioning.
        %
        %  partition = obj.createPartition(partitionIndex, numPartitions) creates a
        %  datastore based on numPartitions. If IsNumPartitionsFixed is
        %  true, then numPartitions must equal DesiredNumPartitions.
        %
        %  partition = obj.createPartition(partitionIndex, numPartitions, hadoopSplit)
        %  creates a datastore based on the provided datastore Hadoop split.
        %  The partitionIndex must match corresponding partition index of
        %  the Hadoop split. This argument is only supported if
        %  IsDatastorePartitioning is true.
        %
        partition = createPartition(obj, partitionIndex, numPartitions, varargin)
    end
    
    methods (Static)
        % Create a fixed NumPartitions or Datastore Partition Strategy.
        %
        % Syntax:
        %   strategy = PartitionStrategy.create(N) for a positive integer
        %   scalar N creates a partition strategy that has exactly N number
        %   of partitions.
        %
        %   strategy = PartitionStrategy.create(ds) creates a partition
        %   strategy that decides the partitioning based on the datastore
        %   ds.
        %
        function strategy = create(strategy)
            import matlab.bigdata.internal.executor.ArbitraryPartitionStrategy;
            import matlab.bigdata.internal.executor.DatastorePartitionStrategy;
            import matlab.bigdata.internal.executor.FixedNumPartitionStrategy;
            if isempty(strategy)
                strategy = ArbitraryPartitionStrategy();
            elseif isnumeric(strategy)
                strategy = FixedNumPartitionStrategy(strategy);
            elseif matlab.io.datastore.internal.shim.isDatastore(strategy)
                strategy = DatastorePartitionStrategy(strategy);
            else
                assert(false, 'Invalid input for partition strategy.');
            end
        end
        
        function strategy = align(varargin)
            % Align several partition strategies to form one that will work for all inputs.
            %
            % This is basic, it will just check the partition strategies
            % match or are broadcast.
            import matlab.bigdata.internal.executor.BroadcastPartitionStrategy;
            strategy = [];
            for ii = 1:nargin
                if varargin{ii}.IsBroadcast
                    continue;
                end
                
                if isempty(strategy)
                    strategy = varargin{ii};
                elseif ~isempty(varargin{ii})
                    if ~isequal(strategy, varargin{ii})
                        matlab.bigdata.internal.throw(...
                            message('MATLAB:bigdata:array:IncompatibleTallDatastore'));
                    end
                end
            end
            if isempty(strategy)
                strategy = BroadcastPartitionStrategy();
            end
        end
    end
end
