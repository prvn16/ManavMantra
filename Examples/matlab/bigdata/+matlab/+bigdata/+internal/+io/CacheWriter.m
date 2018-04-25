%CacheWriter
% An abstract implementation of the Writer interface that commits cache
% entries to a CacheStore object. This base class is extended by
% DiskCacheWriter and MemoryCacheWriter. This will be used by
% non-spark back-ends.
%
% The public methods supports usage as an array of CacheWriter objects. In
% such cases, the data is added to every CacheWriter individually.
%

%   Copyright 2016-2017 The MathWorks, Inc.

classdef (Abstract) CacheWriter < matlab.bigdata.internal.io.Writer & matlab.mixin.Heterogeneous
    properties (SetAccess = immutable)
        % The unique ID associated with the entire partitioned array
        % being cached.
        CacheEntryId;
        
        % The unique ID associated with the entire partitioned array being
        % replaced by that of CacheEntryId. This can be missing.
        CacheEntryOldId = string(missing);
        
        % The partition index that is associated with this writer.
        PartitionIndex;
        
        % The underlying CacheStore that will own the resulting cache
        % entries.
        CacheStore;
    end
    
    properties (SetAccess = private)
        % A logical scalar that is true if this object is still writing
        % into a cache entry.
        HasEntryOpenForWrite = true;
        
        % The size in bytes of all data written to the cache entry.
        CacheEntrySize = 0;
    end
    
    methods (Access = protected)
        % The main constructor.
        %
        % The inputs are as follows:
        %  - cacheEntryId: The value for the CacheEntryId property.
        %  - partitionIndex: The value for the PartitionIndex property.
        %  - cacheStore: The value for the CacheStore property.
        function obj = CacheWriter(cacheEntryId, cacheEntryOldId, partitionIndex, cacheStore)
            obj.CacheEntryId = string(cacheEntryId);
            if ~isempty(cacheEntryOldId)
                obj.CacheEntryOldId = string(cacheEntryOldId);
            end
            obj.PartitionIndex = partitionIndex;
            obj.CacheStore = cacheStore;
        end
    end
    
    methods (Sealed)
        %ADD Add a collection of<key, value> pairs to the intermediate storage
        function add(objs, ~, value)
            p = whos('value');
            numBytes = p.bytes;
            
            for obj = objs(:)'
                obj.CacheEntrySize = obj.CacheEntrySize + numBytes;
                if obj.HasEntryOpenForWrite
                    keep = obj.CacheStore.checkCacheSize(obj.CacheEntrySize);
                    if keep
                        obj.doAdd(value);
                    else
                        obj.CacheStore.closeEntry(obj.CacheEntryId, obj.PartitionIndex);
                        obj.HasEntryOpenForWrite = false;
                        obj.doDiscard();
                    end
                end
            end
        end
        
        %COMMIT Commit all output to the intermediate storage
        function commit(objs)
            for obj = objs(:)'
                if obj.HasEntryOpenForWrite
                    [data, dataSize] = obj.doCommit(obj.CacheEntrySize);
                    obj.CacheStore.commitEntry(obj.CacheEntryId, obj.CacheEntryOldId, obj.PartitionIndex, data, dataSize);
                    obj.CacheStore.closeEntry(obj.CacheEntryId, obj.PartitionIndex);
                    obj.HasEntryOpenForWrite = false;
                end
            end
        end
    end
    
    methods
        % Ensure that the cache entry is always closed.
        function delete(obj)
            if obj.HasEntryOpenForWrite
                obj.CacheStore.closeEntry(obj.CacheEntryId, obj.PartitionIndex);
                obj.HasEntryOpenForWrite = false;
            end
        end
    end
    
    methods (Abstract, Access = protected)
        % The underlying implementation of the add method for a single
        % CacheWriter object.
        doAdd(obj, value);
        
        % The underlying implementation of the commit method for a single
        % CacheWriter object. This receives the sum of the sizes of all
        % values added. It returns both data to be stored for the cache
        % entry and the size of that cache entry.
        [data, dataSize] = doCommit(obj, dataSize);
        
        % The underlying implementation of discard method for a single
        % CacheWriter object. This is called whenever the cache entry is to
        % be discarded.
        doDiscard(obj);
    end
end
