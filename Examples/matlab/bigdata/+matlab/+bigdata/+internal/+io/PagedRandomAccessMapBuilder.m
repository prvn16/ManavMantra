%PagedRandomAccessMapBuilder
% The builder class for PagedRandomAccessMap. This expects to be given
% pairs of <source index, slice>, in order sorted by source index. The map
% built from this will allow random access.

% Copyright 2017 The MathWorks, Inc.

classdef PagedRandomAccessMapBuilder < handle
    
    properties (GetAccess = private, SetAccess = immutable)
        % The number of pages in the map.
        NumPages;
        
        % The number of bytes per page.
        PageSizeInBytes;
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
        MemoryPages = struct('Id', {}, 'Size', {}, 'Indices', {}, 'Slices', {});
        
        % A array of slice IDs that mark the first slice ID of each
        % corresponding page.
        PageBoundaries = [];
        
        % An array of page sizes.
        PageSizes = [];
        
        % A cell array containing an empty chunk. This is empty until add
        % has been invoked.
        EmptyCell = {};
        
        % The ID to be attached to the next built page.
        NextPageId = 1;
        
        % The slices to be added to the next built page.
        NextPageSlices;
        
        % The source indices to be attached to the next built page.
        NextPageIndices;
        
        % The temporary folder on disk to spill pages that no longer fit in
        % memory.
        Folder;
    end
    
    methods
        function obj = PagedRandomAccessMapBuilder(numPages, pageSizeInBytes)
            % Construct a builder, that will build a map containing
            % numPages pages each of size pageSizeInBytes. If no input
            % arguments are given, the default will be 10 pages each of
            % size 10 MB.
            if nargin < 1
                numPages = 10;
            end
            obj.NumPages = numPages;
            
            if nargin < 2
                pageSizeInBytes = 10485760; % 10 MB
            end
            obj.PageSizeInBytes = pageSizeInBytes;
            
            obj.Folder = matlab.bigdata.internal.util.TempFolder();
        end
        
        function add(obj, indices, slices)
            % Add <source index, slice> pairs to the map. This expects to
            % be given the data in order sorted by index.
            import matlab.bigdata.internal.util.indexSlices;
            assert(~isempty(obj.Folder), ['Assertion failed: ' ...
                'Attempted to invoke PagedRandomAccessMapBuilder/add after build already invoked.']);
            assert(size(indices, 1) == size(slices, 1), ['Assertion failed: ' ...
                'PagedRandomAccessMapBuilder/add mismatch between height of slices and height of data.']);
            
            if isempty(obj.EmptyCell)
                obj.EmptyCell = {indexSlices(slices, [])};
            end
            
            if ~isempty(obj.NextPageSlices)
                slices = [obj.NextPageSlices; slices];
                indices = [obj.NextPageIndices; indices];
                obj.NextPageSlices = [];
                obj.NextPageIndices = [];
            end
            
            obj.NextPageSlices = slices;
            obj.NextPageIndices = indices;
            sizeInBytes = iGetSizeInBytes(indices, slices);
            if sizeInBytes > obj.PageSizeInBytes
                obj.addPage();
            end
        end
        
        function map = build(obj)
            % Build the map. Once this is done, the builder is no longer
            % valid and any further modification will assert.
            assert(~isempty(obj.Folder), ['Assertion failed: ' ...
                'Attempted to invoke PagedRandomAccessMapBuilder/build after build already invoked.']);
            assert(~isempty(obj.EmptyCell), ['Assertion failed: ' ...
                'Attempted to invoke PagedRandomAccessMapBuilder/build without any calls to add.']);
            if ~isempty(obj.NextPageSlices)
                obj.addPage();
            end
            map = matlab.bigdata.internal.io.PagedRandomAccessMap(...
                obj.MemoryPages, obj.Folder, [obj.PageBoundaries, inf, inf], obj.PageSizes, obj.EmptyCell{1});
            obj.MemoryPages = [];
            obj.Folder = [];
            obj.PageBoundaries = [];
            obj.PageSizes = [];
        end
    end
    
    methods (Access = private)
        function addPage(obj, sizeInBytes)
            % Construct a new page by consuming slices from the NextPage
            % properties. This will be added to either memory or disk
            % depending on availability.
            indices = obj.NextPageIndices;
            obj.NextPageIndices = [];
            slices = obj.NextPageSlices;
            obj.NextPageSlices = [];
            if nargin < 2
                sizeInBytes = iGetSizeInBytes(indices, slices);
            end
            page = struct('Id', {obj.NextPageId}, ...
                'Size', {sizeInBytes}, ...
                'Indices', {indices}, ...
                'Slices', {slices});
            obj.NextPageId = obj.NextPageId + 1;
            
            obj.PageSizes(page.Id) = page.Size;
            obj.PageBoundaries(page.Id) = min(page.Indices);
            if numel(obj.MemoryPages) < obj.NumPages
                obj.MemoryPages(end + 1, 1) = page;
            else
                obj.spillPageToDisk(obj.Folder, page);
            end
        end
    end
    
    methods (Access = {?matlab.bigdata.internal.io.PagedRandomAccessMap}, Static)
        function spillPageToDisk(folder, page)
            % Function to spill to disk. This is exposed to the map itself
            % to allow spill to disk be lazily done.
            import matlab.bigdata.internal.io.PagedRandomAccessMapBuilder;
            filename = PagedRandomAccessMapBuilder.getPageFilename(folder, page.Id);
            save(filename, '-struct', 'page');
        end
        
        function filename = getPageFilename(folder, pageId)
            % Get the filename for the corresponding page ID.
            filename = fullfile(folder.Path, sprintf('page_06%i.mat', pageId));
        end
    end
end

function sizeInBytes = iGetSizeInBytes(indices, slices) %#ok<INUSD>
% Get the size in bytes of the given pairs of <source indices, slices>.
slicesMetadata = whos('slices');
indicesMetadata = whos('indices');
sizeInBytes = slicesMetadata.bytes + indicesMetadata.bytes;
end
