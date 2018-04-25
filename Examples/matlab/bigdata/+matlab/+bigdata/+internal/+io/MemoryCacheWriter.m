%MemoryCacheWriter
% An implementation of the Writer interface that writes to a
% MemoryCacheStore. This will be used by non-spark back-ends.
%

%   Copyright 2016-2017 The MathWorks, Inc.

classdef (Sealed) MemoryCacheWriter < matlab.bigdata.internal.io.CacheWriter
    properties (SetAccess = private)
        Data = {};
    end
    
    methods (Access = ?matlab.bigdata.internal.io.MemoryCacheStore)
        % The main constructor.
        %
        % The inputs are as follows:
        %  - cacheEntryId: The value for the CacheEntryId property.
        %  - partitionIndex: The value for the PartitionIndex property.
        %  - cacheStore: The value for the CacheStore property.
        function obj = MemoryCacheWriter(cacheEntryId, cacheEntryOldId, partitionIndex, cacheStore)
            obj = obj@matlab.bigdata.internal.io.CacheWriter(cacheEntryId, cacheEntryOldId, partitionIndex, cacheStore);
        end
    end
    
    methods (Access = protected)
        % The underlying implementation of the add method for a single
        % CacheWriter object.
        function doAdd(obj, value)
            obj.Data{end + 1} = value;
        end
        
        % The underlying implementation of the commit method for a single
        % CacheWriter object.
        function [data, dataSize] = doCommit(obj, dataSize)
            data = obj.Data;
        end
        
        % The underlying implementation of discard method for a single
        % CacheWriter object.
        function doDiscard(obj)
            obj.Data = {};
        end
    end
end
