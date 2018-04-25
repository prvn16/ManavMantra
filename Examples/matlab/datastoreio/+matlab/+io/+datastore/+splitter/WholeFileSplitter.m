classdef (Abstract, Hidden) WholeFileSplitter < matlab.io.datastore.splitter.FileSizeBasedSplitter
% WHOLEFILESPLITTER Splitter for creating full file splits.
%
% See also - matlab.io.datastore.WholeFileCustomReadSplitter.

%   Copyright 2015 The MathWorks, Inc.

    methods (Static, Hidden, Access = protected)
        function splits = createArgs(files, fileSizes, includeSubfolders)
            if ischar(files)
                files = { files };
            end
            if iscell(files) && ~isempty(files) && isempty(fileSizes)
                % if input files are not resolved use pathLookup.
                [files, fileSizes] = matlab.io.datastore.internal.pathLookup(files, includeSubfolders);
            end
            splits = [];
            if ~isempty(files)
                if ~iscellstr(files)
                    error(message('MATLAB:datastoreio:filesplitter:invalidFilesInput'));
                end
                numFiles = numel(files);
                fileIdcs = num2cell((1:numFiles)');
                fileSizes = num2cell(fileSizes(:));
                offsetSizes = num2cell(zeros(numFiles,1));
                splits = struct('Filename', files, ...
                                'Size', fileSizes, ... % Initialize file Sizes
                                'Offset', offsetSizes, ...% All offsets are zeros
                                'FileSize', fileSizes, ...% Initialize file sizes
                                'FileIndex', fileIdcs);
            end
        end

    end

    methods (Static, Hidden)
        % Helper function to create a FileSizeBasedSplitter split from PCT Hadoop split.
        function split = createBasicSplit(filepath, offset, size)
            % Call pathLookup:
            % When creating from hadoop split, it needs to have proper schemes
            % for matlab functions to work.
            filepath = matlab.io.datastore.internal.pathLookup(filepath);
            split = struct('Filename', filepath, 'Offset', offset, ...
                'Size', size, 'FileSize', size, ...
                'FileIndex', 1);
        end
    end

    methods (Hidden)
        % A WholeFileSplitter is always a full file splitter.
        function tf = isFullFileSplitter(~)
            tf = true;
        end
        % A WholeFileSplitter always have splits over all files.
        function tf = isSplitsOverAllOfFiles(~)
            tf = true;
        end
        % Return file sizes as a column vector for specific indices
        function fileSizes = getFileSizes(splitter, idxes)
            if splitter.NumSplits == 0
                fileSizes = [];
                return;
            end
            if nargin == 1
                fileSizes = [splitter.Splits.FileSize];
            else
                fileSizes = [splitter.Splits(idxes).FileSize];
            end
            fileSizes = fileSizes(:);
        end
    end

    methods (Access = protected)
        function splitter = WholeFileSplitter(splits)
            splitter@matlab.io.datastore.splitter.FileSizeBasedSplitter(splits, inf);
        end
    end
end
