%GeneralizedPartitionwiseProcessor
% Data Processor that applies a partition-wise function handle to the input
% data without any restriction to input size.
%
% This will apply a function handle chunk-wise using the advanced
% partitionwise API. It will emit data continuously throughout a pass.
%
% See LazyTaskGraph for a general description of input and outputs.
% Specifically, each iteration will emit a 1 x NumOutputs cell array where
% each cell contains a chunk of output of the corresponding operation
% output.
%

%   Copyright 2017 The MathWorks, Inc.

classdef (Sealed) GeneralizedPartitionwiseProcessor < matlab.bigdata.internal.executor.DataProcessor
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
        PartitionIndex;
        
        % The number of partitions that this operation is partitioned into.
        NumPartitions
    end
    
    properties (SetAccess = private)
        % A buffer to hold both unused inputs as well as inputs prior to
        % having received at least one chunk per input.
        InputBuffer;
        
        % The relative input in each partition.
        RelativeIndexInPartition;
    end
    
    methods (Static)
        % Create a data processor factory that can be used by the execution
        % environment to construct instances of this class.
        function factory = createFactory(functionHandle, numOutputs, inputFutureMap, isInputReplicated)
            import matlab.bigdata.internal.lazyeval.InputMapProcessorDecorator;
            factory = @createProcessor;
            factory = InputMapProcessorDecorator.wrapFactory(factory, inputFutureMap);
            
            function dataProcessor = createProcessor(partition)
                import matlab.bigdata.internal.lazyeval.GeneralizedPartitionwiseProcessor;
                
                dataProcessor = GeneralizedPartitionwiseProcessor(copy(functionHandle), ...
                    partition.PartitionIndex, partition.NumPartitions, ...
                    numOutputs, isInputReplicated);
            end
        end
    end
    
    % Methods overridden in the DataProcessor interface.
    methods
        %PROCESS Process the next chunk of data.
        function output = process(obj, isLastOfInputsVector, varargin)
            
            obj.InputBuffer.add(isLastOfInputsVector, varargin{:});
            
            % We require at least one chunk per input to get size, type and
            % broadcast information.
            if any(~obj.InputBuffer.IsBufferInitialized)
                output = cell(0, obj.NumOutputs);
                return;
            end
            
            % Store numSlices to increment RelativeIndexInPartition later.
            % Broadcasts do not increment.
            numSlices = obj.InputBuffer.NumBufferedSlices;
            numSlices(obj.InputBuffer.IsInputSingleSlice) = 0;
            
            varargin = obj.InputBuffer.getAll();
            info = struct(...
                'PartitionId', obj.PartitionIndex, ...
                'NumPartitions', obj.NumPartitions, ...
                'IsBroadcast', obj.InputBuffer.IsInputSingleSlice, ...
                'IsLastChunk', isLastOfInputsVector, ...
                'RelativeIndexInPartition', obj.RelativeIndexInPartition);
            [obj.IsFinished, varargin, output{1 : obj.NumOutputs}] = ...
                feval(obj.FunctionHandle, info, varargin{:});
            
            isOutputEmpty = all(cellfun(@isempty, output));
            
            % Deal with unused inputs.
            if isempty(varargin)
                isMoreInputRequiredVector = ~isLastOfInputsVector;
                
            elseif iscell(varargin)
                % Deal with unused inputs. In particular, we do not add
                % broadcasts back to the buffer.
                varargin = num2cell(varargin);
                varargin(obj.InputBuffer.IsInputSingleSlice) = {cell(0, 1)};
                obj.InputBuffer.add(isLastOfInputsVector, varargin{:});
                
                numBufferedSlices = obj.InputBuffer.NumBufferedSlices;
                if isOutputEmpty
                    % If no output, we assume the calculation cannot
                    % continue only because there wasn't enough input. So
                    % we choose to request more input based on which
                    % has the fewest slices in the buffer.
                    bufferTooShortThreshold = max(max(numBufferedSlices), 1);
                    isBufferTooShortVector = numBufferedSlices < bufferTooShortThreshold;
                    isMoreInputRequiredVector = ~isLastOfInputsVector & isBufferTooShortVector;
                    if all(~isMoreInputRequiredVector)
                        isMoreInputRequiredVector(~isLastOfInputsVector) = true;
                    end
                else
                    % If output, we have to be careful because the function
                    % handle might expand data. If inputs are unused, it
                    % might be because there is no room in the output. So
                    % we choose to request more input only if that input is
                    % empty.
                    bufferTooShortThreshold = 1;
                    isBufferTooShortVector = numBufferedSlices < bufferTooShortThreshold;
                    isMoreInputRequiredVector = ~isLastOfInputsVector & isBufferTooShortVector;
                end
                
            elseif islogical(varargin)
                isMoreInputRequiredVector = ~varargin;
                
            else
                assert(false, 'Function handle returned unused inputs of type ''%s''.', class(varargin));
            end
            
            obj.RelativeIndexInPartition = obj.RelativeIndexInPartition + numSlices - obj.InputBuffer.NumBufferedSlices;
            obj.IsMoreInputRequired = ~obj.IsFinished & isMoreInputRequiredVector;
            
            isNotDeadlocked = obj.IsFinished ...
                || any(obj.IsMoreInputRequired) ...
                || ~isOutputEmpty;
            assert(isNotDeadlocked, 'A generalized partitionfun processor is in deadlock.');
        end
    end
    
    methods (Access = private)
        % Private constructor for factory method.
        function obj = GeneralizedPartitionwiseProcessor(functionHandle, partitionIndex, numPartitions, numOutputs, isInputReplicated)
            import matlab.bigdata.internal.lazyeval.InputBuffer;
            obj.NumOutputs = numOutputs;
            obj.FunctionHandle = functionHandle;
            obj.PartitionIndex = partitionIndex;
            obj.NumPartitions = numPartitions;
            obj.IsMoreInputRequired = true(size(isInputReplicated));
            obj.InputBuffer = InputBuffer(numel(isInputReplicated), isInputReplicated);
            obj.RelativeIndexInPartition = ones(1, numel(isInputReplicated));
        end
    end
end
