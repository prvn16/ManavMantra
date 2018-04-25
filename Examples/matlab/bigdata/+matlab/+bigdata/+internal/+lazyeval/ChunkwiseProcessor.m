%ChunkwiseProcessor
% Data Processor that applies a chunk-wise function handle to the input
% data.
%
% This will apply a function handle chunk-wise to all of the data. It will
% emit data continuously throughout a pass.
%
% See LazyTaskGraph for a general description of input and outputs.
% Specifically, each iteration will emit a 1 x NumOutputs cell array where
% each cell contains a chunk of output of the corresponding operation
% output.
%

%   Copyright 2015-2017 The MathWorks, Inc.

classdef (Sealed) ChunkwiseProcessor < matlab.bigdata.internal.executor.DataProcessor
    % Properties overridden in the DataProcessor interface.
    properties (SetAccess = private)
        IsFinished = false;
        IsMoreInputRequired;
    end
    
    properties (GetAccess = private, SetAccess = immutable)
        % The chunk-wise function handle.
        FunctionHandle;
        
        % The number of outputs from the function handle.
        NumOutputs;
    end
    
    methods (Static)
        % Create a data processor factory that can be used by the execution
        % environment to construct instances of this class.
        function factory = createFactory(functionHandle, numOutputs, ...
                inputFutureMap, isInputReplicated, allowTallDimExpansion, varargin)
            import matlab.bigdata.internal.lazyeval.BufferedZipProcessDecorator;
            import matlab.bigdata.internal.lazyeval.ChunkwiseProcessor;
            import matlab.bigdata.internal.lazyeval.DecellificationProcessorDecorator;
            import matlab.bigdata.internal.lazyeval.InputMapProcessorDecorator;
            if nargin < 5
                allowTallDimExpansion = true;
            end
            
            numInputs = inputFutureMap.NumOperationInputs;
            factory = ChunkwiseProcessor.createSimpleFactory(...
                functionHandle, numInputs, numOutputs);
            if numInputs == 1 && isinf(functionHandle.MaxNumSlices)
                % In this case, we do not need a buffer. However, the
                % buffer also decellifies the input, we still need to do
                % that.
                factory = DecellificationProcessorDecorator.wrapFactory(...
                    factory, numOutputs);
            else
                factory = BufferedZipProcessDecorator.wrapFactory(factory, ...
                    numOutputs, isInputReplicated, functionHandle.ErrorStack, ...
                    'MaxNumSlices', functionHandle.MaxNumSlices, ...
                    'AllowTallDimExpansion', allowTallDimExpansion, ...
                    varargin{:});
            end
            factory = InputMapProcessorDecorator.wrapFactory(factory, inputFutureMap);
        end
        
        % Create a data processor factory that can be used by the execution
        % environment to construct instances of this class. This is a raw
        % chunkfun processor, without buffering or input mapping.
        function factory = createSimpleFactory(functionHandle, numInputs, numOutputs)
            factory = @createProcessor;
            function dataProcessor = createProcessor(~)
                import matlab.bigdata.internal.lazyeval.ChunkwiseProcessor;
                
                dataProcessor = ChunkwiseProcessor(copy(functionHandle), numOutputs, numInputs);
            end
        end
    end
    
    % Methods overridden in the DataProcessor interface.
    methods
        function data = process(obj, isLastOfInput, varargin)
            [varargin, data{2:obj.NumOutputs}] = feval(obj.FunctionHandle, varargin{:});
            data{1} = varargin;
            obj.IsFinished = all(isLastOfInput);
        end
    end
    
    methods (Access = private)
        % Private constructor for factory method.
        function obj = ChunkwiseProcessor(functionHandle, numOutputs, numInputs)
            import matlab.bigdata.internal.lazyeval.InputBuffer;
            
            obj.FunctionHandle = functionHandle;
            obj.NumOutputs = numOutputs;
            obj.IsMoreInputRequired = true(1, numInputs);
        end
    end
end
