%GlobalStateProcessorDecorator
% Data Processor that manages global state so that the underlying processor
% receives a well defined view of global state.
%

%   Copyright 2017 The MathWorks, Inc.

classdef (Sealed) GlobalStateProcessorDecorator < matlab.bigdata.internal.executor.DataProcessor
    % Properties overridden in the DataProcessor interface.
    properties (SetAccess = private)
        IsFinished = false;
        IsMoreInputRequired = true;
    end
    
    properties (GetAccess = private, SetAccess = immutable)
        % The underlying processor that performs the actual processing.
        UnderlyingProcessor;
        
        % A random stream that is tied to this processor.
        OperationRandStream;
    end
    
    methods (Static)
        function factory = wrapFactory(underlyingFactory, options)
            randStreamFactory = options.RandStreamFactory;
            
            factory = @createGlobalStateProcessorDecorator;
            function dataProcessor = createGlobalStateProcessorDecorator(partition, varargin)
                import matlab.bigdata.internal.lazyeval.GlobalStateProcessorDecorator;
                dataProcessor = feval(underlyingFactory, partition, varargin{:});
                
                randStream = getRandStreamForPartition(randStreamFactory, partition.PartitionIndex);
                dataProcessor = GlobalStateProcessorDecorator(dataProcessor, randStream);
            end
        end
    end
    
    % Methods overridden in the DataProcessor interface.
    methods
        function varargout = process(obj, isLastChunk, varargin)
            oldStream = RandStream.getGlobalStream();
            oldStreamCleanup = onCleanup(@() RandStream.setGlobalStream(oldStream));
            RandStream.setGlobalStream(obj.OperationRandStream);
            
            [varargout{1 : nargout}] = obj.UnderlyingProcessor.process(isLastChunk, varargin{:});
            obj.updateState();
        end
    end
    
    methods (Access = private)
        % Private constructor for factory method.
        function obj = GlobalStateProcessorDecorator(dataProcessor, randStream)
            obj.UnderlyingProcessor = dataProcessor;
            obj.OperationRandStream = randStream;
            obj.updateState();
        end
        
        function updateState(obj)
            obj.IsFinished = obj.UnderlyingProcessor.IsFinished;
            obj.IsMoreInputRequired = obj.UnderlyingProcessor.IsMoreInputRequired;
        end
    end
end
