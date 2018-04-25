%PartitionMetadata
% An object that represents how a partitioned array has been partitioned.

%   Copyright 2016 The MathWorks, Inc.

classdef PartitionMetadata < handle
    properties (SetAccess = immutable)
        % The underlying partition strategy object that defines how the
        % execution environment will partition evaluation.
        Strategy;
    end
    
    properties (Dependent)
        % The underlying datastore that will be used to generate the
        % partitioning. This can be empty if no such datastore exists.
        Datastore;
    end
    
    methods
        function obj = PartitionMetadata(strategy)
            % Create a partition metadata object from the given strategy
            % object. The strategy object can be either:
            %  - A PartitionStrategy object
            %  - A datastore
            %  - The desired number of partitions
            %  - Empty, which indicates arbitrary partitioning.
            
            import matlab.bigdata.internal.executor.PartitionStrategy;
            if ~isa(strategy, 'matlab.bigdata.internal.executor.PartitionStrategy')
                strategy = matlab.bigdata.internal.executor.PartitionStrategy.create(strategy);
            end
            obj.Strategy = strategy;
        end
        
        function out = get.Datastore(obj)
            if obj.Strategy.IsDatastore
                out = obj.Strategy.Datastore;
            else
                out = [];
            end
        end
    end
    
    methods (Static)
        function obj = align(varargin)
            % Align several partition metadata objects to form one that will
            % work for all the partitioned arrays.
            import matlab.bigdata.internal.executor.PartitionStrategy;
            import matlab.bigdata.internal.PartitionMetadata;
            allPartitionMetadata = vertcat(PartitionMetadata.empty(), varargin{:});
            strategy = PartitionStrategy.align(allPartitionMetadata.Strategy);
            obj = PartitionMetadata(strategy);
        end
    end
end
