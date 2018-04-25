%DiskCacheStore
% Helper class that manages a collection of disk cache entries for one
% MATLAB Context. This will be used by non-spark back-ends.
%

%   Copyright 2016-2017 The MathWorks, Inc.

classdef (Sealed) DiskCacheStore < matlab.bigdata.internal.io.CacheStore
    properties (SetAccess = immutable)
        % The folder that stores all caches on disk.
        CacheFolder;
    end
    
    properties (Constant)
        % The default max size for disk cache stores.
        DEFAULT_MAX_SIZE = 1000 * 1024 ^ 2;
    end
    
    methods
        % The main constructor. This takes an optional max size input
        % parameter, if this is not given then the value from
        % defaultMaxSize is used.
        function obj = DiskCacheStore(maxSizeInBytes)
            import matlab.bigdata.internal.io.DiskCacheStore;
            import matlab.bigdata.internal.util.TempFolder;
            
            if nargin < 1
                maxSizeInBytes = DiskCacheStore.defaultMaxSize();
            end
            obj = obj@matlab.bigdata.internal.io.CacheStore(maxSizeInBytes);
            obj.CacheFolder = TempFolder();
        end
    end
    
    methods (Static)
        % Static method to set or get the default max size for disk cache
        % stores.
        function out = defaultMaxSize(in)
            import matlab.bigdata.internal.io.DiskCacheStore;
            persistent default;
            if isempty(default)
                default = DiskCacheStore.DEFAULT_MAX_SIZE;
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
        function reader = doOpenForRead(~, files)
            reader = datastore(files, 'Type', 'Tall', 'FileType', 'mat');
        end
        
        % The underlying implementation specific pieces of openEntryForWrite.
        function writer = doOpenForWrite(obj, cacheEntryId, cacheEntryOldId, partitionIndex)
            import matlab.bigdata.internal.io.DiskCacheWriter;
            writer = DiskCacheWriter(cacheEntryId, cacheEntryOldId, partitionIndex, obj);
        end
        
        % Do cleanup for the data of a specific cache entry. This is
        % a hook for the disk cache cleanup.
        function doRemove(~, files)
            iDeleteFiles(files);
        end
        
        % Do cleanup of all data associated with a cache entry ID. This is
        % a hook for the disk cache cleanup.
        function doRemoveAll(obj, cacheEntryId)
            path = fullfile(obj.CacheFolder.Path, char(cacheEntryId));
            if exist(path, 'dir') == 7
                iDeleteDirectory(path);
            end
        end
    end
end

% Helper function that removes a directory with no warnings.
function iDeleteDirectory(path)
[success, msgId, message] = rmdir(path, 's');
if ~success
    error(msgId, message);
end
end

% Helper function that deletes a collection of files with no warnings.
function iDeleteFiles(files)
ws = warning('off', 'all');
warningCleanup = onCleanup(@()warning(ws));
delete(files{:});
end
