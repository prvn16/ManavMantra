%ChunkResizeOperation
% An operation that resizes the chunks prior to a tall/write, in order to
% remove empty chunks and coalesce small chunks.

% Copyright 2017 The MathWorks, Inc.

classdef (Sealed) ChunkResizeOperation < matlab.bigdata.internal.lazyeval.Operation
    properties (GetAccess = private, SetAccess = immutable)
        % Minimum number of bytes per chunk. This will default to
        % desiredMinBytesPerChunk.
        MinBytesPerChunk;
        
        % Maximum number of seconds to collect each chunk. This will
        % default to Inf.
        MaxTimePerChunk;
    end
    
    methods
        % The main constructor.
        function obj = ChunkResizeOperation(numVariables, varargin)
            import matlab.bigdata.internal.lazyeval.ChunkResizeOperation;
            numInputs = numVariables;
            numOutputs = numVariables;
            supportsPreview = true;
            obj = obj@matlab.bigdata.internal.lazyeval.Operation(numInputs, numOutputs, supportsPreview);
            
            p = inputParser;
            p.addParameter('MinBytesPerChunk', ...
                ChunkResizeOperation.desiredMinBytesPerChunk(), ...
                @(x) isscalar(x) && isnumeric(x) && x > 0 && (isinf(x) || mod(x, 1) == 0));
            p.addParameter('MaxTimePerChunk', ...
                Inf, ...
                @(x) isscalar(x) && isnumeric(x));
            p.parse(varargin{:});
            obj.MinBytesPerChunk = double(p.Results.MinBytesPerChunk);
            obj.MaxTimePerChunk = double(p.Results.MaxTimePerChunk);
        end
    end
    
    % Methods overridden in the Operation interface.
    methods
        function task = createExecutionTasks(obj, taskDependencies, inputFutureMap, ~)
            import matlab.bigdata.internal.executor.ExecutionTask;
            import matlab.bigdata.internal.lazyeval.PassthroughProcessor;
            import matlab.bigdata.internal.lazyeval.InputMapProcessorDecorator;
            import matlab.bigdata.internal.lazyeval.OutputBufferProcessDecorator;
            
            % This relies the logic of OutputBufferProcessDecorator, which
            % already coalesce small chunks of the output of a decorator.
            processorFactory = PassthroughProcessor.createFactory(obj.NumInputs);
            processorFactory = InputMapProcessorDecorator.wrapFactory(processorFactory, inputFutureMap);
            processorFactory = OutputBufferProcessDecorator.wrapFactory(processorFactory, obj.MinBytesPerChunk, obj.MaxTimePerChunk);
            
            task = ExecutionTask.createSimpleTask(taskDependencies, processorFactory);
        end
    end
    
    methods (Static)
        function out = desiredMinBytesPerChunk(in)
            % Get the default desired minimum bytes per chunk that a resize
            % chunk operation will aim for.
            persistent value
            if isempty(value)
                value = 1048576; % 1 MB
            end
            if nargout
                out = value;
            end
            if nargin
                value = in;
            end
        end
        
        function out = minBytesPerChunkForVisualization(in)
            % Get the default desired min bytes per chunk for visualization.
            persistent value
            if isempty(value)
                value = 33554432; % 32 MB
            end
            if nargout
                out = value;
            end
            if nargin
                value = in;
            end
        end
        
        function out = maxTimePerChunkForParallelVisualization(in)
            % Get the default maximum time to collect each chunk for
            % visualization when dealing with a parallel backend.
            persistent value
            if isempty(value)
                value = 10; % 10 second
            end
            if nargout
                out = value;
            end
            if nargin
                value = in;
            end
        end
        
        function out = maxTimePerChunkForSerialVisualization(in)
            % Get the default maximum time to collect each chunk for
            % visualization when dealing with a serial backend.
            persistent value
            if isempty(value)
                value = 0.5; % 0.5 second
            end
            if nargout
                out = value;
            end
            if nargin
                value = in;
            end
        end
    end
end
