classdef ExternalSortFunction < handle & matlab.mixin.Copyable
    %EXTERNALSORTFUNCTION A partition-wise function object that performs a sort
    %of one partition of data.
    %
    % This implementation does one of two things based on how much data is
    % received.
    %
    % If the input data is less than the maximum buffer size, this will
    % buffer all input in memory and call sort on all of it in one go.
    %
    % Otherwise, this will spill all input to TallDatastore folders on disk
    % and use the merge-sort algorithm to sort the data.
    %
    % The merge-sort algorithm is:
    %  1. For each full buffer (of 100MB by default) as well as the final
    %     buffer:
    %       a. Sort the buffer in memory
    %       b. Write the buffer to its own location on disk
    %  2. If there are too many TallDatastore folders on disk to read
    %     simultaneously, reduce this number by picking a subset and merging
    %     those into a single TallDatastore folder.
    %  3. When the number of TallDatastore folders is small enough, perform
    %     one final merge and emit this chunkwise as output.
    %
    
    %   Copyright 2016 The MathWorks, Inc.
    
    properties (GetAccess = private, SetAccess = immutable)
        % Function handle that can sort an in-memory chunk of data.
        SortFunctionHandle;
    end
    
    properties (Access = private, Transient)
        % An in-memory buffer that will collect the data until we have
        % everything for the partition.
        Buffer;
        
        % A rough estimate of the number of bytes currently being held in
        % memory.
        BufferSizeInBytes = 0;
        
        % The number of slices per chunk to emit as output. This is empty
        % until some data is received, at which point it is set to give the
        % required chunk sizes in bytes.
        NumSlicesPerChunk;
        
        % A logical scalar that is true if and only if the sort action has
        % been applied.
        HasSorted = false;
        
        % The base folder on disk that holds any data spilled to disk. This
        % is empty when no data has been spilled to disk.
        DataFolder;
        
        % A list of folders that contain data that has been spilled to disk.
        % Each path represents one sorted TallDatastore collection of data.
        SpilledDataPaths = {};
        
        % An object that reads data from the spilled data paths and merges
        % using a sort rule. The output of the sort is the chunks retrieved
        % from this object when in the out-of-memory case. This is empty
        % both before data is sorted and when all data fits into one
        % buffer.
        FinalMerger;
    end
    
    properties (Constant)
        % The default maximum size in memory of the buffer. Once this is
        % exceeded, data is spilled to disk.
        DEFAULT_MAX_BUFFER_SIZE_IN_BYTES = 100 * 1024 ^ 2;
        
        % The default size of each chunk in bytes.
        DEFAULT_CHUNK_SIZE_IN_BYTES = 1 * 1024 ^ 2;
        
        % The default maximum number of allowed datastores to be open
        % simultaneously during merge-sort.
        DEFAULT_MAX_NUM_DATASTORES = 10;
    end
    
    methods
        function obj = ExternalSortFunction(sortFunctionHandle)
            obj.SortFunctionHandle = sortFunctionHandle;
        end
        
        function [isFinished, out] = feval(obj, info, in)
            import matlab.bigdata.internal.lazyeval.InputBuffer;
            
            % Basic initialization
            if isempty(obj.Buffer)
                isInputSinglePartition = false;
                obj.Buffer = InputBuffer(1, isInputSinglePartition);
            end
            
            if ~obj.HasSorted
                obj.add(in);
                
                if info.IsLastChunk
                    obj.sortData();
                end
            end
            
            if obj.HasSorted
                [isFinished, out] = obj.getnext();
            else
                isFinished = false;
                out = obj.Buffer.getCompleteSlices(0);
                out = out{1};
                return;
            end
        end
    end
    
    methods (Access = private)
        function add(obj, chunk)
            %ADD Add a chunk to held data.
            
            whosData = whos('chunk');
            obj.Buffer.add(false, {chunk});
            obj.BufferSizeInBytes = obj.BufferSizeInBytes + whosData.bytes;
            
            if obj.BufferSizeInBytes > obj.maxBufferSize()
                obj.spillBuffer();
            end
        end
        
        function sortData(obj)
            %SORT Sort the contents of all held data.
            
            if isempty(obj.SpilledDataPaths)
                % In-memory case
                data = obj.Buffer.getAll();
                obj.Buffer.add(false, {feval(obj.SortFunctionHandle, data{1})});
            else
                % Out-of-memory case
                obj.spillBuffer();
                obj.mergeSort();
            end
            obj.HasSorted = true;
        end
        
        function [isFinished, chunk] = getnext(obj)
            %GETNEXT Retrieve the next chunk from held data.
            
            if isempty(obj.NumSlicesPerChunk)
                obj.initializeNumSlicesPerChunk();
            end
            
            if isempty(obj.FinalMerger)
                % In-memory case
                chunk = obj.Buffer.getCompleteSlices(obj.NumSlicesPerChunk);
                chunk = chunk{1};
                isFinished = (obj.Buffer.NumBufferedSlices(1) == 0);
            else
                % Out-of-memory case
                chunk = read(obj.FinalMerger);
                isFinished = ~hasdata(obj.FinalMerger);
            end
        end
        
        function initializeNumSlicesPerChunk(obj)
            %INITIALIZENUMSLICESPERCHUNK Initialize the value of
            % NumSlicesPerChunk based on the current buffer and buffer size.
            
            numBytesPerSlice = obj.BufferSizeInBytes / obj.Buffer.NumBufferedSlices;
            obj.NumSlicesPerChunk = max(1, ceil(obj.chunkSize / numBytesPerSlice));
        end
        
        function spillBuffer(obj)
            %SPILLBUFFER Spill the contents of the in-memory buffer on-to
            %  disk in a sorted order.
            
            import matlab.bigdata.internal.io.WriteFunction;
            import matlab.bigdata.internal.util.TempFolder;
            
            if isempty(obj.DataFolder)
                obj.DataFolder = TempFolder;
            end
            if isempty(obj.NumSlicesPerChunk)
                obj.initializeNumSlicesPerChunk();
            end
            
            data = obj.Buffer.getAll();
            data = feval(obj.SortFunctionHandle, data{1});
            if isempty(data)
                return;
            end
            
            nextSpilledDataIndex = numel(obj.SpilledDataPaths) + 1;
            location = fullfile(obj.DataFolder.Path, sprintf('part-%05i', nextSpilledDataIndex));
            isDatastore = false;
            iWriteDataToDisk(location, data, isDatastore);
            
            obj.BufferSizeInBytes = 0;
            obj.SpilledDataPaths{end + 1} = location;
        end
        
        function mergeSort(obj)
            %MERGESORT Perform a merge-sort of data on disk.
            %
            % This sets the FinalMerger property of this object to a
            % datastore-like object that will read all of the data in
            % sorted order chunkwise.
            
            import matlab.bigdata.internal.util.TempFolder;
            
            % If there are more TallDatastore folders than we can open at
            % once, we need to reduce this number. This is done by picking
            % subsets and merging those into a single folder first.
            maxNumDatastores = obj.maxNumDatastores;
            while numel(obj.SpilledDataPaths) > maxNumDatastores
                newDataFolder = TempFolder;
                newSpilledDataPaths = cell(1, ceil(numel(obj.SpilledDataPaths) / maxNumDatastores));
                
                for ii = 1 : numel(newSpilledDataPaths)
                    startIndex = (ii - 1) * maxNumDatastores + 1;
                    endIndex = ii * maxNumDatastores;
                    spilledDataPaths = obj.SpilledDataPaths(startIndex : min(endIndex, end));
                    
                    isDatastore = true;
                    newSpilledDataPaths{ii} = fullfile(newDataFolder.Path, sprintf('part-%05i', ii));
                    iWriteDataToDisk(newSpilledDataPaths{ii}, obj.createSortMerger(spilledDataPaths), isDatastore);
                end
                
                obj.DataFolder = newDataFolder;
                obj.SpilledDataPaths = newSpilledDataPaths;
            end
            
            obj.FinalMerger = obj.createSortMerger(obj.SpilledDataPaths);
        end
        
        function merger = createSortMerger(obj, paths)
            %CREATESORTMERGER Create a SortedDatastoreMerger from the given
            %  collection of paths.
            
            import matlab.bigdata.internal.io.SortedDatastoreMerger;
            import matlab.io.datastore.TallDatastore;
            
            datastores = cell(size(paths));
            for ii = 1:numel(paths)
                datastores{ii} = TallDatastore(paths{ii}, 'ReadSize', obj.NumSlicesPerChunk);
            end
            merger = SortedDatastoreMerger(obj.SortFunctionHandle, datastores{:});
        end
    end
    
    methods (Static)
        function out = maxBufferSize(in)
            % Persistent value for controlling the maximum buffer size
            % before this object spills to disk.
            
            import matlab.bigdata.internal.io.ExternalSortFunction;
            
            persistent value;
            if isempty(value)
                value = ExternalSortFunction.DEFAULT_MAX_BUFFER_SIZE_IN_BYTES;
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
            
            import matlab.bigdata.internal.io.ExternalSortFunction;
            
            persistent value;
            if isempty(value)
                value = ExternalSortFunction.DEFAULT_CHUNK_SIZE_IN_BYTES;
            end
            if nargout
                out = value;
            end
            if nargin
                value = in;
            end
        end
        
        function out = maxNumDatastores(in)
            % Persistent value for controlling the maximum allowed number
            % of datastores open simultaneously during merge-sort.
            
            import matlab.bigdata.internal.io.ExternalSortFunction;
            
            persistent value;
            if isempty(value)
                value = ExternalSortFunction.DEFAULT_MAX_NUM_DATASTORES;
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

function iWriteDataToDisk(location, ds, isDatastore)
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
if isDatastore
    while hasdata(ds)
        data = read(ds);
        info.IsLastChunk = ~hasdata(ds);
        feval(writer, info, data);
    end
else
    data = ds;
    feval(writer, info, data);
end
end

function iCreateDirectory(path)
% Helper function that creates a directory with no warnings.
[success, msgId, message] = mkdir(path);
if ~success
    error(msgId, '%s', message);
end
end
