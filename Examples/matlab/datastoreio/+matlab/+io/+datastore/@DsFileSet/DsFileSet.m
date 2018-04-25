classdef DsFileSet < matlab.io.datastore.internal.HandleUnwantedHideable &...
                     matlab.mixin.Copyable
%DSFILESET A file set object for a collection of files.
%   FS = DsFileSet(LOCATION) creates a file set object that can be used
%   to collect a very large collection of files. This provides an easier
%   and iterative way of going over the collection of files.
%   LOCATION has the following properties:
%      - Can be a filename or a folder name
%      - Can be a cell array of multiple file or folder names
%      - Can contain a relative path (HDFS requires a full path)
%      - Can contain a wildcard (*) character
%      - Can be a struct containing fields: FileName, Offset, Size
%
%   FS = DsFileSet(__,'FileSplitSize',SPLITSIZE) specifies the size in
%   bytes to be used to split file information. The default value for
%   FileSplitSize is 'file', which means one file information from the
%   nextfile method contains the whole file. SPLITSIZE can also be number
%   of bytes. In this case, nextfile returns the same file multiple times
%   with increasing offsets based on SPLITSIZE.
%   For example, if LOCATION has one file of size 5MB and SPLITSIZE is 1MB,
%   then fileset provides file information for the same file 5 times when
%   calling the nextfile method.
%
%   FS = DsFileSet(__,'IncludeSubfolders',TF) specifies the logical
%   true or false to indicate whether the files in each folder and its
%   subfolders are included recursively or not.
%
%   FS = DsFileSet(__,'FileExtensions',EXTENSIONS) specifies the
%   extensions of files to be included. Values for EXTENSIONS can be:
%      - A character vector, such as '.jpg' or '.png' (empty quotes '' are
%        allowed for files without extensions)
%      - A cell array of character vectors, such as {'.jpg', '.mat'}
%
%   FS = DsFileSet(__,'AlternateFileSystemRoots',ALTROOTS) specifies
%   the alternate file system root paths for the files provided in the
%   LOCATION argument. ALTROOTS contains one or more rows, where each row
%   specifies a set of equivalent root paths. Values for ALTROOTS can be one
%   of these:
%
%      - A string row vector of root paths, such as
%                 ["Z:\datasets", "/mynetwork/datasets"]
%
%      - A cell array of root paths, where each row of the cell array can be
%        specified as string row vector or a cell array of character vectors,
%        such as
%                 {["Z:\datasets", "/mynetwork/datasets"];...
%                  ["Y:\datasets", "/mynetwork2/datasets","S:\datasets"]}
%        or
%                 {{'Z:\datasets','/mynetwork/datasets'};...
%                  {'Y:\datasets', '/mynetwork2/datasets','S:\datasets'}}
%
%   The value of ALTROOTS must also satisfy these conditions:
%      - Each row of ALTROOTS must specify multiple root paths and each root
%        path must contain at least 2 characters.
%      - Root paths specified must be unique and should not be subfolders of
%        each other
%      - ALTROOTS must have at least one root path entry that points to the
%        location of files
%
%   DsFileSet Properties:
%
%      NumFiles                 - Number of files represented by this file set
%      FileSplitSize            - Size in bytes to split file information
%      AlternateFileSystemRoots - Alternate file system root paths for the files
%
%   DsFileSet Methods:
%
%      hasfile       - Returns true if there are more files in the file set
%      nextfile      - Returns the next consecutive file
%      resolve       - Resolves all the files represented by this file set
%      reset         - Reset the file set to the start of the first file
%      partition     - Returns a new fileset that represents a single
%                      partitioned portion of the original file set
%      maxpartitions - Returns the maximum number of partitions possible for
%                      the file set
%
%   Example:
%   --------
%      folder = fullfile(matlabroot,'toolbox','matlab','demos');
%      fs = matlab.io.datastore.DsFileSet(folder,'IncludeSubfolders',true,'FileExtensions','.mat');
%
%      fTable1 = nextfile(fs)            % Obtain the file name and file size of the first file
%      fTable2 = nextfile(fs)            % Obtain the file name and file size of the second file
%      allfiles = resolve(fs)            % Obtain the file name and file size of all the files
%
%      ft = cell(fs.NumFiles,1);
%      i = 1;
%      reset(fs);                        % Reset to the beginning of the fileset
%      while hasfile(fs)                 % Get files using a while-loop
%          ft{i} = nextfile(fs);
%          i = i + 1;
%      end
%      allFiles = vertcat(ft{:});
%
%   See also matlab.io.Datastore,
%            matlab.io.datastore.DsFileReader,
%            matlab.io.datastore.Partitionable,
%            matlab.io.datastore.HadoopFileBased.

