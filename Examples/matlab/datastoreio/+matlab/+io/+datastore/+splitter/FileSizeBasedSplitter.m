classdef (Abstract) FileSizeBasedSplitter < matlab.io.datastore.splitter.FileBasedSplitter
%FileSizeBasedSplitter   Class for creating splits from filenames based on file sizes.

%   Copyright 2015 The MathWorks, Inc.

    properties (Dependent, GetAccess = 'public', SetAccess = 'private')
        Files;
    end
    
    properties (SetAccess = 'private', GetAccess = 'protected')
        SplitSize;
    end

    properties (Constant, Access = 'protected')
        DEFAULT_SPLIT_SIZE = 32*1024*1024; % 32 mega bytes
    end
    
    methods (Static)
        function split = createBasicSplit(filepath, offset, sz)
            % Helper function to create FileSizeBasedSplitter split from PCT Hadoop split.
            split = struct(...
                'Filename', filepath, ...
                'Offset', offset, ...
                'Size', sz, ...
                'FileSize', 0, ...
                'FileIndex', 1);
        end
        
        function splits = createBasicSplitsWithMaxSplitSize(filepath, offset, sz, maxSplitSize)
            % Helper function to create FileSizeBasedSplitter split from PCT
            % Hadoop split while breaking up the splits to fulfill a
            % maximum split size constraint.
            import matlab.io.datastore.splitter.FileSizeBasedSplitter;
            
            if sz == 0
                splits = FileSizeBasedSplitter.createBasicSplit(filepath, offset, sz);
                return;
            end
            
            offsets = offset + (0 : maxSplitSize : sz - 1);
            
            numSplits = numel(offsets);
            finalSplitSize = mod(sz - 1, maxSplitSize) + 1;
            sizes = [maxSplitSize * ones(1, numSplits - 1), finalSplitSize];
            
            splits = struct(...
                'Filename', {filepath}, ...
                'Offset', num2cell(offsets), ...
                'Size', num2cell(sizes), ...
                'FileSize', {offset + sz}, ...
                'FileIndex', {1});
        end
    end

    methods (Static, Access = 'protected')

        function [splits, splitSize] = createArgs(files, splitSize, fileSizes)
        %CREATEARGS Creates splitter constructor arguments.
        %
            narginchk(1,3);
            import matlab.io.datastore.splitter.FileSizeBasedSplitter;
            
            if nargin < 2
                splitSize = FileSizeBasedSplitter.DEFAULT_SPLIT_SIZE;
                fileSizes = [];
            end
            
            if nargin < 3                
                fileSizes = [];
            end
            
            % FOR EMPTY DATASTORES
            if isempty(files)
                splits = []; return;
            end
            
            % if fileSizes is passed in explicitly, then no need to resolve
            if isempty(fileSizes)
                [files, fileSizes] = matlab.io.datastore.internal.pathLookup(files);
            end
            
            % adding file indices to the split info to support partition
            % across repeated files.
            fileIdcs = (1:numel(files))';
            
                function splits = getSplitsFromPathCell(fileCell, filesize, fileIdx)
                    splits = ...
                        matlab.io.datastore.splitter.FileSizeBasedSplitter.getSplitsFromPath(...
                            fileCell{1}, splitSize, filesize, fileIdx);
                end
            
            splits = arrayfun(@getSplitsFromPathCell, ...
                              files, fileSizes, fileIdcs, 'UniformOutput', false);
            splits = [splits{:}];
        end
        
        function splits = getSplitsFromPath(filepath, chunksize, filesize, fileIdx)
            if filesize == -1
                % imports
                import matlab.internal.datatypes.warningWithoutTrace;

                % Can happen because of permissions, etc. Not sure if a warning is
                % the right thing to do here.
                warningWithoutTrace(message(...
                    'MATLAB:datastoreio:filesplitter:invalidFileSize', filepath));
                splits = [];
                return;
            end
            
            if filesize == 0
                splits.Filename = filepath;
                splits.FileSize = 0;
                splits.Offset = 0;
                splits.Size = 0;
                splits.FileIndex = fileIdx;
                return;
            end
            
            offsets = num2cell(0 : chunksize : filesize-1);
            numSplits = numel(offsets);
            if numSplits == 0
                splits = [];
                return;
            end
            
            [splits(1:numSplits).Filename] = deal(filepath);
            
            [splits.FileSize] = deal(filesize);
            
            [splits.Offset] = deal(offsets{:});
            
            [splits(1:numSplits-1).Size] = deal(chunksize);
            splits(end).Size = filesize-offsets{end};
            
            [splits.FileSize] = deal(filesize);
            
            [splits.FileIndex] = deal(fileIdx);
        end

        function [splits, splitSize] = createFromSplitsArgs(splits)
        %CREATEFROMSPLITARGS Creates splitter constructor arguments.
        %
            import matlab.io.datastore.splitter.FileSizeBasedSplitter;
            if ~isempty(splits)
                if ~isstruct(splits) || ...
                   ~isempty(setdiff({'Filename', 'Offset', 'Size', 'FileSize', 'FileIndex'}, fieldnames(splits)))
                      error(message('MATLAB:datastoreio:filesplitter:invalidSplits'));
                end
                
                % validate full file splits or chunked splits
                offsets = [splits.Offset];
                sizes = [splits.Size];
                fileSizes = [splits.FileSize];
                if  any(offsets) ||  ~isequal(fileSizes, sizes) || ...
                    all(fileSizes < FileSizeBasedSplitter.DEFAULT_SPLIT_SIZE)
                    splitSize = FileSizeBasedSplitter.DEFAULT_SPLIT_SIZE;
                else
                    splitSize = Inf;                    
                end                    
                
                % find the unique files using file indices
                [~, ~, ia] = unique([splits.FileIndex], 'stable');
                
                % reset the FileIndices for the current splits
                for ii = 1:numel(splits)
                    splits(ii).FileIndex = ia(ii);
                end
                return;
            else
                splits = [];
                splitSize = FileSizeBasedSplitter.DEFAULT_SPLIT_SIZE;
            end
        end
    end
    
    methods (Access = 'protected')
        function splitter = FileSizeBasedSplitter(splits, splitSize)
            splitter.Splits = splits;
            if nargin < 2
                splitSize = this.DEFAULT_SPLIT_SIZE;
            end
            splitter.SplitSize = splitSize;
        end
        
        % function used to change the splitsize on an existing splitter.
        function changeSplitSize(splitter, splitSize, forceChange)
            splits = splitter.Splits;
            if nargin < 3
                % Do not force change of split size by default
                forceChange = false;
            end
            % nothing to do for an empty splitter, or same split size
            % If forceChange is true, we want to change resize the splits (for example,
            % when the split is from Hadoop using initFromFileSplit)
            if isempty(splits) || (splitSize == splitter.SplitSize && ~forceChange)
                return
            end
            
            % find the unique files using file indices
            [~, idxs] = unique([splits.FileIndex], 'stable');
            
            % recreate splits using the specified split size
            splits = arrayfun(@getSplitsFromPathCell, ...
                              splitter.Files, [splits(idxs).FileSize]', ...
                              (1:numel(splitter.Files))', 'UniformOutput', false);

                function splits = getSplitsFromPathCell(fileCell, filesize, fileIdx)
                    splits = ...
                        matlab.io.datastore.splitter.FileSizeBasedSplitter.getSplitsFromPath(...
                            fileCell{1}, splitSize, filesize, fileIdx);
                end
                          
            % set the new splits and the split size on the splitter
            splitter.Splits = [splits{:}];
            splitter.SplitSize = splitSize;
        end
    end
    
    methods
        % A FileSizeBasedSplitter can be a full file splitter or a chunked splitter
        % based on its SplitSize
        function tf = isFullFileSplitter(splitter)
            if isinf(splitter.SplitSize)
                tf = true;
            else
                tf = false;
            end
        end
        
        % A FileSizeBasedSplitter that has been partitioned cannot guarantee that
        % the contained collection of splits is equivalent to creating a new
        % splitter from the Files property. This method allows clients of
        % FileSizeBasedSplitter to guard against this.
        function tf = isSplitsOverAllOfFiles(splitter)
            splits = splitter.Splits;
            if isempty(splits)
                tf = true;
                return;
            end
            fileIdx = [splits.FileIndex];
            uniqueFileIdx = unique(fileIdx, 'stable');
            for ii = 1:numel(uniqueFileIdx)
                fileSplits = splits(fileIdx == uniqueFileIdx(ii));
                if sum([fileSplits.Size]) ~= fileSplits(1).FileSize
                    tf = false;
                    return;
                end
            end
            tf = true;
        end
    end
    
    methods
        function files = get.Files(splitter)
            splits = splitter.Splits;
            if isempty(splits)
                files = {}; return;
            end
            % find the unique files using file indices
            [~, idxs] = unique([splits.FileIndex], 'stable');
            files = { splits(idxs).Filename }';
        end
        function set.Files(~,~)
        end
    end    
end
