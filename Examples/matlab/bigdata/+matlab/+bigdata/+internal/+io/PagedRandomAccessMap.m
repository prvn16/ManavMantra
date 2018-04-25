%PagedRandomAccessMap
% A vectorized random access map that can store chunks to disk similar to
% how a page cache would work.
%
% This allows for random access retrieving of out-of-memory data by index.
% It will be optimal in cases where the ordering keeps similar indices near
% each other.

% Copyright 2017 The MathWorks, Inc.

classdef PagedRandomAccessMap < handle
    
    properties (GetAccess = private, SetAccess = immutable)
        % The temporary folder on disk to spill pages that no longer fit in
        % memory.
        Folder;
        
        % A array of slice IDs that mark the first slice ID of each
        % corresponding page.
        PageBoundaries;
        
        % An array of page sizes.
        PageSizes;
        
        % An empty of the appropriate size and type.
        Empty;
    end
    
    properties (Access = private)
        % The current set of pages in memory. Each entry is a struct with
        % 4 fields:
        %  * Id: A unique ID for this page. This is an index into
        %        PageBoundaries / PageSizes and will be used to determine
        %        filename on disk.
        %  * Size: The size in bytes of this memory page.
        %  * Indices: The indices of the corresponding slices of data. This
        %             will be in sorted order.
        %  * Slices: Slices of data corresponding to indices.
        MemoryPages;
    end
    
    methods
        function out = get(obj, indices)
            % Get the slices of data corresponding to the given source
            % indices. The indices can be in any order, with duplicates
            % allowed.
            import matlab.bigdata.internal.util.indexSlices;
            import matlab.bigdata.internal.util.vertcatCellContents;
            
            % Early exit if no indices.
            if isempty(indices)
                out = obj.Empty;
                return;
            end
            
            pageIndices = discretize(indices, obj.PageBoundaries);
            [uniquePageIndices, ~, uniquePageIndicesMap] = unique(pageIndices);
            
            memoryPageIds = [obj.MemoryPages.Id];
            [isPageInMemory, idx] = ismember(uniquePageIndices, memoryPageIds);
            
            % First deal with pages that are already in memory. This is so
            % we don't have to reload them in unnecessarily later.
            outIndices = cell(numel(uniquePageIndices), 1);
            out = cell(numel(uniquePageIndices), 1);
            for ii = 1 : numel(uniquePageIndices)
                if isPageInMemory(ii)
                    selectedIndices = unique(indices(ii == uniquePageIndicesMap));
                    isSelected = ismember(obj.MemoryPages(idx(ii)).Indices, selectedIndices);
                    outIndices{ii} = obj.MemoryPages(idx(ii)).Indices(isSelected);
                    out{ii} = indexSlices(obj.MemoryPages(idx(ii)).Slices, isSelected);
                end
            end
            
            % Move those pages to the front of the queue in order to get
            % LRU cache behavior.
            isMemoryPageTouched = ismember(memoryPageIds, uniquePageIndices);
            obj.MemoryPages = vertcat(obj.MemoryPages(isMemoryPageTouched), obj.MemoryPages(~isMemoryPageTouched));
            
            % Now deal with the pages that are only on disk.
            for ii = 1 : numel(uniquePageIndices)
                if ~isPageInMemory(ii)
                    obj.loadMemoryPage(uniquePageIndices(ii));
                    
                    selectedIndices = unique(indices(ii == uniquePageIndicesMap));
                    isSelected = ismember(obj.MemoryPages(1).Indices, selectedIndices);
                    outIndices{ii} = obj.MemoryPages(1).Indices(isSelected);
                    out{ii} = indexSlices(obj.MemoryPages(1).Slices, isSelected);
                end
            end
            
            out = vertcat(out{:});
            outIndices = vertcat(outIndices{:});
            [~, orderIdx] = ismember(indices, outIndices);
            out = indexSlices(out, orderIdx);
        end
    end
    
    methods (Access = {?matlab.bigdata.internal.io.PagedRandomAccessMapBuilder})
        function obj = PagedRandomAccessMap(memoryPages, folder, pageBoundaries, pageSizes, empty)
            % Private constructor for the builder.
            obj.MemoryPages = memoryPages;
            obj.Folder = folder;
            obj.PageBoundaries = pageBoundaries;
            obj.PageSizes = pageSizes;
            obj.Empty = empty;
        end
    end
    
    methods (Access = private)
        function loadMemoryPage(obj, pageId)
            % Load the page of given ID back into memory.
            import matlab.bigdata.internal.io.PagedRandomAccessMapBuilder;
            obj.dropMemoryPage();
            filename = PagedRandomAccessMapBuilder.getPageFilename(obj.Folder, pageId);
            page = load(filename);
            obj.MemoryPages = vertcat(page, obj.MemoryPages);
        end
        
        function dropMemoryPage(obj)
            % Drop the given page in memory. This has to check if the page
            % has been spilled to disk already as that is done lazily.
            import matlab.bigdata.internal.io.PagedRandomAccessMapBuilder;
            filename = PagedRandomAccessMapBuilder.getPageFilename(obj.Folder, obj.MemoryPages(end).Id);
            if exist(filename, 'file') ~= 2
                PagedRandomAccessMapBuilder.spillPageToDisk(obj.Folder, obj.MemoryPages(end));
            end
            obj.MemoryPages(end) = [];
        end
    end
end