%   Copyright 2017 The MathWorks, Inc.

    properties (Dependent, SetAccess = private)
        %NUMFILES Number of files represented by this file set object.
        NumFiles
        %FILESPLITSIZE Size in bytes to be used to represent a split of a file.
        FileSplitSize
    end

    properties (Dependent)
        %ALTERNATEFILESYSTEMROOTS Alternate file system roots for the files.
        %   Alternate file system root paths for the files provided in the
        %   LOCATION argument. ALTROOTS contains one or more rows, where each row
        %   specifies a set of equivalent root paths. Values for ALTROOTS can be one
        %   of these:
        %
        %      - A string row vector of root paths, such as
        %                 ["Z:\datasets", "/mynetwork/datasets"]
        %
        %      - A cell array of root paths, where each row of the cell array can be
        %        specified as string row vector or a cell array of character vectors,
        %        such as
        %                 {["Z:\datasets", "/mynetwork/datasets"];...
        %                  ["Y:\datasets", "/mynetwork2/datasets","S:\datasets"]}
        %        or
        %                 {{'Z:\datasets','/mynetwork/datasets'};...
        %                  {'Y:\datasets', '/mynetwork2/datasets','S:\datasets'}}
        AlternateFileSystemRoots
    end

    properties (Constant, Access = private)
        DEFAULT_INCLUDE_SUBFOLDERS = false;
        DEFAULT_FILE_EXTENSIONS = -1;
        DEFAULT_FULL_FILE_PATHS = 'compressed';
        IN_MEMORY_FULL_FILE_PATHS = 'in-memory';
        DEFAULT_FILE_SPLIT_SIZE = 'file';
        INCLUDE_SUBFOLDERS_NV_NAME = 'IncludeSubfolders';
        FILE_EXTENSIONS_NV_NAME = 'FileExtensions';
        FULL_FILE_PATHS_NV_NAME = 'FullFilePaths';
        FILE_SPLIT_SIZE_NV_NAME = 'FileSplitSize';
        M_FILENAME = mfilename;
    end

    properties (Access = private)
        % An internal fileset object chosen by this DsFileSet object
        InternalFileSet
        % Logical to indicate whether to copy internal fileset or not
        DoNotCopyInternalFileSet = false
    end

    methods
        function fs = DsFileSet(location, varargin)
            try
                nvStruct = iParseNameValues(varargin);

                import matlab.io.datastore.internal.fileset.ResolvedFileSetFactory;
                % Choose an internal fileset object built by the ResolvedFileSetFactory.
                fs.InternalFileSet = ResolvedFileSetFactory.build(location, nvStruct);
            catch ME
                throw(ME);
            end
        end

        function N = maxpartitions(fs)
            %MAXPARTITIONS Return the maximum number of partitions possible for DsFileSet.
            %
            %   N = MAXPARTITIONS(FS) returns the maximum number of partitions for a
            %   given DsFileSet, FS. Returns the number of Files, represented
            %   by the DsFileSet object, when FileSplitSize = 'file'. When FileSplitSize is
            %   numeric, then MAXPARTITIONS is the sum of the ceil of file sizes of each file
            %   divided by the FileSplitSize.
            %
            %   Example:
            %   --------
            %      folder = fullfile(matlabroot,'toolbox','matlab','demos');
            %      files = fullfile(folder, {'patients.mat','accidents.mat'});
            %
            %      fs = matlab.io.datastore.DsFileSet(files);
            %
            %      % When FileSplitSize is file, maxpartitions is equal to NumFiles
            %      isequal(fs.NumFiles, maxpartitions(fs))
            %
            %      % fs contains 2 files but split into partitions of size 2000 bytes
            %      fs = matlab.io.datastore.DsFileSet(files,'FileSplitSize',2000);
            %
            %      % find the maximum number of partitions provided by the fileset for the 2 files
            %      n = maxpartitions(fs);
            %      subfs_1 = partition(fs, n, 1)    % subfs_1 contains the first partition off of n partitions
            %      subfs_2 = partition(fs, n, 2)    % subfs_2 contains the second partition off of n partitions
            %
            %   See also partition, matlab.io.datastore.DsFileSet, matlab.io.datastore.Partitionable.
            try
                N = maxpartitions(fs.InternalFileSet);
            catch ME
                throw(ME);
            end
        end
        function subfs = partition(fs, N, ii)
            %PARTITION Return a partitioned part of the file set object.
            %
            %   SUBFS = PARTITION(FS,NUMPARTITIONS,INDEX) partitions FS into
            %   NUMPARTITIONS parts and returns the partitioned file set,
            %   SUBFS, corresponding to INDEX. An estimate for a reasonable value for the
            %   NUMPARTITIONS input can be obtained by using the NUMFILES property
            %   of the file set.
            %
            %   Example:
            %   --------
            %      folder = fullfile(matlabroot,'toolbox','matlab','demos');
            %
            %      % fs contains 40 files
            %      fs = matlab.io.datastore.DsFileSet(folder,'IncludeSubfolders',true,'FileExtensions','.mat');
            %
            %      % partition the 40 files into 5 partitions and obtain the first portion
            %      subfs_1 = partition(fs, 5, 1)       % subfs contains the first 8 files
            %      allSubfsFiles_1 = resolve(subfs_1)    % Obtain the file name and file size of all the 8 files
            %
            %      % partition the 40 files into 5 partitions and obtain the second portion
            %      subfs_2 = partition(fs, 5, 2)       % subfs contains the second 8 files
            %      allSubfsFiles_2 = resolve(subfs_2)  % Obtain the file name and file size of all the 8 files
            %
            %   See also resolve, matlab.io.Datastore,
            %            matlab.io.datastore.DsFileSet,
            %            matlab.io.datastore.Partitionable.
            try
                subfs = copy(fs);
                subfs.InternalFileSet = partition(fs.InternalFileSet, N, ii);
            catch ME
                throw(ME);
            end
        end

        function files = resolve(fs)
            %RESOLVE Returns all the file information available in the file set object.
            %   ALLFILES = RESOLVE(FS) returns all the files from FS.
            %   ALLFILES is a table with variables, FileName and FileSize.
            %
            %   Example:
            %   --------
            %      folder = fullfile(matlabroot,'toolbox','matlab','demos');
            %      fs = matlab.io.datastore.DsFileSet(folder,'IncludeSubfolders',true,'FileExtensions','.mat');
            %
            %      allfiles = resolve(fs);           % Obtain a table with all the filenames
            %
            %   See also hasfile, nextfile, matlab.io.Datastore,
            %            matlab.io.datastore.DsFileSet,
            %            matlab.io.datastore.Partitionable.
            try
                files = resolve(fs.InternalFileSet);
            catch ME
                throw(ME);
            end
        end

        function file = nextfile(fs)
            %NEXTFILE Returns the next file information available in the file set object.
            %   FT = NEXTFILE(FS) returns the next consecutive file information from FS.
            %   FT is a table with variables, FileName, FileSize, Offset, and SplitSize.
            %   NEXTFILE(FS) errors if there are no more files in the file set object, FS and
            %   should be used with hasfile(FS) and reset(FS).
            %
            %   Example:
            %   --------
            %      folder = fullfile(matlabroot,'toolbox','matlab','demos');
            %      fs = matlab.io.datastore.DsFileSet(folder,'IncludeSubfolders',true,'FileExtensions','.mat');
            %
            %      while hasfile(fs)
            %         file = nextfile(fs);           % Obtain one file at a time
            %      end
            %
            %   See also resolve, hasfile, matlab.io.Datastore,
            %            matlab.io.datastore.DsFileSet,
            %            matlab.io.datastore.Partitionable.
            try
                file = nextfile(fs.InternalFileSet);
            catch ME
                throw(ME);
            end
        end

        function tf = hasfile(fs)
            %HASFILE Returns true if there is more file information not yet obtained from the file set object.
            %   TF = hasfile(FS) returns true if the file set has one or more files
            %   available to obtain with the nextfile method. nextfile(FS) returns an error
            %   when hasfile(FS) returns false.
            %
            %   Example:
            %   --------
            %      folder = fullfile(matlabroot,'toolbox','matlab','demos');
            %      fs = matlab.io.datastore.DsFileSet(folder,'IncludeSubfolders',true,'FileExtensions','.mat');
            %
            %      while hasfile(fs)
            %         file = nextfile(fs);           % Obtain one file at a time
            %      end
            %
            %   See also resolve, nextfile, matlab.io.Datastore,
            %            matlab.io.datastore.DsFileSet,
            %            matlab.io.datastore.Partitionable.
            tf = hasfile(fs.InternalFileSet);
        end

        function reset(fs)
            %RESET Reset the file set to the start of the files information in the file set object.
            %   RESET(FS) resets FS to the beginning of the file set.
            %
            %   Example:
            %   --------
            %      folder = fullfile(matlabroot,'toolbox','matlab','demos');
            %      fs = matlab.io.datastore.DsFileSet(folder,'IncludeSubfolders',true,'FileExtensions','.mat');
            %
            %      ft = cell(fs.NumFiles,1);
            %      i = 1;
            %      while hasfile(fs)                 % Get files using a while-loop
            %          ft{i} = nextfile(fs);
            %          i = i + 1;
            %      end
            %      allFiles = vertcat(ft{:});
            %
            %      reset(fs);                        % Reset to the beginning of the fileset
            %      fTable1 = nextfile(fs)            % Obtain the file name and file size of the first file
            %      fTable2 = nextfile(fs)            % Obtain the file name and file size of the second file
            %      allfiles = resolve(fs)            % Obtain the file name and file size of all the files
            %
            %   See also hasfile, nextfile, matlab.io.Datastore,
            %            matlab.io.datastore.DsFileSet,
            %            matlab.io.datastore.Partitionable.
            try
                reset(fs.InternalFileSet);
            catch ME
                throw(ME);
            end
        end

        % Getter for AlternateFileSystemRoots
        function aRoots = get.AlternateFileSystemRoots(fs)
            aRoots = fs.InternalFileSet.AlternateFileSystemRoots;
        end

        % Setter for AlternateFileSystemRoots
        function set.AlternateFileSystemRoots(fs, aRoots)
            fs.InternalFileSet.AlternateFileSystemRoots = aRoots;
        end

        % Getter for NumFiles
        function nfiles = get.NumFiles(fs)
            nfiles = fs.InternalFileSet.NumFiles;
        end

        % Getter for FileSplitSize
        function nfiles = get.FileSplitSize(fs)
            nfiles = fs.InternalFileSet.FileSplitSize;
        end

    end

    methods (Access = protected)
        function cpObj = copyElement(fs)
            cpObj = copyElement@matlab.mixin.Copyable(fs);
            if ~fs.DoNotCopyInternalFileSet
                cpObj.InternalFileSet = copy(fs.InternalFileSet);
            end
        end
    end

    methods (Access = {?matlab.io.datastore.internal.fileset.ResolvedFileSetFactory})
        function setInternalFileSet(fs, internalFileSet)
            %SETINTERNALFILESET Set the internal fileset object created by ResolvedFileSetFactory.
            fs.InternalFileSet = internalFileSet;
        end
    end

    methods (Hidden)
        function setFilesAndFileSizes(fs, varargin)
            %SETFILESANDFILESIZES Set the files and file sizes for the fileset object.
            %   This is useful when creating an empty file set object and setting the
            %   valid folders and files that are already resolved without any need for
            %   file existence or validity.
            fs.InternalFileSet.setFilesAndFileSizes(varargin{:});
        end
        function setFileSizes(fs, varargin)
            %SETFILESIZES Set the file sizes for the fileset object.
            fs.InternalFileSet.setFileSizes(varargin{:});
        end
        function fileSizes = getFileSizes(fs, indices)
            %GETFILESIZES Get the file sizes from the fileset object.
            %   If a set of indices are given just get those file sizes or just
            %   get all the file sizes.
            if nargin == 2
                fileSizes = fs.InternalFileSet.getFileSizes(indices);
            else
                fileSizes = fs.InternalFileSet.getFileSizes;
            end
        end
        function files = getFiles(fs, ii)
            %GETFILES Get the file paths from the fileset object.
            %   If a set of indices are given just get those files or just
            %   get all the files.
            files = fs.InternalFileSet.getFiles(ii);
        end
        function newCopy = copyAndOrShuffle(fs, varargin)
            %COPYANDORSHUFFLE This copies the current object, with or without shuffling.
            %   Based on the inputs fileset object can decide to either copy
            %   and/or shuffle the fileset. If just shuffling is done, then the output
            %   of this function is empty since a copy is not created.
            internalFileSetCpy = fs.InternalFileSet.copyAndOrShuffle(varargin{:});
            if isempty(internalFileSetCpy)
                newCopy = [];
                return;
            end
            newCopy = copy(fs);
            newCopy.InternalFileSet = internalFileSetCpy;
        end
        function newCopy = copyWithFileIndices(fs, varargin)
            %COPYWITHFILEINDICES This copies the current object using the input indices.
            %   Based on the input indices fileset object creates a copy.
            internalFileSetCpy = fs.InternalFileSet.copyWithFileIndices(varargin{:});
            newCopy = copy(fs);
            newCopy.InternalFileSet = internalFileSetCpy;
        end
        function setShuffledIndices(fs, varargin)
            %SETSHUFFLEDIINDICES Set the shuffled indices for the fileset object.
            %   Any subsequent nextfile calls to the fileset object gets the files
            %   using the shuffled indices.
            fs.InternalFileSet.setShuffledIndices(varargin{:});
        end
        function setDuplicateIndices(fs, varargin)
            %SETDUPLICATEINDICES Set the duplicate indices for the fileset object.
            %   Any subsequent nextfile calls to the fileset object gets the files
            %   using the already existing indices and duplicate indices.
            fs.InternalFileSet.setDuplicateIndices(varargin{:});
        end
        function setHoldPartitionIndices(fs, tf)
            %SETHOLDPARTITIONINDICES Set logical value to whether hold partition indices or not.
            %   This will set the logical value on the fileset object, indicating whether
            %   partition indices must be held by the fileset or not.
            fs.InternalFileSet.setHoldPartitionIndices(tf);
        end
        function clearPartitionIndices(fs)
            %CLEARPARTITIONINDICES Clears the partition indices held by the fileset object.
            %   This will clear the partition indices held by the fileset object.
            fs.InternalFileSet.clearPartitionIndices;
        end
        function indices = getPartitionIndices(fs)
            %GETPARTITIONINDICES Gets the partition indices held by the fileset object.
            %   setHoldPartitionIndices(true) must have been called prior to this
            %   to get non-empty values from this function.
            indices = fs.InternalFileSet.getPartitionIndices;
        end
        function setDoNotCopyInternalFileSet(fs, tf)
            fs.DoNotCopyInternalFileSet = tf;
        end
    end
