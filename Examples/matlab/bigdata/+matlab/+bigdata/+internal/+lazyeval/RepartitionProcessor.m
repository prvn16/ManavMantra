%RepartitionProcessor
% An implementation of the DataProcessor interface that used in combination
% with an AnyToAny ExecutionTask to repartition a partitioned array to any
% chosen partitioning.

%   Copyright 2016 The MathWorks, Inc.

classdef (Sealed) RepartitionProcessor < matlab.bigdata.internal.executor.DataProcessor
    % Properties overridden in the DataProcessor interface.
    properties (SetAccess = private)
        IsFinished = false;
        IsMoreInputRequired = true;
    end
    
    properties (GetAccess = private, SetAccess = immutable)
        % The number of inputs/outputs.
        NumVariables;
        
        % The number of partitions after the communication..
        NumOutputPartitions;
    end
    
    methods (Static)
        function factory = createFactory(numVariables)
            % Create a data processor factory that can be used by the execution
            % environment to construct instances of this class.
            
            factory = @createReduceByKeyProcessor;
            function dataProcessor = createReduceByKeyProcessor(~, numOutputPartitions)
                import matlab.bigdata.internal.lazyeval.RepartitionProcessor;
                if nargin < 2
                    numOutputPartitions = 1;
                end
                dataProcessor = RepartitionProcessor(numVariables, numOutputPartitions);
            end
        end
    end
    
    % Methods overridden in the DataProcessor interface.
    methods
        function [data, partitionIndices] = process(obj, isLastOfInput, partitionIndices, varargin)
            if obj.IsFinished || (isempty(varargin{1}) && ~all(isLastOfInput))
                data = cell(0, obj.NumVariables);
                partitionIndices = zeros(0, 1);
                return;
            end
            
            [partitionIndices, data] = iPartitionData(obj.NumOutputPartitions, partitionIndices, varargin{:});
            obj.IsFinished = all(isLastOfInput);
            obj.IsMoreInputRequired = ~isLastOfInput;
        end
    end
    
    methods (Access = private)
        function obj = RepartitionProcessor(numVariables, numOutputPartitions)
            % Private constructor for static constructor.
            
            obj.NumVariables = numVariables;
            obj.NumOutputPartitions = numOutputPartitions;
        end
    end
end

% Bin the input slices based on a column vector of target partition indices.
function [indices, data] = iPartitionData(numPartitions, indices, varargin)
import matlab.bigdata.internal.util.indexSlices;

data = cell(numPartitions, numel(varargin));
for partitionIdx = 1:numPartitions
    for inputIdx = 1:numel(varargin)
        data{partitionIdx, inputIdx} = indexSlices(varargin{inputIdx}, indices == partitionIdx);
    end
end
indices = (1:numPartitions)';
end
