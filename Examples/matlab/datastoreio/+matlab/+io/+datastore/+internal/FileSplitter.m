classdef (Abstract) FileSplitter < matlab.io.datastore.internal.FileBasedSplitter
%FileSplitter   Class for creating splits from filenames.

%   Copyright 2014-2015 The MathWorks, Inc.

    properties (Access = 'public')
        Files;
        Splits;
    end
    
    properties (SetAccess = 'private', GetAccess = 'protected')
        SplitSize;
    end
    
    properties (Constant = true, Access = 'protected')
        DEFAULT_SPLIT_SIZE = 32*1024*1024; % 32 mega bytes
    end
    
    methods (Static = true, Access = 'public')
        function split = createBasicSplit(filepath, offset, sz)
            % Helper function to create FileSplitter split from PCT Hadoop split.
            split = struct(...
                'Filename', filepath, ...
                'Offset', offset, ...
                'Size', sz, ...
                'FileSize', 0, ...
                'FileIndex', 1);
        end
    end
    
    methods (Static = true, Access = 'protected')
        function [files, splits, splitSize] = createArgs(files, splitSize)
            % Return splitter constructor args from filenames and splitSize
            import matlab.io.datastore.internal.FileSplitter;
            import matlab.io.datastore.internal.pathLookup;
            
            narginchk(1,2);
            
            if nargin < 2
                splitSize = FileSplitter.DEFAULT_SPLIT_SIZE;
            end
            
            % FOR EMPTY DATASTORES
            if isempty(files)
                files = {};
                splits = [];
                return;
            end
            
            % splitSize can be Inf or a positive integer
            if ~isinf(splitSize)
                try
                    validateattributes(splitSize, {'numeric'}, ...
                                        {'scalar', 'positive', 'integer'});
                catch
                    error(message('MATLAB:datastoreio:filesplitter:invalidSplitSize'));
                end
            end
            
            if ischar(files)
                files = { files };
            elseif ~iscellstr(files) || (iscell(files) && isempty(files))
                error(message('MATLAB:datastoreio:pathlookup:invalidFilesInput'));
            end
            [files, fileSizes] = pathLookup(files);
            % adding file indices to the split info to support partition
            % across repeated files.
            fileIdcs = 1:numel(files);
            
                function splits = getSplitsFromPathCell(fileCell, filesize, fileIdx)
                    splits = ...
                        matlab.io.datastore.internal.FileSplitter.getSplitsFromPath(...
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

        function [files, splits, splitSize] = createFromSplitsArgs(splits)
            % Create a splitter from existing splits
            import matlab.io.datastore.internal.FileSplitter;
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
                    all(fileSizes < FileSplitter.DEFAULT_SPLIT_SIZE)
                    splitSize = FileSplitter.DEFAULT_SPLIT_SIZE;
                else
                    splitSize = Inf;                    
                end                    
                
                % find the unique files using file indices
                [~, idxs, ia] = unique([splits.FileIndex], 'stable');
                
                % reset the FileIndices for the current splits
                for ii = 1:numel(splits)
                    splits(ii).FileIndex = ia(ii);
                end
                
                files = {splits(idxs).Filename};
                return;
            else
                files = {};
                splits = [];
                splitSize = FileSplitter.DEFAULT_SPLIT_SIZE;
            end
        end
    end
    
    methods (Access = 'protected')
        function this = FileSplitter(files, splits, splitSize)
            this.Files = files;
            this.Splits = splits;
            
            if nargin == 2
                splitSize = this.DEFAULT_SPLIT_SIZE;
            end
            
            this.SplitSize = splitSize;
        end
    end
    
    methods (Access = 'public')
        % A FileSplitter can be a full file splitter or a chunked splitter
        % based on its SplitSize
        function tf = isFullFileSplitter(splitter)
            if isinf(splitter.SplitSize)
                tf = true;
            else
                tf = false;
            end
        end
        
        % A FileSplitter that has been partitioned cannot guarantee that
        % the contained collection of splits is equivalent to creating a new
        % splitter from the Files property. This method allows clients of
        % FileSplitter to guard against this.
        function tf = isSplitsOverAllOfFiles(splitter)
            splits = splitter.Splits;
            if isempty(splits)
                tf = true;
                return;
            end
            fileIdx = [splits.FileIndex];
            uniqueFileIdx = unique(fileIdx, 'stable');
            for ii = 1:numel(uniqueFileIdx)
                fileSplitsLogIdx = (fileIdx == uniqueFileIdx(ii));
                fileSplits = splits(fileSplitsLogIdx);
                fileSplitSize = [fileSplits.Size];
                fileSize = fileSplits(1).FileSize;
                if sum(fileSplitSize) ~= fileSize
                    tf = false;
                    return;
                end
            end
            tf = true;
        end
        
        % function used to change the splitsize on an existing splitter.
        function changeSplitSize(splitter, splitSize)
            splits = splitter.Splits;
            % nothing to do for an empty splitter
            if isempty(splits)
                return
            end
            
            % nothing to do if the splitsize is unchanged
            if isequal(splitter.SplitSize, splitSize)
                return
            end
            
            % find the unique files using file indices
            [~, idxs] = unique([splits.FileIndex], 'stable');
            
            % recreate splits using the specified split size
            splits = arrayfun(@getSplitsFromPathCell, ...
                              splitter.Files, [splits(idxs).FileSize], ...
                              1:numel(splitter.Files), 'UniformOutput', false);

                function splits = getSplitsFromPathCell(fileCell, filesize, fileIdx)
                    splits = ...
                        matlab.io.datastore.internal.FileSplitter.getSplitsFromPath(...
                            fileCell{1}, splitSize, filesize, fileIdx);
                end
                          
            % set the new splits and the split size on the splitter
            splitter.Splits = [splits{:}];
            splitter.SplitSize = splitSize;
        end
    end
end