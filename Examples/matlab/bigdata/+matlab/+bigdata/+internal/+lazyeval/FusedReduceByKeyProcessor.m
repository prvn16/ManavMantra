%FusedReduceByKeyProcessor
% Data Processor that performs a reduction of the current partition to a
% single chunk per key. This differs from the ordinary
% ReduceByKeyProcessor in the respect that different groups of
% input/output variables can have different lengths per key.
%
% This will apply a rolling reduction to all input. It will emit the final
% result of this rolling reduction once all input has been received.
%

%   Copyright 2016-2017 The MathWorks, Inc.

classdef (Sealed) FusedReduceByKeyProcessor < matlab.bigdata.internal.executor.DataProcessor
    % Properties overridden in the DataProcessor interface.
    properties (SetAccess = private)
        IsFinished = false;
        IsMoreInputRequired = true;
    end
    
    properties (GetAccess = private, SetAccess = immutable)
        % A vector of ReduceByKeyProcessor objects that will do the actual
        % work.
        UnderlyingProcessors;
        
        % The number of variables that will be reduced for each
        % ReduceByKeyProcessor.
        NumVariablesVector;
        
        % The number of partitions in the output.
        NumPartitions;
    end
    
    methods (Static)
        % Create a data processor factory that can be used by the execution
        % environment to construct instances of this class.
        function factory = createFactory(functionHandles, numVariablesVector, numDependencies)
            if nargin < 3
                numDependencies = numel(functionHandles);
            end
            factory = @createFusedReduceByKeyProcessor;
            function dataProcessor = createFusedReduceByKeyProcessor(~, numOutputPartitions)
                import matlab.bigdata.internal.lazyeval.FusedReduceByKeyProcessor;
                if nargin < 2
                    numOutputPartitions = 1;
                end
                dataProcessor = FusedReduceByKeyProcessor(functionHandles, numVariablesVector, numOutputPartitions, numDependencies);
            end
        end
    end
    
    % Methods overridden in the DataProcessor interface.
    methods
        function [data, partitionIndices] = process(obj, isLastOfInput, varargin)
            if obj.IsFinished
                data = cell(0, sum(obj.NumVariablesVector));
                partitionIndices = zeros(0, 1);
                return;
            end
            
            isLastOfAllInput = all(isLastOfInput);
            if numel(varargin) == 1 && numel(obj.UnderlyingProcessors) ~= 1
                % In this case, the input originated from a previous
                % FusedReduceByKeyProcessor. We need to separate out the
                % input into one per ReduceByKeyOperation.
                numInputsUsed = 0;
                numInputsVector = obj.NumVariablesVector;
                inputs = cell(1, numel(numInputsVector));
                for ii = 1:numel(numInputsVector)
                    inputs{ii} = varargin{1}(:, numInputsUsed + (1 : numInputsVector(ii)));
                    numInputsUsed = numInputsUsed + numInputsVector(ii);
                end
            else
                inputs = varargin;
            end
            
            % For the actual reduction, delegate to ReduceByKeyProcessor.
            % Up-to this point, all data is packed into cells and so
            % mismatches of sizes in the tall dimension does not matter.
            % Each ReduceByKeyProcessor will unpack its respective input
            % and perform size mismatch checking on its group of variables.
            processors = obj.UnderlyingProcessors;
            data = cell(1, numel(processors));
            partitionIndices = cell(1, numel(processors));
            for ii = 1:numel(processors)
                [data{ii}, partitionIndices{ii}] = processors(ii).process(isLastOfAllInput, inputs{ii});
            end
            obj.IsMoreInputRequired = ~isLastOfInput;
            
            % Stop here if we have not finished the reduction.
            if ~isLastOfAllInput
                data = cell(0, sum(obj.NumVariablesVector));
                partitionIndices = zeros(0, 1);
                return;
            end
            
            % All ReduceByKeyProcessors should generate the same number of
            % packed cells of output (one for each partition). Mismatch of
            % size in the output is handled because at this point, the
            % output data is already packed into cells by each
            % ReduceByKeyProcessor.
            for ii = 2:numel(partitionIndices)
                assert(isequal(partitionIndices{1}, partitionIndices{ii}));
            end
            partitionIndices = partitionIndices{1};
            data = [data{:}];
            obj.IsFinished = true;
        end
    end
    
    % Private constructor for factory method.
    methods (Access = private)
        function obj = FusedReduceByKeyProcessor(functionHandles, numVariablesVector, numPartitions, numDependencies)
            import matlab.bigdata.internal.lazyeval.ReduceByKeyProcessor
            
            underlyingProcessors = cell(1, numel(functionHandles));
            for ii = 1:numel(functionHandles)
                underlyingProcessors{ii} = ReduceByKeyProcessor(...
                    functionHandles{ii}, numVariablesVector(ii), numPartitions);
            end
            obj.UnderlyingProcessors = vertcat(underlyingProcessors{:});
            obj.NumVariablesVector = numVariablesVector;
            obj.NumPartitions = numPartitions;
            
            obj.IsMoreInputRequired = true(1, numDependencies);
        end
    end
end
