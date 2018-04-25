%PartitionwiseProcessor
% Data Processor that applies a partition-wise function handle to the input
% data.
%
% This will apply a function handle chunk-wise using the advanced
% partitionwise API. It will emit data continuously throughout a pass.
%
% See LazyTaskGraph for a general description of input and outputs.
% Specifically, each iteration will emit a 1 x NumOutputs cell array where
% each cell contains a chunk of output of the corresponding operation
% output.
%

%   Copyright 2015-2017 The MathWorks, Inc.

classdef (Sealed) PartitionwiseProcessor < matlab.bigdata.internal.executor.DataProcessor
    % Properties overridden in the DataProcessor interface.
    properties (SetAccess = private)
        IsFinished = false;
        IsMoreInputRequired;
    end
    
    properties (GetAccess = private, SetAccess = immutable)
        % The number of outputs from the function handle.
        NumOutputs;
        
        % The chunk-wise function handle.
        FunctionHandle;
        
        % The index of the current partition into the number of partitions
        % for the task.
        PartitionIndex = 1;
        
        % The number of partitions that this operation is partitioned into.
        NumPartitions
    end
    
    properties (SetAccess = private)
        % The relative index of the first slice in the next chunk to be
        % passed to the function handle.
        RelativeIndexInPartition = 1;
    end
    
    methods (Static)
        % Create a data processor factory that can be used by the execution
        % environment to construct instances of this class.
        function factory = createFactory(functionHandle, numOutputs, inputFutureMap, isInputReplicated)
            import matlab.bigdata.internal.lazyeval.BufferedZipProcessDecorator;
            import matlab.bigdata.internal.lazyeval.InputMapProcessorDecorator;
            factory = @createProcessor;
            factory = BufferedZipProcessDecorator.wrapFactory(factory, ...
                numOutputs, isInputReplicated, functionHandle.ErrorStack, ...
                'MaxNumSlices', functionHandle.MaxNumSlices, ...
                'AllowTallDimExpansion', true);
            factory = InputMapProcessorDecorator.wrapFactory(factory, inputFutureMap);
            function dataProcessor = createProcessor(partition)
                import matlab.bigdata.internal.lazyeval.PartitionwiseProcessor;
                
                dataProcessor = PartitionwiseProcessor(copy(functionHandle), partition.PartitionIndex, partition.NumPartitions, ...
                    numOutputs, inputFutureMap.NumOperationInputs);
            end
        end
    end
    
    % Methods overridden in the DataProcessor interface.
    methods
        function data = process(obj, isLastOfInputsVector, varargin)
            numSlices = matlab.bigdata.internal.lazyeval.determineNumSlices(varargin{:});
            info = struct(...
                'PartitionId', obj.PartitionIndex, ...
                'NumPartitions', obj.NumPartitions, ...
                'RelativeIndexInPartition', obj.RelativeIndexInPartition, ...
                'IsLastChunk', all(isLastOfInputsVector));
            [obj.IsFinished, data{1:obj.NumOutputs}] = feval(obj.FunctionHandle, info, varargin{:});
            obj.RelativeIndexInPartition = obj.RelativeIndexInPartition + numSlices;
        end
        
        function throwFromFunctionHandle(obj, err)
            obj.FunctionHandle.throwAsFunction(err);
        end
    end
    
    methods (Access = private)
        % Private constructor for factory method.
        function obj = PartitionwiseProcessor(functionHandle, partitionIndex, numPartitions, numOutputs, numInputs)
            obj.NumOutputs = numOutputs;
            obj.FunctionHandle = functionHandle;
            obj.PartitionIndex = partitionIndex;
            obj.IsMoreInputRequired = true(1, numInputs);
            obj.NumPartitions = numPartitions;
        end
    end
end
