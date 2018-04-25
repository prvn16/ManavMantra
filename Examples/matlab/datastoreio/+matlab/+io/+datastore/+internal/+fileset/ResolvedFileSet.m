classdef (Abstract, Hidden, AllowedSubclasses = {?matlab.io.datastore.internal.fileset.InMemoryFileSet, ?matlab.io.datastore.internal.fileset.CompressedFileSet}) ResolvedFileSet < matlab.mixin.Copyable
%ResolvedFileSet An in-memory abstract FileSet for collecting files.
%
%   See also datastore, matlab.io.datastore.Partitionable.

%   Copyright 2017 The MathWorks, Inc.

    properties
        %NUMFILES Number of files represented by this file set object.
        NumFiles
        %FILESPLITSIZE Size in bytes to be used to represent a split of a file.
        FileSplitSize
    end

    properties (Access = protected)
        FileSizes
        %ACTUALFILESIZEIFSTRUCT The actual file size if LOCATION provided is a
        % struct containing the fields: FileName, Size and Offset
        % The value is either
        %    - Actual file's size calculated from path lookup,
        %      if the given location is a struct
        %    - double value -1 (DEFAULT_ACTUAL_FILE_SIZE_IF_NOT_STRUCT),
        %      if the given location is not a struct
        %   See also matlab.io.datastore.DsFileSet.
        ActualFileSizeIfStruct
        CurrentFileIndex
        CurrentOffset
        CurrentFileName
        StartOffset
        EndOffset
        %HOLDTOPARTITIONINDICES A boolean indicating to hold on to the partition
        % indices during the partition of the fileset object.
        HoldToPartitionIndices = false
        %PARTITIONINDICES A vector of partition indices held by the fileset
        % object during the partition of the fileset object.
        PartitionIndices
    end

    properties (Constant)
        % If the given location is not a struct, the default value for the property
        % ActualFileSizeIfStruct.
        DEFAULT_ACTUAL_FILE_SIZE_IF_NOT_STRUCT = -1
    end

    methods
        function fs = ResolvedFileSet(nvStruct)
            fs.FileSizes = nvStruct.FileSizes;
            fs.FileSplitSize = nvStruct.FileSplitSize;
            fs.StartOffset = nvStruct.StartOffset;
            fs.ActualFileSizeIfStruct = nvStruct.ActualFileSizeIfStruct;
            if isempty(nvStruct.Files)
                fs.EndOffset = 0;
            else
                fs.EndOffset = nvStruct.FileSizes(end);
            end
        end

        function subfs = partition(fs, N, ii)
            %PARTITION Return a partitioned part of the file set.
            %   SUBFS = PARTITION(FS,N,ii) returns a new file set, SUBFS, that represents
            %   the part of the files corresponding to the original file set, FS,
            %   given
            %       N  - the number of partitions for the original file set
            %       ii - the index chosen for the new file set
            %
            %   See also matlab.io.datastore.DsFileSet, nextfile, matlab.io.datastore.Partitionable.

            validateattributes(N, {'double'}, {'scalar', 'positive', 'integer'}, 'partition', 'NumPartitions');
            validateattributes(ii, {'double'}, {'scalar', 'positive', 'integer'}, 'partition', 'Index');
            if ii > N
                error(message('MATLAB:datastoreio:dsfileset:invalidPartitionIndex', ii));
            end

            % pigeonhole the files in the FileSet
            %    n(r-1) + 1 objects into n boxes
            if ischar(fs.FileSplitSize)
                rMinus1 = (0:fs.NumFiles - 1) / fs.NumFiles;
                splits = 0;
            else
                % FileSplitSize is specified
                allSizes = fs.FileSizes;
                splits = [];
                for jj = 1 : fs.NumFiles
                    % split each file based on FileSplitSize
                    thisSplit = 0:fs.FileSplitSize:allSizes(jj);
                    endOffset = [thisSplit(2:end)-1, allSizes(jj)];
                    if numel(thisSplit) > 1
                        splits = [splits; thisSplit', endOffset', repmat(jj,numel(thisSplit),1)];
                    else
                        splits = [splits; thisSplit, endOffset, jj];
                    end
                end
                rMinus1 = (0:size(splits,1) - 1) / size(splits,1);
            end

            boxIndices = floor(N * rMinus1) + 1;
            % find the file indices that belong to the given box index
            if ~splits
                fileIndices = find(boxIndices == ii);
            else
                % FileSplitSize is specified
                if ~isempty(boxIndices)
                    fileIndices = unique(splits(boxIndices == ii,3));
                else
                    fileIndices = [];
                end
            end

            % if fileIndices is empty we need a column vector to index file sizes
            % to form a table in the resolve method. See help for resolveAll.
            if isempty(fileIndices)
                fileIndices = fileIndices(:);
            end

            if fs.HoldToPartitionIndices
                % If the clients need these file indices, setHoldPartitionIndices(true)
                % must be called prior to partition of the fileset object.
                fs.PartitionIndices = fileIndices;
            end
            % Create a copy of the FileSet for the boxed file indices
            subfs = copyWithFileIndices(fs, fileIndices);

            % get the start and end offset for the partition
            startOffset = 0;
            if ~isempty(boxIndices) && ~ischar(fs.FileSplitSize)
                % save only the end offset of the last split in each
                % partition
                endOffset = splits(find(boxIndices == ii, 1, 'last'),2);
                startOffset = splits(find(boxIndices == ii, 1, 'first'),1);
            else
                if fs.NumFiles
                    endOffset = fs.FileSizes(fs.NumFiles);
                else
                    endOffset = 0;
                end
            end
            subfs.EndOffset = endOffset;
            subfs.StartOffset = startOffset;
            subfs.CurrentOffset = subfs.StartOffset;
        end

        function files = resolve(fs)
            [f, fsize] = resolveAll(fs);
            fsize = getActualFileSizeIfStruct(fs, fsize);
            files = table(f, fsize, 'VariableNames', {'FileName', 'FileSize'});
        end

        function file = nextfile(fs)
            if ~hasfile(fs)
                error(message('MATLAB:datastoreio:dsfileset:noMoreFiles'));
            end
            ci = fs.CurrentFileIndex;
            fsize = fs.FileSizes(ci);
            if ischar(fs.FileSplitSize)
                % If FileSplitSize is 'file' get the next file.
                f = resolveNextFile(fs);
                % CurrentOffset will always be the start offset for this FileSet.
                offset = fs.CurrentOffset;
                % Split size is the file size for a file. This could be the Size
                % passed using a LOCATION-struct or the size of the file.
                splitSize = fsize - offset;
                % Always increment to the next file.
                fs.CurrentFileIndex = ci + 1;
            else
                if fs.CurrentOffset == 0 || isempty(fs.CurrentFileName)
                    % only get the next file when CurrentOffset is 0 or
                    % filename was not initialized
                    fs.CurrentFileName = resolveNextFile(fs);
                end
                f = fs.CurrentFileName;
                offset = fs.CurrentOffset;
                splitSize = fs.FileSplitSize;
                if offset + splitSize > fsize
                    % split size is the remaining amount in the full file size.
                    splitSize = fsize - offset;
                end
                fs.CurrentOffset = fs.CurrentOffset + splitSize;
                if fs.CurrentOffset >= fsize || (fs.CurrentOffset >= fs.EndOffset ...
                        && fs.CurrentFileIndex == fs.NumFiles)
                    % Set the CurrentOffset to 0 once the current file is done.
                    if ci + 1 <= fs.NumFiles
                        fs.CurrentOffset = 0;
                    end
                    % Increment to the next file once the current file is done.
                    fs.CurrentFileIndex = ci + 1;
                end
            end
            fsize = getActualFileSizeIfStruct(fs, fsize);
            file = table(f, fsize, offset, splitSize, 'VariableNames', {'FileName', 'FileSize', 'Offset', 'SplitSize'});
        end

        function reset(fs)
            fs.NumFiles = numel(fs.FileSizes);
            fs.CurrentFileIndex = 1;
            if ~isempty(fs.StartOffset)
                fs.CurrentOffset = fs.StartOffset(1);
            else
                fs.CurrentOffset = [];
            end
        end

        function tf = hasfile(fs)
            tf = fs.CurrentFileIndex <= fs.NumFiles;
        end

        function N = maxpartitions(fs)
            if ischar(fs.FileSplitSize)
                N = fs.NumFiles;
            else
                N = sum(ceil(fs.FileSizes/fs.FileSplitSize));
            end
        end
    end

    methods (Abstract, Access = protected)
        %RESOLVEALL Return a resolved set of files and filesizes.
        %   Subclasses must implement how all files and filesizes are resolved.
        %   [FILES, FSIZES] = resolveAll(FS) returns resolved files and file
        %   sizes represented by the DsFileSet object.
        %       FILES - A string column vector of files
        %       FSIZES - A double column vector of file sizes
        %
        %   See also matlab.io.datastore.DsFileSet, resolve.
        [f, fs] = resolveAll(fs);

        % Subclasses must implement how each file will be resolved.
        f = resolveNextFile(fs);

        % Subclasses must implement how to obtain a column cell array of files
        % that can be obtained from the fileset object.
        getFilesAsCellStr(fs, indices);
    end

    methods (Abstract, Hidden)
        %COPYWITHFILEINDICES This copies the current object using the input indices.
        %   Based on the input indices fileset object creates a copy.
        %   Subclasses must implement on how they can be created from a list of file indices.
        newCopy = copyWithFileIndices(fs, varargin);

        %SETFILESANDFILESIZES Set the files and file sizes for the fileset object.
        %   This is useful when creating an empty file set object and setting the
        %   valid folders and files that are already resolved without any need for
        %   file existence or validity.
        setFilesAndFileSizes(fs, files, fileSizes);

        %SETSHUFFLEDINDICES Set the shuffled indices for files and file sizes of the fileset object.
        %   Any subsequent nextfile calls to the fileset object gets the files
        %   using the shuffled indices. This sets the corresponding file sizes to reflect
        %   the new indices.
        setShuffledIndices(fs, idxes);

        %SETDUPLICATEINDICES Set the duplicate indices for the fileset object.
        %   Any subsequent nextfile calls to the fileset object gets the files
        %   using the already existing indices and duplicate indices.
        setDuplicateIndices(fs, duplicateIndices, addedIndices);

        %COPYANDORSHUFFLE This copies the current object, with or without shuffling.
        %   Based on the inputs fileset object can decide to either copy
        %   and/or shuffle the fileset. If just shuffling is done, then the output
        %   of this function is empty since a copy is not created.
        newCopy = copyAndOrShuffle(fs, indices);
    end

    methods (Hidden)
        function setFileSizes(fs, fileSizes)
            %SETFILESIZES Set the file sizes for the fileset object.
            fs.FileSizes = fileSizes;
            reset(fs);
        end
        function fileSizes = getFileSizes(fs, indices)
            %GETFILESIZES Get the file sizes from the fileset object.
            %   If a set of indices are given just get those file sizes or just
            %   get all the file sizes.
            if nargin == 2
                fileSizes = fs.FileSizes(indices);
            else
                fileSizes = fs.FileSizes;
            end
        end
        function files = getFiles(fs, ii)
            %GETFILES Get the file paths from the fileset object.
            %   If a set of indices are given just get those files or just
            %   get all the files.
            files = getFilesAsCellStr(fs, ii);
        end

        function setHoldPartitionIndices(fs, tf)
            %SETHOLDPARTITIONINDICES Set logical value to whether hold partition indices or not.
            %   This will set the logical value on the fileset object, indicating whether
            %   partition indices must be held by the fileset or not.
            fs.HoldToPartitionIndices = tf;
        end

        function clearPartitionIndices(fs)
            %CLEARPARTITIONINDICES Clears the partition indices held by the fileset object.
            %   This will clear the partition indices held by the fileset object.
            if ~fs.HoldToPartitionIndices
                return;
            end
            fs.PartitionIndices = [];
        end

        function indices = getPartitionIndices(fs)
            %GETPARTITIONINDICES Gets the partition indices held by the fileset object.
            %   setHoldPartitionIndices(true) must have been called prior to this
            %   to get non-empty values from this function.
            indices = fs.PartitionIndices;
        end
    end

    methods (Access = private)
        function fsize = getActualFileSizeIfStruct(fs, fsize)
            import matlab.io.datastore.internal.fileset.ResolvedFileSet;
            if fs.ActualFileSizeIfStruct ~= ResolvedFileSet.DEFAULT_ACTUAL_FILE_SIZE_IF_NOT_STRUCT
                fsize = fs.ActualFileSizeIfStruct;
            end
        end
    end
end
