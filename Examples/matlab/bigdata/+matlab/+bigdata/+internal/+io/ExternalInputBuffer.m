classdef ExternalInputBuffer < handle & matlab.mixin.Copyable
    %EXTERNALINPUTBUFFER An input buffer that spills to disk when the
    %maxBufferSize threshold is exceeded
    
    %   Copyright 2017 The MathWorks, Inc.
    
    
    properties (Access = private, Transient)
        % An in-memory buffer to collect partition data within
        Buffer;
        
        % A rough estimate of the number of bytes currently being held in
        % memory.
        BufferSizeInBytes = 0;
        
        % The number of slices per chunk to emit as output. This is empty
        % until some data is received, at which point it is set to give the
        % required chunk sizes in bytes.
        NumSlicesPerChunk;
        
        % The base folder on disk that holds any data spilled to disk. This
        % is empty when no data has been spilled to disk.
        DataFolder;
        
        % A list of folders that contain data that has been spilled to disk.
        % Each path represents a single TallDatastore collection of data.
        SpilledDataPaths = {};
        
        % The datastore used to read data that has been spilled to disk.
        DiskDatastore;
    end
    
    properties (Constant)
        % The default maximum size in memory of the buffer. Once this is
        % exceeded, data is spilled to disk.
        DEFAULT_MAX_BUFFER_SIZE_IN_BYTES = 100 * 1024 ^ 2;
        
        % The default size of each chunk in bytes.
        DEFAULT_CHUNK_SIZE_IN_BYTES = 1 * 1024 ^ 2;
    end
    
    methods        
        function add(obj, chunk)
            %ADD Add a chunk to held data.
            
            import matlab.bigdata.internal.lazyeval.InputBuffer
            
            if isempty(obj.Buffer)
                isInputSinglePartition = false;
                obj.Buffer = InputBuffer(1, isInputSinglePartition);
            end
            
            whosData = whos('chunk');
            obj.Buffer.add(false, {chunk});
            obj.BufferSizeInBytes = obj.BufferSizeInBytes + whosData.bytes;
            
            if obj.BufferSizeInBytes > obj.maxBufferSize()
                obj.spillBuffer();
            end
        end
        
        function [isFinished, chunk] = getnext(obj)
            %GETNEXT Retrieve the next chunk from held data.
            
            if isempty(obj.NumSlicesPerChunk)
                obj.initializeNumSlicesPerChunk();
            end
            
            if isempty(obj.SpilledDataPaths)
                % In-memory case
                chunk = obj.Buffer.getCompleteSlices(obj.NumSlicesPerChunk);
                isFinished = (obj.Buffer.NumBufferedSlices(1) == 0);
            else
                % Out-of-memory case
                [isFinished, chunk] = obj.readSpilledBuffer();
            end
            
            chunk = chunk{1};
        end
    end
    
    methods (Access = private)
        function initializeNumSlicesPerChunk(obj)
            %INITIALIZENUMSLICESPERCHUNK Initialize the value of
            % NumSlicesPerChunk based on the current buffer and buffer size.
            
            numBytesPerSlice = obj.BufferSizeInBytes / obj.Buffer.NumBufferedSlices;
            obj.NumSlicesPerChunk = max(1, ceil(obj.chunkSize / numBytesPerSlice));
        end
        
        function spillBuffer(obj)
            %SPILLBUFFER Spill the contents of the in-memory buffer to disk
            
            import matlab.bigdata.internal.io.WriteFunction;
            import matlab.bigdata.internal.util.TempFolder;
            
            if isempty(obj.DataFolder)
                obj.DataFolder = TempFolder;
            end
            if isempty(obj.NumSlicesPerChunk)
                obj.initializeNumSlicesPerChunk();
            end
            
            data = obj.Buffer.getAll();
            if isempty(data)
                return;
            end
            
            nextSpilledDataIndex = numel(obj.SpilledDataPaths) + 1;
            location = fullfile(obj.DataFolder.Path, sprintf('part-%05i', nextSpilledDataIndex));
            iWriteDataToDisk(location, data);
            
            obj.BufferSizeInBytes = 0;
            obj.SpilledDataPaths{end + 1} = location;
        end
        
        function [isFinished, chunk] = readSpilledBuffer(obj)
            %READSPILLEDBUFFER Reads buffered data in FIFO order from disk
            
            import matlab.io.datastore.TallDatastore;
            
            if isempty(obj.DiskDatastore) || ~hasdata(obj.DiskDatastore)
                assert(~isempty(obj.SpilledDataPaths), 'No spilled data to read from');
                obj.DiskDatastore = TallDatastore(obj.SpilledDataPaths{1}, 'ReadSize', obj.NumSlicesPerChunk);
                obj.SpilledDataPaths = obj.SpilledDataPaths(2:end);
            end
            
            chunk = read(obj.DiskDatastore);
            isFinished = ~hasdata(obj.DiskDatastore) && isempty(obj.SpilledDataPaths);
        end
    end
    
    methods (Static)
        function out = maxBufferSize(in)
            % Persistent value for controlling the maximum buffer size
            % before this object spills to disk.
            
            import matlab.bigdata.internal.io.ExternalInputBuffer;
            
            persistent value;
            if isempty(value)
                value = ExternalInputBuffer.DEFAULT_MAX_BUFFER_SIZE_IN_BYTES;
            end
            if nargout
                out = value;
            end
            if nargin
                value = in;
            end
        end
        
        function out = chunkSize(in)
            % Persistent value for controlling the chunk size in bytes.
            
            import matlab.bigdata.internal.io.ExternalInputBuffer;
            
            persistent value;
            if isempty(value)
                value = ExternalInputBuffer.DEFAULT_CHUNK_SIZE_IN_BYTES;
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

function iWriteDataToDisk(location, data)
% Write the contents of datastore or local MATLAB array to the given
% location.

import matlab.bigdata.internal.io.WriteFunction;

isHdfs = false;
iCreateDirectory(location);
writer = WriteFunction.createWriteToBinaryFunction(location, isHdfs);
info = struct( ...
    'PartitionId', 1, ...
    'NumPartitions', 1, ...
    'IsLastChunk', true );

feval(writer, info, data);
end

function iCreateDirectory(path)
% Helper function that creates a directory with no warnings.
[success, msgId, message] = mkdir(path);
if ~success
    error(msgId, '%s', message);
end
end
