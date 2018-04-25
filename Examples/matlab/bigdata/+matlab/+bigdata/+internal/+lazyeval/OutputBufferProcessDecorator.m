%OutputBufferProcessDecorator
% A decorator of the DataProcessor interface that buffers the output in
% order to reduce the number of chunks if all output chunks are small.

%   Copyright 2017 The MathWorks, Inc.

classdef (Sealed) OutputBufferProcessDecorator < matlab.bigdata.internal.executor.DataProcessor
    % Properties overridden in the DataProcessor interface.
    properties (SetAccess = private)
        IsFinished = false;
        IsMoreInputRequired;
    end
    
    properties (GetAccess = private, SetAccess = immutable)
        % The underlying processor that performs the actual processing.
        UnderlyingProcessor;
        
        % The desired minimum number of bytes per chunk. If the output is
        % smaller than this, it will be buffered and vertically
        % concatenated with future calls of this function.
        DesiredMinChunkBytes;
        
        % The maximum number of seconds to wait to collect a chunk. If Inf,
        % this restriction is never applied. If not inf, the very first
        % chunk of input is emitted immediately. All following chunks
        % will wait up-to the max time for as much data to be collected as
        % possibility.
        MaxTimePerChunk;
    end
    
    properties (Access = private)
        % The buffer for all input.
        OutputBuffer;
        
        % The last tic.
        LastTic = NaN;
    end
    
    % Methods overridden in the DataProcessor interface.
    methods
        function data = process(obj, isLastOfInputsVector, varargin)
            data = obj.UnderlyingProcessor.process(isLastOfInputsVector, varargin{:});
            obj.updateState();
            
            % If there is no data, we can in general skip checking
            % manipulating the buffer because nothing has changed. The only
            % exception is at the end, where we want to flush everything
            % out of the buffer.
            if ~obj.IsFinished && isempty(data)
                return;
            end
            
            if ~isempty(obj.OutputBuffer)
                data = [obj.OutputBuffer; data];
                obj.OutputBuffer = [];
            end
            
            data = cellfun(@matlab.bigdata.internal.util.vertcatCellContents, num2cell(data, 1), 'UniformOutput', false);
            dataInfo = whos('data');
            if isempty(data)
                % If the output has no chunks anyway, ignore.
            elseif obj.IsFinished ...
                    || (dataInfo.bytes > obj.DesiredMinChunkBytes) ...
                    || (~isinf(obj.MaxTimePerChunk) && (isnan(obj.LastTic) || (toc(obj.LastTic) > obj.MaxTimePerChunk)))
                % Emit the data.
                obj.LastTic = tic;
            else
                % Emit no chunks.
                obj.OutputBuffer = data;
                data = cell(0, size(data, 2));
            end
        end
    end
    
    methods (Static)
        function factory = wrapFactory(dataProcessorFactory, desiredMinChunkBytes, maxTimePerChunk)
            % Wrap a data processor factory into one that, the constructed
            % DataProcessor instances will buffer output to a minimum chunk
            % size.
            import matlab.bigdata.internal.lazyeval.ChunkResizeOperation;
            if nargin < 2
                desiredMinChunkBytes = ChunkResizeOperation.desiredMinBytesPerChunk();
            end
            if nargin < 3
                maxTimePerChunk = inf;
            end
            
            factory = @createProcessor;
            function processor = createProcessor(partition, varargin)
                import matlab.bigdata.internal.lazyeval.OutputBufferProcessDecorator;
                processor = feval(dataProcessorFactory, partition, varargin{:});
                processor = OutputBufferProcessDecorator(processor, desiredMinChunkBytes, maxTimePerChunk);
            end
        end
    end
    
    methods (Access = private)
        function obj = OutputBufferProcessDecorator(underlyingProcessor, desiredMinChunkBytes, maxTimePerChunk)
            % Private constructor for the static build function.
            
            obj.UnderlyingProcessor = underlyingProcessor;
            obj.DesiredMinChunkBytes = desiredMinChunkBytes;
            obj.MaxTimePerChunk = maxTimePerChunk;
            obj.updateState();
        end
        
        function updateState(obj)
            % Update the DataProcessor public properties to correspond with
            % the equivalent of the underlying processor.
            
            obj.IsFinished = obj.UnderlyingProcessor.IsFinished;
            obj.IsMoreInputRequired = obj.UnderlyingProcessor.IsMoreInputRequired;
        end
    end
end
