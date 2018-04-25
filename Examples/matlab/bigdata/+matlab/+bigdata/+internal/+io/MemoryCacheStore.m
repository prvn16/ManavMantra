%MemoryCacheStore
% Helper class that manages a collection of memory cache entries for one
% MATLAB Context. This will be used by non-spark back-ends.
%

%   Copyright 2016-2017 The MathWorks, Inc.

classdef MemoryCacheStore < matlab.bigdata.internal.io.CacheStore
    
    properties (Constant)
        % The default max size for memory cache stores.
        DEFAULT_MAX_SIZE = 200 * 1024 ^ 2;
    end
    
    methods
        % The main constructor. This takes an optional max size input
        % parameter, if this is not given then the value from
        % defaultMaxSize is used.
        function obj = MemoryCacheStore(maxSizeInBytes)
            import matlab.bigdata.internal.io.MemoryCacheStore;
            
            if nargin < 1
                maxSizeInBytes = MemoryCacheStore.defaultMaxSize();
            end
            obj = obj@matlab.bigdata.internal.io.CacheStore(maxSizeInBytes);
        end
    end
    
    methods (Static)
        % Static method to set or get the default max size for memory cache
        % stores.
        function out = defaultMaxSize(in)
            import matlab.bigdata.internal.io.MemoryCacheStore;
            persistent default;
            if isempty(default)
                default = MemoryCacheStore.DEFAULT_MAX_SIZE;
            end
            if nargout
                out = default;
            end
            if nargin
                default = in;
            end
        end
    end
    
    methods (Access = protected)
        % The underlying implementation specific pieces of openEntryForRead.
        function reader = doOpenForRead(~, data)
            import matlab.bigdata.internal.io.MemoryCacheReader;
            reader = MemoryCacheReader(data);
        end
        
        % The underlying implementation specific pieces of openEntryForWrite.
        function writer = doOpenForWrite(obj, cacheEntryId, cacheEntryOldId, partitionIndex)
            import matlab.bigdata.internal.io.MemoryCacheWriter;
            writer = MemoryCacheWriter(cacheEntryId, cacheEntryOldId, partitionIndex, obj);
        end
        
        % Do cleanup for the data of a specific cache entry. This is
        % a hook for the disk cache cleanup.
        function doRemove(~, ~)
            % Do not need to do anything, the entry will be removed as part
            % of dropping the cache entry table.
        end
        
        % Do cleanup of all data associated with a cache entry ID. This is
        % a hook for the disk cache cleanup.
        function doRemoveAll(~, ~)
            % Do not need to do anything, the entry will be removed as part
            % of dropping the cache entry table.
        end
    end
end
