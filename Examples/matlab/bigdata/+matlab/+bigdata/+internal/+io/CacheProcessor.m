%CacheProcessor
% Helper class that introduces a cache to the graph of operations.
%
% On cache hit, this will not require any input and read output chunks from
% the cache. On cache miss, this will require the input, write it to the
% cache as well as pass it forward.
%

%   Copyright 2015-2016 The MathWorks, Inc.

classdef CacheProcessor < matlab.bigdata.internal.executor.DataProcessor
    % Properties overridden in the DataProcessor interface.
    properties (SetAccess = private)
        IsFinished = false;
        IsMoreInputRequired = true;
    end
    
    properties (SetAccess = immutable)
        % The underlying processor that will read from the disk or memory
        % cache. This will be empty if no cache exists.
        ReadProcessor;
        
        % The underlying processor that will write to the disk or memory
        % cache. This will be empty if both disk and memory cache already
        % exists.
        WriteProcessor;
    end
    
    % Methods overridden in the DataProcessor interface.
    methods
        function data = process(obj, isLastOfInput, data)
            if isempty(obj.ReadProcessor)
                % If no cache read processor, this is a straight pass
                % through.
                obj.IsFinished = isLastOfInput;
            else
                % Otherwise we redirect input to be from the cache read
                % processor.
                data = obj.ReadProcessor.process([]);
                obj.IsFinished = obj.ReadProcessor.IsFinished;
            end
            
            if ~isempty(obj.WriteProcessor)
                % If we need to write to cache, do that here.
                data = obj.WriteProcessor.process(obj.IsFinished, data);
                obj.IsFinished = obj.WriteProcessor.IsFinished;
            end
        end
    end
    
    methods (Static)
        % Create a DataProcessor that represents a cache point in the graph
        % of data processors.
        function factory = createFactory(cacheEntryKey, getCacheStoreFunction)
            factory = @createCacheProcessor;
            function processor = createCacheProcessor(partition)
                import matlab.bigdata.internal.io.CacheProcessor;
                import matlab.bigdata.internal.io.LocalReadProcessor;
                import matlab.bigdata.internal.io.LocalWriteProcessor;
                cacheEntryStore = feval(getCacheStoreFunction);
                
                [reader, writer] = cacheEntryStore.openOrCreateEntry(cacheEntryKey, partition.PartitionIndex);
                if ~isempty(reader)
                    reader = LocalReadProcessor(reader);
                end
                if ~isempty(writer)
                    writer = LocalWriteProcessor(writer);
                end
                processor = CacheProcessor(reader, writer);
            end
        end
    end
    
    methods (Access = private)
        % Private constructor for the static factory method.
        function obj = CacheProcessor(readProcessor, writeProcessor)
            obj.ReadProcessor = readProcessor;
            obj.WriteProcessor = writeProcessor;
            obj.IsMoreInputRequired = isempty(readProcessor);
        end
    end
end
