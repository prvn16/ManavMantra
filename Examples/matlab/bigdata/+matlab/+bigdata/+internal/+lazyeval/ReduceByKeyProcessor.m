%ReduceByKeyProcessor
% Data Processor that performs a reduction of the current partition to a
% single chunk per key.
%
% This will apply a rolling reduction to all input. It will emit the final
% result of this rolling reduction once all input has been received.
%
% See LazyTaskGraph for a general description of input and outputs.
% Specifically, this will receive a N x NumVariables cell array where the
% first variable when unpacked represent a set of keys. It will return a
% NumOutputPartitions x NumVariables cell array as output. Each row of this
% output is a chunk of data to be sent to the output partition of
% corresponding index in the same row of partitionIndices output. Every
% unique key is matched to exactly one output partition via hash mod n.
%

%   Copyright 2016-2017 The MathWorks, Inc.

classdef (Sealed) ReduceByKeyProcessor < matlab.bigdata.internal.executor.DataProcessor
    % Properties overridden in the DataProcessor interface.
    properties (SetAccess = private)
        IsFinished = false;
        IsMoreInputRequired = true;
    end
    
    properties (GetAccess = private, SetAccess = immutable)
        % The Reducing function handle.
        FunctionHandle;
        
        % The number of variables that will be reduced.
        %
        % If this is greater than one, this processor expects a multiplexed
        % input and returns a multiplexed output. Multiplexing here means a
        % cell array with one column representing each variable.
        NumVariables;
        
        % The number of partitions in the output.
        NumPartitions;
    end
    
    properties (Access = private)
        % A buffer for holding partially reduced data while this data
        % processor is still receiving input.
        IntermediateBuffer;
    end
    
    methods (Static)
        % Create a data processor factory that can be used by the execution
        % environment to construct instances of this class.
        function factory = createFactory(functionHandle, numVariables)
            factory = @createReduceByKeyProcessor;
            function dataProcessor = createReduceByKeyProcessor(~, numOutputPartitions)
                import matlab.bigdata.internal.lazyeval.ReduceByKeyProcessor;
                if nargin < 2
                    numOutputPartitions = 1;
                end
                dataProcessor = ReduceByKeyProcessor(copy(functionHandle), numVariables, numOutputPartitions);
            end
        end
    end
    
    % Methods overridden in the DataProcessor interface.
    methods
        function [data, partitionIndices] = process(obj, isLastOfInput, in)
            if obj.IsFinished || (isempty(in) && ~all(isLastOfInput))
                data = cell(0, obj.NumVariables);
                partitionIndices = zeros(0, 1);
                return;
            end
            
            % This enforces pairwise reduction so that we do not get sporadic
            % differences in rounding of results if this processor so
            % happens to receive a different number of chunks in two
            % different passes of the underlying data.
            in = [obj.IntermediateBuffer; in];
            state = in(1, :);
            if isempty(obj.IntermediateBuffer)
                % Call reducefun on the first chunk of the partition in-case
                % it is the only chunk of the partition.
                [state{:}] = feval(obj.FunctionHandle, state{:});
            end
            for ii = 2:size(in, 1)
                state = cellfun(@vertcat, state, in(ii, :), 'UniformOutput', false);
                [state{:}] = feval(obj.FunctionHandle, state{:});
            end
            obj.IntermediateBuffer = state;
            
            if isLastOfInput && ~obj.IsFinished
                data = obj.IntermediateBuffer;
                obj.IntermediateBuffer = [];
                [partitionIndices, data] = iPartitionData(obj.NumPartitions, data{:});
                obj.IsFinished = true;
                obj.IsMoreInputRequired = false;
            else
                data = cell(0, obj.NumVariables);
                partitionIndices = zeros(0, 1);
            end
        end
    end
    
    % Private constructor for factory method and for FusedReduceByKeyProcessor.
    methods (Access = {?matlab.bigdata.internal.lazyeval.FusedReduceByKeyProcessor})
        function obj = ReduceByKeyProcessor(functionHandle, numVariables, numPartitions)
            obj.FunctionHandle = functionHandle;
            obj.NumVariables = numVariables;
            obj.NumPartitions = numPartitions;
        end
    end
end

% Partition the output into chunks based on binning the keys into the output
% partitions.
function [indices, data] = iPartitionData(numPartitions, keys, varargin)
indices = (1:numPartitions)';

keyIndices = iPartition(keys, numPartitions);
if iscategorical(keys)
    % These indices are calculated here to support the pruning done to the
    % category names of each key data array sent to each corresponding worker.
    cats = categories(keys);
    catIndices = iPartition(cats, numPartitions);
end

data = cell(numPartitions, 1 + numel(varargin));
for ii = 1:numPartitions
    data{ii, 1} = iIndexSlices(keys, keyIndices == ii);
    if iscategorical(keys)
        % For categorical key data, we ensure each worker receives key data
        % that contains only the category names assigned to that worker.
        data{ii, 1} = setcats(data{ii, 1}, cats(catIndices == ii));
    end
    for jj = 1:numel(varargin)
        data{ii, jj + 1} = iIndexSlices(varargin{jj}, keyIndices == ii);
    end
end
end

% Bin the keys into the various output partitions by doing a crude hash
% modulo number of partitions.
function indices = iPartition(keys, numPartitions)
sz = size(keys);
if isa(keys, 'double')
    keys = double(mod(typecast(keys(:), 'uint64'), numPartitions));
elseif isfloat(keys)
    keys = double(mod(typecast(keys(:), 'uint32'), numPartitions));    
elseif isnumeric(keys) || islogical(keys)
    keys = mod(double(keys(:)), numPartitions);
elseif isdatetime(keys) || isduration(keys)
    keys = datenum(keys(:));
    keys = double(mod(typecast(keys, 'uint64'), numPartitions));
elseif isstring(keys) || iscellstr(keys) || iscategorical(keys)
    [uniqueKeys, ~, idx] = unique(keys);
    keySum = mod(cellfun(@sum, cellstr(uniqueKeys)), numPartitions);
    keys = keySum(idx);
else
    error(message('MATLAB:bigdata:executor:InvalidKeyType', class(keys)));
end
indices = mod(31 * sum(reshape(keys,sz(1),[]), 2), numPartitions) + 1;
end

% Helper function for indexing into slices
function data = iIndexSlices(data, indices)
sz = size(data);
data = data(indices, :);
if numel(sz) > 2
    data = reshape(data, [size(data, 1), sz(2:end)]);
end
end
