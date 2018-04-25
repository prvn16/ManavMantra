%DiskCacheWriter
% An implementation of the Writer interface that writes to a
% DiskCacheStore. This will be used by non-spark back-ends.
%

%   Copyright 2016-2017 The MathWorks, Inc.

classdef (Sealed) DiskCacheWriter < matlab.bigdata.internal.io.CacheWriter
    properties (SetAccess = immutable)
        % The underlying Writer object that will write the disk cache
        % entry.
        UnderlyingWriter;
    end
    
    methods (Access = ?matlab.bigdata.internal.io.DiskCacheStore)
        % The main constructor.
        %
        % The inputs are as follows:
        %  - cacheEntryId: The value for the CacheEntryId property.
        %  - partitionIndex: The value for the PartitionIndex property.
        %  - cacheStore: The value for the CacheStore property.
        function obj = DiskCacheWriter(cacheEntryId, cacheEntryOldId, partitionIndex, cacheStore)
            import matlab.bigdata.internal.io.MatArrayWriter;
            
            obj = obj@matlab.bigdata.internal.io.CacheWriter(cacheEntryId, cacheEntryOldId, partitionIndex, cacheStore);
            
            path = fullfile(cacheStore.CacheFolder.Path, char(cacheEntryId));
            iCreateDirectory(path);
            obj.UnderlyingWriter = MatArrayWriter(partitionIndex, [], path);
        end
    end
    
    methods (Access = protected)
        % The underlying implementation of the add method for a single
        % CacheWriter object.
        function doAdd(obj, value)
            obj.UnderlyingWriter.add(value);
        end
        
        % The underlying implementation of the commit method for a single
        % CacheWriter object.
        function [files, dataSize] = doCommit(obj, ~)
            obj.UnderlyingWriter.commit();
            files = obj.getFiles();
            
            dirStruct = cellfun(@dir, files);
            dataSize = sum([dirStruct.bytes]);
        end
        
        % The underlying implementation of discard method for a single
        % CacheWriter object.
        function doDiscard(obj, ~)
            files = obj.getFiles();
            delete(obj.UnderlyingWriter);
            if ~isempty(files)
                iDeleteFiles(files);
            end
        end
    end
    
    methods
        % Cleanup files on disk if we are an in non-committed state at
        % delete.
        function delete(obj)
            if obj.HasEntryOpenForWrite
                obj.doDiscard();
            end
        end
    end
    
    methods (Access = private)
        % Get the files currently created as a result of this writer.
        function files = getFiles(obj)
            if isempty(obj.UnderlyingWriter)
                files = {};
            else
                % This assumes the underlying writer is of type
                % MatArrayWriter.
                files = obj.UnderlyingWriter.Serializer.getFiles();
            end
        end
    end
end

% Helper function that creates a directory with no warnings.
function iCreateDirectory(path)
[success, msgId, message] = mkdir(path);
if ~success
    error(msgId, '%s', message);
end
end

% Helper function that deletes a collection of files with no warnings.
function iDeleteFiles(files)
ws = warning('off', 'all');
warningCleanup = onCleanup(@()warning(ws));
delete(files{:});
end
