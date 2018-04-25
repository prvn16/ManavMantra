classdef SortedDatastoreMerger < handle
    %SortedDatastoreMerger
    % Helper class that merges several datastores of sorted data together
    % to form one larger datastore-like object of sorted data.
    %
    % This requires that the input datastores are each already in sorted
    % order.
    %
    % This implementation works by holding two things:
    %   1. A "working set" buffer of the data that has already been read.
    %   2. For each datastore, the index of the last slice in the buffer
    %   that originated from the datastore.
    % On each iteration, chunks are read from specific datastores and added
    % to the buffer. As datastores are each individually in sorted order,
    % we can guarantee that some part of the beginning of the buffer after
    % sort does not overlap with data yet to be read. This is emitted as
    % the output.
    %
    
    %   Copyright 2016 The MathWorks, Inc.
    
    properties (GetAccess = private, SetAccess = immutable)
        % Function handle that can sort an in-memory chunk of data.
        SortFunctionHandle;
        
        % The list of datastores to be merged.
        Datastores = {};
    end
    
    properties (Access = private)
        % A cache of the output of HASDATA for each datastore.
        HasDataVector = false(1,0);
        
        % A collection of slices that have been read into memory. This is
        % kept in a sorted order.
        Buffer;
        
        % For each datastore, the index of the last slice in the buffer that
        % originated from that datastore. If no such slice exists, this
        % will be zero for that datastore.
        LastBufferedInputIndices;
    end
    
    methods
        function obj = SortedDatastoreMerger(sortFunctionHandle, varargin)
            %SORTEDDATASTOREMERGER The main constructor.
            %
            % Syntax:
            %   obj = SortedDatastoreMerger(sortFunctionHandle,ds1,ds2,..)
            %
            
            import matlab.bigdata.internal.util.indexSlices;
            
            obj.SortFunctionHandle = sortFunctionHandle;
            obj.Datastores = cellfun(@copy, varargin, 'UniformOutput', false);
            cellfun(@reset, obj.Datastores);
            obj.HasDataVector = cellfun(@hasdata, obj.Datastores);
            
            obj.Buffer = indexSlices(preview(obj.Datastores{1}), []);
            obj.LastBufferedInputIndices = zeros(1, numel(varargin));
        end
        
        function tf = hasdata(obj)
            %HASDATA Returns true if and only if there is the possibility
            %  of more data.
            
            tf = ~isempty(obj.Buffer) || any(obj.HasDataVector);
        end
        
        function out = read(obj)
            %READ Return one chunk of the data.
            
            % Read new chunks
            inputsToRead = find(obj.LastBufferedInputIndices == 0 & obj.HasDataVector);
            newChunks = cell(size(inputsToRead));
            for ii = 1 : numel(newChunks)
                inputIndex = inputsToRead(ii);
                newChunks{ii} = read(obj.Datastores{inputIndex});
                obj.HasDataVector(inputIndex) = hasdata(obj.Datastores{inputIndex});
            end
            
            obj.insert(inputsToRead, newChunks);
            out = obj.popSortedSlices();
        end
    end
    
    methods (Access = private)
        function insert(obj, chunkInputIndices, newChunks)
            %INSERT Insert the given chunks into the sorted buffer.
            
            % No need to insert empty chunks. Discard these here.
            bufferHeight = size(obj.Buffer, 1);
            newChunkHeights = cellfun(@(x) size(x, 1), newChunks);
            if any(newChunkHeights == 0)
                chunkInputIndices(newChunkHeights == 0) = [];
                newChunks(newChunkHeights == 0) = [];
                newChunkHeights(newChunkHeights == 0) = [];
            end
            if isempty(newChunks)
                return;
            end
            
            % Insert the new chunks into the buffer and re-sort.
            [obj.Buffer, idx] = feval(obj.SortFunctionHandle, vertcat(obj.Buffer, newChunks{:}));
            
            % Update the positions of the last held slice of each input.
            %  * Every input with a new chunk has a new last slice.
            %  * Every other input must also be updated as their last slice
            %    might have been pushed back by the re-sort.
            lastBufferedInputIndices = obj.LastBufferedInputIndices;
            lastBufferedInputIndices(chunkInputIndices) = bufferHeight + cumsum(newChunkHeights);
            [~, obj.LastBufferedInputIndices] = ismember(lastBufferedInputIndices, idx);
        end
        
        function out = popSortedSlices(obj)
            %POPSORTEDSLICES Pop all slices from the beginning of the
            %buffer that are guaranteed to be before all data that has yet
            %to be read.
            
            import matlab.bigdata.internal.util.indexSlices;
            
            lastBufferedInputIndices = obj.LastBufferedInputIndices;
            lastCompleteIndex = min(lastBufferedInputIndices(obj.HasDataVector));
            if isempty(lastCompleteIndex)
                lastCompleteIndex = size(obj.Buffer, 1);
            end
            
            out = indexSlices(obj.Buffer, 1:lastCompleteIndex);
            obj.Buffer = indexSlices(obj.Buffer, lastCompleteIndex + 1 : size(obj.Buffer, 1));
            
            lastBufferedInputIndices = max(lastBufferedInputIndices - lastCompleteIndex, 0);
            obj.LastBufferedInputIndices = lastBufferedInputIndices;
        end
    end
end
