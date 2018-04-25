classdef (Hidden) MatSeqDatastore < ...
                  matlab.io.datastore.FileBasedDatastore & ...
                  matlab.io.datastore.mixin.HadoopFileBasedSupport & ...
                  matlab.io.datastore.mixin.CrossPlatformFileRoots & ...
                  matlab.io.datastore.internal.ScalarBase
%MATSEQDATASTORE Datastore for use with MAT-Files or Sequence files.
%   This class inherits from FileBasedDatastore and uses the mixin
%   HadoopFileBasedSupport. This will be the superclass for all MAT-file or
%   Sequence file supporting datastore(s), eg., TallDatastore and,
%   KeyValueDatastore, etc.
%
%   See also tall, matlab.io.datastore.TallDatastore, mapreduce, datastore.

%   Copyright 2016 The MathWorks, Inc.

    properties (Abstract, Dependent)
        %Files -
        % MAT files or SEQUENCE files in the datastore.
        Files;
        %ReadSize -
        % Maximum number of data rows to read.
        ReadSize;
    end

    properties (Abstract, SetAccess = protected)
        %FileType -
        % The type of file supported by the Datastore. FileType
        % must be 'mat' or 'seq'. By default, FileType is determined
        % by the type of file in the location provided.
        FileType;
    end

    properties (Abstract, Access = protected)
        % deployment needs a way to get files before resolving them
        UnresolvedFiles;
    end

    properties (Abstract, Access = protected)
        %ErrorCatalogName - Error catalog name for error handling
        ErrorCatalogName;
        %MFilename - mfilename of the subclasses for error handling
        MFilename;
        %ValuesOnly- Only values are supported from the MAT-files or Sequence files 
        ValuesOnly;
    end

    properties (Constant, Access = protected)
       DEFAULT_FILE_TYPE = 'mat';
       DEFAULT_READ_SIZE = 1;
       DEFAULT_INCLUDE_SUBFOLDERS = false;
       DEFAULT_FILE_EXTENSIONS = -1;
       ALLOWED_FILE_TYPES = {'mat', 'seq'};
       SEQUENCE_FILE_TYPE = 'seq';
       FILETYPE_PROP_NAME = 'FileType';
       READSIZE_PROP_NAME = 'ReadSize';
       INCLUDE_SUBFOLDERS_NV_NAME = 'IncludeSubfolders';
       FILE_EXTENSIONS_NV_NAME = 'FileExtensions';
       FILE_TYPE_MAP = containers.Map({'seq', 'mat'}, {'Sequence ', 'MAT-'});
       MAT_KV_SPLITTER_NAME = 'matlab.io.datastore.splitter.MatKVFileSplitter';
       SEQ_KV_SPLITTER_NAME = 'matlab.io.datastore.splitter.SequenceFileSplitter';
    end

    methods (Access = protected)
        % Setup input files and info for initializing the datastore
        function [files, info] = preambleSetFiles(ds, files)
            import matlab.io.datastore.internal.validators.validatePaths;
            import matlab.io.datastore.internal.indexOfFirstFolderOrWildCard;

            % ensure the given paths are valid strings or cell array of strings
            paths = validatePaths(files);

            % get the appended or modified file list
            appendedPaths = setdiff(paths, ds.Files, 'stable');

            % get the index of the first string which is a folder or
            % contains a wildcard
            idx = indexOfFirstFolderOrWildCard(appendedPaths);

            % error for folder or wild card inputs
            if (-1 ~= idx)
                error(message('MATLAB:datastoreio:filebaseddatastore:nonFilePaths', appendedPaths{idx}));
            end

            import matlab.io.datastore.MatSeqDatastore;
            info.FromConstruction = false;
            info.FileType = ds.FileType;
            info.ReadSize = ds.ReadSize;
            info.ValuesOnly = ds.ValuesOnly;
            info.UsingDefaults = {MatSeqDatastore.FILE_EXTENSIONS_NV_NAME,...
                MatSeqDatastore.INCLUDE_SUBFOLDERS_NV_NAME};
            info.FileExtensions = -1;
            info.IncludeSubfolders = false;
        end
    end

    methods (Access = protected)

        % Initialization of datastore. Used by set.Files method and the constructor
        % This resolves the file paths, checks for supported MAT-files or Sequence
        % files, sets up the splitter for the datastore.
        function initDatastore(ds, files, nvStruct)
            import matlab.io.datastore.splitter.*;
            import matlab.io.datastore.MatSeqDatastore;
            fileType = nvStruct.FileType;
            fileType = validateFileTypeStr(ds, fileType);
            userPassedFileType = true;
            checkMatOrSeq = strcmp(fileType, MatSeqDatastore.ALLOWED_FILE_TYPES);
            if ismember(MatSeqDatastore.FILETYPE_PROP_NAME, nvStruct.UsingDefaults)
                checkMatOrSeq = [true, true];
                userPassedFileType = false;
            end
            % Check the first file
            [~, info, files, fileSizes] = ...
                MatSeqDatastore.supportsLocation(files, nvStruct, checkMatOrSeq, userPassedFileType);
            if userPassedFileType && nvStruct.FromConstruction
                % Filter all unsupported files and if empty error.
                [splitterName, fileInfo] = filterAndGetInfo(ds, fileType, files, fileSizes);
            else
                % Check if all files are supported, otherwise error.
                info.FileType = fileType;
                info.FromConstruction = nvStruct.FromConstruction;
                [splitterName, fileInfo] = checkSupportAndGetInfo(ds, info, files, fileSizes);
            end
            ds.Splitter = feval([splitterName '.create'], fileInfo);
            % reset the datastore so setting the readsize after is a valid call.
            reset(ds);
            if isfield(nvStruct, 'AlternateFileSystemRoots')
                ds.AlternateFileSystemRoots = nvStruct.AlternateFileSystemRoots;
            end
            ds.ReadSize = nvStruct.ReadSize;
            if ds.Splitter.NumSplits == 0
                % Empty datastore defaults to mat type.
                ds.FileType = 'mat';
            else
                % Pick the fileType from the SplitReader.
                ds.FileType = ds.SplitReader.FileType;
            end
        end

        % Throws error that the given file is unsupported
        function unsupportedFilesError(ds, errorThrown, fname)
            if ~isempty(errorThrown)
                throw(errorThrown);
            elseif ~isempty(fname)
                error(message(['MATLAB:datastoreio:' ds.ErrorCatalogName ':unsupportedFiles'], fname));
            else
                error(message(['MATLAB:datastoreio:' ds.ErrorCatalogName ':unsupportedFiles'], ''));
            end
        end

        % When FileType is given as 'mat', when the file is Sequence and vice-versa
        function unexpectedFileTypeError(ds, fileType, fname)
            import matlab.io.datastore.MatSeqDatastore;
            error(message(['MATLAB:datastoreio:' ds.ErrorCatalogName ':unexpectedFileType'], ...
                            MatSeqDatastore.FILE_TYPE_MAP(fileType), fname));
        end

        % When FileType is given and none of the files are of that type.
        function noFileTypeEmptyError(ds, fileType)
            import matlab.io.datastore.MatSeqDatastore;
            fileType = MatSeqDatastore.FILE_TYPE_MAP(fileType);
            error(message(['MATLAB:datastoreio:' ds.ErrorCatalogName ':noFileTypeEmptyError'], ...
                fileType));
        end

        % When a filetype is given filter only that filetype supported files.
        function [splitterName, fileInfo] = filterAndGetInfo(ds, fileType, files, fileSizes)
            import matlab.io.datastore.splitter.MatKVFileSplitter;
            import matlab.io.datastore.splitter.SequenceFileSplitter;
            import matlab.io.datastore.MatSeqDatastore;
            splitterName = '';
            fileInfo = [];
            prevNumFiles = numel(files);
            switch fileType
                case 'mat'
                    splitterName = MatSeqDatastore.MAT_KV_SPLITTER_NAME;
                    fileInfo = MatKVFileSplitter.filterMatFiles(files, ds.ValuesOnly);
                case 'seq'
                    splitterName = MatSeqDatastore.SEQ_KV_SPLITTER_NAME;
                    tfArr = SequenceFileSplitter.filterSeqFiles(files, ds.ValuesOnly);
                    files = files(tfArr);
                    fileSizes = fileSizes(tfArr);
                    fileInfo.Files = files;
                    fileInfo.FileSizes = fileSizes;
            end
            if prevNumFiles ~= 0 && numel(fileInfo.Files) == 0
                noFileTypeEmptyError(ds, fileType);
            end
            fileInfo.ValuesOnly = ds.ValuesOnly;
        end

        % When Filetype is not given check if all files in the resolved-files
        % are supported; throw an error otherwise.
        function [splitterName, fileInfo] = checkSupportAndGetInfo(ds, info, files, fileSizes)
            import matlab.io.datastore.splitter.MatKVFileSplitter;
            import matlab.io.datastore.splitter.SequenceFileSplitter;
            import matlab.io.datastore.MatSeqDatastore;
            splitterName = '';
            fileInfo = [];
            switch info.Support
                case 'MATSupport'
                    splitterName = MatSeqDatastore.MAT_KV_SPLITTER_NAME;
                    % Check if all files are supported MAT-files
                    [fileInfo, areMat, idx] = MatKVFileSplitter.filterMatFiles(files, ds.ValuesOnly);
                    if ~areMat
                        if info.FromConstruction
                            unsupportedFilesError(ds, [], files{idx});
                        else
                            unexpectedFileTypeError(ds, info.FileType, files{idx});
                        end
                    end
                case 'SEQSupport'
                    % Check if all files are sequence files.
                    if numel(files) > 1
                        [areSeq, idx] = SequenceFileSplitter.areSeqFilesSupported(files(2:end), ds.ValuesOnly);
                        if ~areSeq
                            if info.FromConstruction
                                unsupportedFilesError(ds, [], files{idx + 1});
                            else
                                unexpectedFileTypeError(ds, info.FileType, files{idx + 1});
                            end
                        end
                    end
                    fileInfo.Files = files;
                    fileInfo.FileSizes = fileSizes;
                    splitterName = MatSeqDatastore.SEQ_KV_SPLITTER_NAME;
                case 'UnexpectedFileType'
                    unexpectedFileTypeError(ds, info.FileType, info.Filename);
                case 'Unsupported'
                    unsupportedFilesError(ds, info.ErrorThrown, info.Filename);
            end
            fileInfo.ValuesOnly = ds.ValuesOnly;
        end

        %Validate the given filetype option string
        function fileType = validateFileTypeStr(ds, fileType)
            import matlab.io.datastore.MatSeqDatastore;
            fileType = validatestring(fileType, ...
                MatSeqDatastore.ALLOWED_FILE_TYPES, ...
                ds.MFilename, ...
                MatSeqDatastore.FILETYPE_PROP_NAME);
        end

        %Validate the given readsize option
        function validateReadSize(ds, readSize)
            try
                validateattributes(readSize, {'numeric'}, ...
                    {'scalar', 'positive', 'integer'});
            catch
                error(message(['MATLAB:datastoreio:' ds.ErrorCatalogName ':invalidReadSize']))
            end
        end
    end

    methods (Static = true, Hidden = true)

        % This function is responsible for determining whether a given
        % location is supported by a MatSeqDatastore. It also returns a
        % resolved filelist and the corresponding file sizes.
        function [tf, info, files, fileSizes] = supportsLocation(files, nvStruct, checkMatOrSeq, userPassedFileType)
            info.Filename = '';
            info.ErrorThrown = [];
            tf = false;
            if iscell(files) && isempty(files)
                % MATSuppport by default for empty datastore.
                tf = true;
                fileSizes = 0;
                info.Support = 'MATSupport';
                return;
            end
            import matlab.io.datastore.internal.validators.validateFileExtensions;
            import matlab.io.datastore.FileBasedDatastore;

            isDefaultExts = validateFileExtensions(nvStruct.FileExtensions, nvStruct.UsingDefaults);
            % This validates the paths and does a pathlookup of the location input
            [~, files, fileSizes] = matlab.io.datastore.FileBasedDatastore.supportsLocation(files, nvStruct, {}, ~isDefaultExts);
            [~, ~, exts] = cellfun(@fileparts, files, 'UniformOutput', false);
            isCrcFile = strcmp(exts, '.crc');
            files(isCrcFile) = [];
            fileSizes(isCrcFile) = [];
            
            checkForMat = true;
            checkForSeq = true;
            if nargin == 4
                checkForMat = checkMatOrSeq(1);
                checkForSeq = checkMatOrSeq(2);
            end
            info.Support = 'Unsupported';
            try
                info.Filename = files{1};
                import matlab.io.datastore.splitter.MatKVFileSplitter;
                if checkForMat && MatKVFileSplitter.isMatSupported(info.Filename, nvStruct.ValuesOnly)
                    tf = true;
                    info.Support = 'MATSupport';
                    return;
                end
                import matlab.io.datastore.internal.SequenceFileReader;
                if ~tf && checkForSeq && SequenceFileReader.isSeqSupported(info.Filename, nvStruct.ValuesOnly)
                    tf = true;
                    info.Support = 'SEQSupport';
                    return;
                end
            catch e
                info.ErrorThrown = e;
                tf = false;
                return;
            end
            if nargin == 4 && userPassedFileType && ~tf
                % Used by initDatastore method to validate
                info.Support = 'UnexpectedFileType';
            end
        end

    end

    methods (Hidden = true, Access = 'public')
        % return true if the splits of this datastore are file at a time
        function tf = areSplitsWholeFile(ds)
            tf = ds.Splitter.isFullFileSplitter();
        end

        % return true if the splits of this datastore span the all files
        % in the Files property in their entirety (non-partitioned)
        function tf = areSplitsOverCompleteFiles(ds)
            tf = ds.Splitter.isSplitsOverAllOfFiles();
        end

        %PROGRESS   Percentage of completed splits between 0.0 and 1.0.
        %   Return fraction between 0.0 and 1.0 indicating progress. Does
        %   not count unfinished splits
        function frac = progress(ds)
            frac = ds.SplitIdx-hasNext(ds.SplitReader) + progress(ds.SplitReader);
            frac = min(frac/numel(ds.Splitter.Splits), 1.0);
        end

        % HadoopFileBasedSupport: initialize this datastore given filename, offset
        % and size to read
        function initFromFileSplit(ds, filename, offset, len)
            import matlab.io.datastore.splitter.SequenceFileSplitter;
            ds.Splitter = ds.Splitter.createCopyWithSplits(...
                            SequenceFileSplitter.createBasicSplit(filename, offset, len));
            reset(ds);
        end

        % Deployment needs a way to get unresolved files.
        function files = getUnresolvedFiles(ds)
            files = ds.UnresolvedFiles;
        end
    end
end