end

function parsedStruct = iParseNameValues(args)
    % Parse the DsFileSet Name-Value pairs using inputParser
    import matlab.io.datastore.DsFileSet;
    persistent inpP;
    if isempty(inpP)
        inpP = inputParser;
        addParameter(inpP, DsFileSet.INCLUDE_SUBFOLDERS_NV_NAME, DsFileSet.DEFAULT_INCLUDE_SUBFOLDERS);
        addParameter(inpP, DsFileSet.FILE_EXTENSIONS_NV_NAME, DsFileSet.DEFAULT_FILE_EXTENSIONS);
        addParameter(inpP, DsFileSet.FULL_FILE_PATHS_NV_NAME, DsFileSet.DEFAULT_FULL_FILE_PATHS);
        addParameter(inpP, DsFileSet.FILE_SPLIT_SIZE_NV_NAME, DsFileSet.DEFAULT_FILE_SPLIT_SIZE);
        addParameter(inpP, 'AlternateFileSystemRoots', {});
        inpP.FunctionName = DsFileSet.M_FILENAME;
    end
    parse(inpP, args{:});
    parsedStruct = inpP.Results;
    parsedStruct.UsingDefaults = inpP.UsingDefaults;
    parsedStruct.FullFilePaths = validatestring(parsedStruct.FullFilePaths, ...
        {DsFileSet.IN_MEMORY_FULL_FILE_PATHS, DsFileSet.DEFAULT_FULL_FILE_PATHS},...
        DsFileSet.M_FILENAME, DsFileSet.FULL_FILE_PATHS_NV_NAME);
    parsedStruct.FileSplitSize = iValidateSplitSize(parsedStruct.FileSplitSize);
end

function splitSize = iValidateSplitSize(splitSize)
    import matlab.io.datastore.DsFileSet;
    try
        if ischar(splitSize)
            splitSize = validatestring(splitSize, {DsFileSet.DEFAULT_FILE_SPLIT_SIZE},...
                DsFileSet.M_FILENAME, DsFileSet.FILE_SPLIT_SIZE_NV_NAME);
            return;
        end
        classes = {'numeric'};
        attrs = {'scalar', 'positive', 'integer'};
        import matlab.io.datastore.DsFileSet;
        validateattributes(splitSize, classes, attrs,...
            DsFileSet.M_FILENAME, DsFileSet.FILE_SPLIT_SIZE_NV_NAME);
        splitSize = double(splitSize);
    catch ME
        if any(strcmp(ME.identifier, {'MATLAB:DsFileSet:unrecognizedStringChoice', 'MATLAB:DsFileSet:invalidType'}))
            error(message('MATLAB:datastoreio:dsfileset:invalidFileSplitSize'));
        end
        throw(ME);
    end
end
