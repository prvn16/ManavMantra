%ReduceProcessor
% Data Processor that performs a reduction of the current partition to a
% single chunk.
%
% This will apply a rolling reduction to all input. It will emit the final
% result of this rolling reduction once all input has been received.
%
% See LazyTaskGraph for a general description of input and outputs.
% Specifically, this will receive a N x NumVariables cell array and reduce
% it to a 1 x NumVariables cell array, where each cell contains the final
% reduced chunk of the corresponding operation output.
%

%   Copyright 2015-2017 The MathWorks, Inc.

classdef (Sealed) ReduceProcessor < matlab.bigdata.internal.executor.DataProcessor
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
            factory = @createReduceProcessor;
            function dataProcessor = createReduceProcessor(~)
                import matlab.bigdata.internal.lazyeval.ReduceProcessor;
                dataProcessor = ReduceProcessor(copy(functionHandle), numVariables);
            end
        end
    end
    
    % Methods overridden in the DataProcessor interface.
    methods
        function data = process(obj, isLastOfInput, in)
            if obj.IsFinished || isempty(in)
                data = cell(0, obj.NumVariables);
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
                obj.IsFinished = true;
                obj.IsMoreInputRequired = false;
            else
                data = cell(0, obj.NumVariables);
            end
        end
    end
    
    % Private constructor for factory method.
    methods (Access = private)
        function obj = ReduceProcessor(functionHandle, numVariables)
            obj.FunctionHandle = functionHandle;
            obj.NumVariables = numVariables;
        end
    end
end
