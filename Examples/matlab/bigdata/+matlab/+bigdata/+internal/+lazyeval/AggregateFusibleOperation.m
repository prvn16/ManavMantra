%AggregateFusibleOperation
% An abstract base class that represents an operation that can be fused
% into a FusedAggregateOperation.
%
% All operations that represent an aggregation of a partitioned array into
% a non-partitioned array should inherit from this.

% Copyright 2015-2016 The MathWorks, Inc.

classdef (Abstract) AggregateFusibleOperation < matlab.bigdata.internal.lazyeval.Operation
    properties (SetAccess = immutable)
        % The number of intermediate variables in-between the PerChunk
        % function handle and the final result.
        NumIntermediates;
    end
    
    methods
        function obj = AggregateFusibleOperation(numIntermediates, varargin)
            % Initialize the AggregateFusibleOperation immutable state.
            
            assert(isnumeric(numIntermediates) && isscalar(numIntermediates) && mod(numIntermediates,1) == 0 && numIntermediates >= 0, ...
                'The numIntermediates input must be a scalar positive integer.');
            obj = obj@matlab.bigdata.internal.lazyeval.Operation(varargin{:});
            obj.NumIntermediates = numIntermediates;
        end
    end
    
    methods (Abstract)
        % Create the DataProcessor that will be applied to every chunk of
        % input before reduction.
        %
        % This will be called by FusedAggregateOperation.
        factory = createPerChunkProcessorFactory(obj, inputFutureMap, isInputReplicated);
        
        % Create the DataProcessor that will be applied to reduce
        % consecutive chunks before communication.
        %
        % This will be called by FusedAggregateOperation.
        factory = createCombineProcessorFactory(obj);
        
        % Create the DataProcessor that will be applied to reduce
        % consecutive chunks after communication.
        %
        % This will be called by FusedAggregateOperation.
        factory = createReduceProcessorFactory(obj);
    end
end
