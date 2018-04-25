classdef (Sealed) ImageDatastore < ...
                  matlab.io.datastore.CustomReadDatastore & ...
                  matlab.io.datastore.internal.ScalarBase & ...
                  matlab.mixin.CustomDisplay
%IMAGEDATASTORE Datastore for a collection of image files.
%   IMDS = imageDatastore(LOCATION) creates an ImageDatastore IMDS given the
%   LOCATION of the image data. LOCATION has the following properties:
%      - Can be a filename or a folder name
%      - Can be a cell array or a string vector of multiple file or folder names
%      - Can contain a relative path (HDFS requires a full path)
%      - Can contain a wildcard (*) character.
%      - All the files in LOCATION must have the same extension and be
%        supported by IMFORMATS
%
%   IMDS = imageDatastore(__,'IncludeSubfolders',TF) specifies the logical
%   true or false to indicate whether the files in each folder and its
%   subfolders are included recursively or not.
%
%   IMDS = imageDatastore(__,'FileExtensions',EXTENSIONS) specifies the
%   extensions of files to be included. The extensions are not required to
%   be supported by IMFORMATS. Values for EXTENSIONS can be:
%      - A character vector or a string scalar, such as '.jpg' or '.png'
%        (empty quotes '' are allowed for files without extensions)
%      - A cell array of character vectors or a string vector, such as {'.jpg', '.png'}
%
%   IMDS = imageDatastore(__,'AlternateFileSystemRoots',ALTROOTS) specifies
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
%   IMDS = imageDatastore(__,'ReadSize',READSIZE) specifies the maximum
%   number of image files to read in a call to the read function. By default,
%   READSIZE is 1. The output of read is a cell array of image data when
%   READSIZE > 1.
%
%   IMDS = imageDatastore(__,'ReadFcn',@MYCUSTOMREADER) specifies the user-
%   defined function to read files. The value of 'ReadFcn' must be a
%   function handle with a signature similar to the following:
%      function data = MYCUSTOMREADER(filename)
%      ..
%      end
%
%   IMDS = imageDatastore(__,'LabelSource',SOURCE) specifies the source from
%   which the Labels property obtains labels. By default, the value of
%   SOURCE is 'none'. If SOURCE is 'foldernames', then the values for the
%   Labels property are obtained from the folder names of the image files.
%
%   IMDS = imageDatastore(__,'Labels',LABELS) specifies the datastore labels
%   according to LABELS. LABELS must be a cell array of character vectors or
%   a vector of numeric, logical, or categorical type.
%
%   ImageDatastore Properties:
%
%      Files                    - Cell array of character vectors of image files.
%                                 You can also set this property using string array.
%      AlternateFileSystemRoots - Alternate file system root paths for the Files.
%      ReadSize                 - Upper limit on the number of images returned by the read method.
%      ReadFcn                  - Function handle used to read files.
%      Labels                   - A set of labels for images.
%
%   ImageDatastore Methods:
%
%      hasdata        - Returns true if there is more data in the datastore
%      read           - Reads the next consecutive file
%      reset          - Resets the datastore to the start of the data
%      preview        - Reads the first image from the datastore
%      readimage      - Reads a specified image from the datastore
%      readall        - Reads all image files from the datastore
%      partition      - Returns a new datastore that represents a single
%                       partitioned portion of the original datastore
%      numpartitions  - Returns an estimate for a reasonable number of
%                       partitions to use with the partition function,
%                       according to the total data size
%      splitEachLabel - Splits the ImageDatastore labels according to the
%                       specified proportions, which can be represented as
%                       percentages or number of files.
%      countEachLabel - Counts the number of unique labels in the ImageDatastore
%      shuffle        - Shuffles the files of ImageDatastore using randperm
%
%   Example:
%   --------
%      folders = fullfile(matlabroot,'toolbox','matlab',{'demos','imagesci'});
%      exts = {'.jpg','.png','.tif'};
%      imds = imageDatastore(folders,'FileExtensions',exts);
%      img1 = read(imds);                  % Read the first image
%      img2 = read(imds);                  % Read the next image
%      readall(imds)                       % Read all of the images
%      numFiles = numpartitions(imds);     % Find number of files
%      imgarr = cell(numFiles,1);
%      for i = 1:numFiles                  % Read images using a for loop
%          imgarr{i} = readimage(imds,i);
%      end
%
%   See also datastore, mapreduce, imformats, imageDatastore.

%   Copyright 2015-2017 The MathWorks, Inc.

    properties (Dependent)
        %Files -
        % A cell array of character vectors of image files. You can also
        % set this property using a string array.
        Files;

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
        AlternateFileSystemRoots;
    end

    properties (Hidden)
        %CachedRead -
        % 'on' | 'off' - Toggle to use cached read.
        CachedRead = 'on';
        %MaxThreads -
        % numeric - Max number of threads for cached read.
        MaxThreads = 'default';
    end

    properties (Dependent, Hidden)
        % PrefetchSize indicates how much data to read in advance
        PrefetchSize = 0;
    end

    properties
        %ReadSize -
        % Number of image files for one read.
        ReadSize;
        %Labels -
        % A set of labels for images with a one-to-one mapping with Files.
        Labels = {};
    end

    properties (Access = private)
        % deployement needs a way to get files before resolving them
        UnResolvedFiles;
        % On subsasgn'ing Files with [], we need a way to subsasgn Labels
        % to [].
        EmptyIndexes;
        % On subsasgn'ing Files with more files, we need a way to subsasgn
        % Labels to default values.
        AddedIndexes;
        % On assigning Files property with new files, we need to assign
        % default values for Labels property.
        FilesAssigned = false;
        % Whenever we set files, determine number of files instead of
        % calling numel all the time (reset method). We also need to check
        % for changed indexes of Files, to subsasgn Labels.
        % Refer method resolveLabelsIndexes.
        NumFiles;
        % To help support future forward compatibility.  The value
        % indicates the version of MATLAB.
        SchemaVersion;
        % To know if ReadFcn is changed
        IsReadFcnDefault;
        % To know if MaxThreads is changed
        IsMaxThreadsDefault = true;
        % To know if cached read is already used
        IsUsingCachedRead = true;
        % File extensions
        FileExts;
        %CACHEALLFILES Logical indicating whether to cache all files or not.
        CacheAllFiles = false;
        % To know if prefetch size is set during construction
        PrefetchSizeSetOnConstruction = false;
        % Private variable that PrefetchSize depends on
        PrivatePrefetchSize = 0;
    end

    properties (Access = private, Transient, NonCopyable)
        % Batch reader
        BatchReader;
        % Data buffer holding on to cached images
        DataBuffer;
        % Error buffer pointing to cached images
        ErrorBuffer;
        % File buffer that holds on to files corresponding
        % to DataBuffer and that are in the process of prefetching
        FileBuffer;
        % The index corresponding to FileSet in the File buffer's first value
        FileBufferFirstIndex = 1;
        % Start Index of FileBuffer corresponding to files being
        % currently prefetched
        StartIndexPrefetchFiles = 1;
        % Set only during display to indicate we don't need
        % get.Files method to get the actual files but be a no-op.
        NoOpDuringGetDotFiles = false;
        %ALLFILESCACHED All files cached when CacheAllFiles is true.
        AllFilesCached = [];
    end

    properties (Constant, Access = private)
        WHOLE_FILE_CUSTOM_READ_SPLITTER_NAME = 'matlab.io.datastore.splitter.WholeFileCustomReadFileSetSplitter';
        WHOLE_FILE_CUSTOM_READ_SPLITTER_NAME_15b_17b = 'matlab.io.datastore.splitter.WholeFileCustomReadSplitter';
        CONVENIENCE_CONSTRUCTOR_FCN_NAME = 'imageDatastore';
        PRE_FETCH_SIZE_FOR_READSIZE_ONE = 2;
        MAX_FILE_SIZE_FOR_DISPLAY = 3;
    end
    % Constructor
    methods
        % ImageDataStore can be constructed with files argument, optionally
        % with ReadFcn, IncludeSubfolders, FileExtensions Name-Value pairs.
        function imds = ImageDatastore(files, varargin)
            try
                import matlab.io.datastore.ImageDatastore;

                % string adoption - convert all NV pairs specified as
                % string to char
                files = convertStringsToChars(files);
                [varargin{:}] = convertStringsToChars(varargin{:});
                nv = iParseNameValues(varargin{:});

                initDatastore(imds, files, nv);
                imds.UnResolvedFiles = files;
                % SchemaVersion indicates the release number of MATLAB. This will be empty in
                % 14b or the appropriate release, if we set it in the constructor.
                imds.SchemaVersion = version('-release');
            catch e
                throwAsCaller(e);
            end
        end
    end

    % Set and Get methods for properties
    methods
        % Set method for Files
        function set.Files(imds, files)
            try
                c = onCleanup(@() initializeSubsAsgnIndexes(imds));
                [diffIndexes, currIndexes, files, fileSizes, diffPaths] = setNewFilesAndFileSizes(imds, files);
                if isempty(diffPaths)
                    if isempty(imds.AddedIndexes)
                        if numel(currIndexes) == imds.NumFiles
                            % Copy and shuffle
                            %   empty out some files and add duplicates
                            %   eg. ds.Files(end-9:end) = ds.Files(1:10);
                            % Shuffle only
                            %   eg. ds.Files = ds.Files(randperm(numel(ds.Files)));
                            %   eg. ds.Files = ds.Files;
                            imds.setFileIndices(currIndexes, imds.Splitter.Files, 'copyAndOrShuffle');
                        elseif numel(currIndexes) < imds.NumFiles
                            % emptied out some files not using empty on rhs
                            % eg. ds.Files = ds.Files(1);
                            imds.setFileIndices(currIndexes, imds.Splitter.Files);
                        else
                            % eg. ds.Files = repelem(ds.Files,5,1);
                            imds.AddedIndexes = 1:numel(currIndexes) > imds.NumFiles;
                            imds.Splitter.Files.setDuplicateIndices(currIndexes, imds.AddedIndexes);
                        end
                    elseif ~isempty(imds.EmptyIndexes)
                        % emptied out some files
                        % eg. ds.Files(1:10) = [];% when imds has more than 10 files
                        imds.setFileIndices(currIndexes, imds.Splitter.Files);
                    else
                        % duplicate paths
                        % eg. ds.Files(end+1:end+10) = ds.Files(1:10);
                        imds.Splitter.Files.setDuplicateIndices(currIndexes, imds.AddedIndexes);
                    end
                else
                    % The case where new files are added. Currently, this is not a very
                    % common use case when you have millions of files. So fall back to
                    % in memory file set.
                    files(diffIndexes) = diffPaths;
                    import matlab.io.datastore.internal.fileset.ResolvedFileSetFactory;
                    f = ResolvedFileSetFactory.buildInMemory(files, fileSizes);
                    imds.Splitter.setFiles(f);
                end
                reset(imds);
                resolveLabelsIndexes(imds);
                setFileExtensions(imds, diffIndexes, currIndexes);
            catch e
                throw(e)
            end
        end

        % Getter for AlternateFileSystemRoots
        function aRoots = get.AlternateFileSystemRoots(ds)
            aRoots = ds.Splitter.Files.AlternateFileSystemRoots;
        end

        % Setter for AlternateFileSystemRoots
        function set.AlternateFileSystemRoots(ds, aRoots)
            try
                ds.Splitter.Files.AlternateFileSystemRoots = aRoots;
                reset(ds);
            catch ME
                throw(ME);
            end
        end

        % Set method for ReadSize
        function set.ReadSize(imds, readSize)
            try
                iValidateReadSize(readSize);
                if imds.PrefetchSizeSetOnConstruction
                    imds.PrivatePrefetchSize = 0;
                end
                imds.ReadSize = readSize;
            catch e
                throw(e);
            end
        end
        % Set method for Labels
        function set.Labels(imds, labels)
            try
                labels = convertStringsToChars(labels);
                if isequal(class(labels),'char')
                    labels = cellstr(labels);
                end
                labels = validateLabels(imds, labels);
                imds.Labels = labels;
            catch e
                throw(e);
            end
        end
        % Set CachedRead
        function set.CachedRead(imds, cachedRead)
            try
                cachedRead = validatestring(cachedRead, {'on', 'off'});
                imds.CachedRead = cachedRead;
            catch e
                throw(e);
            end
        end
        % Set MaxThreads
        function set.MaxThreads(imds, maxThreads)
            try
                maxThreads = iValidateMaxThreads(maxThreads);
                imds.MaxThreads = maxThreads;
                imds.IsMaxThreadsDefault = isequal(maxThreads, 'default');
            catch e
                rethrow(e);
            end
        end
        % Get Files
        function files = get.Files(imds)
            if imds.NoOpDuringGetDotFiles
                % This is for displayScalarObject's getPropertyGroup
                % not incur getting all the files. We just need 3 files.
                files = {};
                return;
            end
            if isempty(imds.AllFilesCached)
                % In case the files are not cached get it from splitter.
                files = imds.Splitter.getFilesAsCellStr();
            else
                files = imds.AllFilesCached;
            end
            if imds.CacheAllFiles
                % If asked to cache all files, store them.
                imds.AllFilesCached = files;
            end
        end
        % Get Labels
        function labels = get.Labels(imds)
            labels = imds.Labels;
        end

        function set.PrefetchSize(imds, prefetchSize)
            if imds.PrefetchSizeSetOnConstruction
                imds.PrefetchSizeSetOnConstruction = false;
            end
            imds.PrivatePrefetchSize = prefetchSize;
            reset(imds);
        end

        function prefetchSize = get.PrefetchSize(imds)
            prefetchSize = imds.PrivatePrefetchSize;
        end
    end

    methods (Hidden)
        function imds = subsasgn(imds, S, B)
            % Store the indexes of added and emptied files.
            %   - AddedIndexes are used to add default labels.
            %   - EmptiedIndexes are used to empty out labels.
            try
                switch numel(S)
                    case 2
                        if isequal(S(1).type, '.')
                            switch S(1).subs
                                case 'Files'
                                    if isempty(B)
                                        imds.EmptyIndexes = S(2).subs{1};
                                    else
                                        idxes = S(2).subs{1};
                                        imds.AddedIndexes = idxes(idxes > imds.NumFiles);
                                    end
                                    % Cache files when assignment happens
                                    imds.CacheAllFiles = true;
                            end
                        end
                    case 1
                        if isequal(S.type, '.')
                            switch S.subs
                                case 'Files'
                                    imds.FilesAssigned = true;
                                    % Cache files when subsref and subsasgn happen
                                    imds.CacheAllFiles = true;
                            end
                        end
                end

                % At the end of subsasgn clear the cache.
                c = onCleanup(@() initializeCachedFiles(imds));
                imds = builtin('subsasgn', imds, S, B);
            catch e
                throw(e)
            end
        end

        function initFromFileSplit(ds, filename, offset, len)
            files = ds.Files;
            l = ds.Labels;
            initFromFileSplit@matlab.io.datastore.CustomReadDatastore(ds, filename, offset, len);
            if ~isempty(l)
                newFiles = ds.Files;
                [~, index] = ismember(newFiles, files);
                if any(index == 0)
                    error(message('MATLAB:datastoreio:imagedatastore:invalidFilenameFromSplit', filename));
                else
                    ds.Labels = l(index);
                    setExistingCategories(ds);
                end
            end
            % set datastore not to use prefetch reading
            ds.IsReadFcnDefault = false;
        end

        function avgFs = getAverageFileSize(imds)
            avgFs = mean(imds.Splitter.getFileSizes);
        end
    end

    methods (Access = private)

        % Set IsReadFcnDefault if ReadFcn is the default readDatastoreImage private method
        function setIsReadFcnDefault(imds, readFcn)
            fcnInfo = functions(readFcn);
            pvtFile = fullfile(fileparts(mfilename('fullpath')), 'private', 'readDatastoreImage.m');
            tf = isfield(fcnInfo, 'file') && isequal(fcnInfo.file, pvtFile);
            imds.IsReadFcnDefault = tf && isfield(fcnInfo, 'parentage') && isequal(fcnInfo.parentage, {'readDatastoreImage'});
        end

        % Set File Extensions of any new files or remove file extensions
        % of files that are removed with subsasgn
        function setFileExtensions(imds, diffIndexes, currIndexes)
            if nargin == 1
                idxes = 1:imds.NumFiles;
            else
                idxes = find(diffIndexes);
            end
            if numel(idxes) > 0
                fileExts = cell(imds.NumFiles, 1);
                if nargin > 1
                    fileExts(~diffIndexes) = cellstr(imds.FileExts(currIndexes));
                end
                filenames = imds.Splitter.getFilesAsCellStr(idxes);
                for ii = 1:numel(idxes)
                    % Find extensions only for the new files.
                    [~,~,ext] = fileparts(filenames{ii});
                    fileExts{idxes(ii)} = lower(ext);
                end
                imds.FileExts = categorical(fileExts);
            else
                imds.FileExts = imds.FileExts(currIndexes);
            end
        end

        function [data, info] = preFetchRead(imds)
            if ~hasdata(imds)
                error(message('MATLAB:datastoreio:splittabledatastore:noMoreData'));
            end
            readSize = getTrueReadSize(imds);
            [filesToRead, idxes] = nextFilesToRead(imds, readSize);
            [data, imds.BatchReader] = readUsingPreFetcher(imds, filesToRead, idxes, imds.BatchReader, readSize);
            info = getInfoForBatch(imds, filesToRead, idxes);

            % Set the SplitIdx appropriately
            newSplitIdx = imds.SplitIdx + readSize;
            if newSplitIdx > imds.NumFiles
                imds.SplitIdx = imds.NumFiles;
                % For hasdata to return false
                imds.SplitReader.ReadingDone = true;
                return;
            end
            imds.SplitIdx = newSplitIdx;

            % start next set of files to read when the ImageDatastore
            % buffer is empty and prefetching is disabled
            if isempty(imds.DataBuffer) && imds.PrefetchSize <= imds.ReadSize
                [filesToRead, idxes] = nextFilesToRead(imds);
                callStartBatchReading(imds, imds.BatchReader, filesToRead, idxes);
            end
        end

        function [data, info] = readUsingSplitReader(imds, splitIndex)
            splitReader = createReader(imds.Splitter, splitIndex);
            reset(splitReader);
            [data, info] = getNext(splitReader);
            info.Label = getLabelUsingIndex(imds, splitIndex);
        end

        function callStartBatchReading(imds, reader, filesToRead, idxes)
            % Call start batch reading after making sure already running
            % prefetch data is gathered.
            if isempty(filesToRead)
                return;
            end
            if isempty(imds.FileBuffer)
                imds.FileBuffer = filesToRead;
                imds.StartIndexPrefetchFiles = 1;
                imds.FileBufferFirstIndex = idxes(1);
            else
                % make sure to gather if prefetching is happening
                % already.
                appendIfPrefetching(imds, reader);
                imds.FileBuffer = [imds.FileBuffer; filesToRead];
            end
            formats = imds.FileExts(idxes);
            startBatchReading(imds, reader, filesToRead, formats);
        end

        function readFromBatchReader(imds, reader)
            % Read from the batch reader and make sure the Start index is after
            % the current buffer.
            [d,e] = read(reader);
            if numel(d) > 0
                imds.DataBuffer = vertcat(imds.DataBuffer, d);
                imds.ErrorBuffer = vertcat(imds.ErrorBuffer, e);
                imds.StartIndexPrefetchFiles = numel(imds.FileBuffer) + 1;
            end
        end

        function appendIfPrefetching(imds, reader)
            % Read from the batch reader only when there is some prefetching
            % happening already.
            if imds.StartIndexPrefetchFiles < numel(imds.FileBuffer)
                readFromBatchReader(imds, reader);
            end
        end

        function bufferEnoughData(imds, filesToRead, idxes, reader, readSize)
            % Buffer enough data to read given a readsize
            % This appends to the buffer if already some prefetching is going on
            % after which if still not enough data is in the buffer prefetch them
            % and read consecutively.
            bufferSize = numel(imds.DataBuffer);
            if bufferSize < readSize
                appendIfPrefetching(imds, reader);
                bufferSize = numel(imds.DataBuffer);
                % If still not enough after gathering the prefetched
                % data, then do one more time to read.
                if bufferSize < readSize
                    remIdxes = bufferSize+1:readSize;
                    callStartBatchReading(imds, reader, filesToRead(remIdxes), idxes(remIdxes));
                    readFromBatchReader(imds, reader);
                end
            end
        end

        function [data, reader] = readUsingPreFetcher(imds, filesToRead, idxes, reader, readSize)
            % When this is invoked from datastore/readall, idxes is a
            % logical vector. When invoked by datastore/read, this is
            % a double vector of the form start:end
            isReadAll = islogical(idxes);
            if isempty(reader)
                reader = matlab.io.datastore.internal.BatchImreader;
                if imds.PrefetchSize > imds.ReadSize && ~isReadAll
                    % Remote location and first prefetching. We need to
                    % bootstrap the prefetching process. The files
                    % downloaded from callStartBatchReading will be also read
                    % subsequently by the read function.
                    [filesToPrefetch, prefetchIdxes] = nextFilesToRead(imds, imds.PrefetchSize);
                    callStartBatchReading(imds, reader, filesToPrefetch, prefetchIdxes);
                else
                    callStartBatchReading(imds, reader, filesToRead, idxes);
                end
            end

            if isempty(imds.DataBuffer)
                % Read into the imds buffer
                readFromBatchReader(imds, reader);
                if imds.PrefetchSize > imds.ReadSize && ~isReadAll
                    % If we are prefetching, start a new prefetching
                    % phase. The next imds.read will be getting data from
                    % imds.DataBuffer, while callStartBatchReading is
                    % downloading the next images from the remote location
                    [filesToPrefetch, prefetchIdxes] = nextFilesToRead(imds, imds.PrefetchSize);
                    callStartBatchReading(imds, reader, filesToPrefetch, prefetchIdxes);
                end
            end

            bufferEnoughData(imds, filesToRead, idxes, reader, readSize);

            data = imds.DataBuffer(1:readSize);
            errors = imds.ErrorBuffer(1:readSize);
            imds.DataBuffer(1:readSize) = [];
            imds.ErrorBuffer(1:readSize) = [];
            imds.FileBuffer(1:readSize) = [];
            imds.FileBufferFirstIndex = imds.FileBufferFirstIndex + readSize;
            imds.StartIndexPrefetchFiles = imds.StartIndexPrefetchFiles - readSize;
            if imds.StartIndexPrefetchFiles < 1
                imds.StartIndexPrefetchFiles = 1;
            end

            errIdxes = find(errors);
            if ~isempty(errIdxes)
                for ii = 1:numel(errIdxes)
                    errIdx = errIdxes(ii);
                    try
                        % If reading all the files, ignore the split index,
                        % otherwise use it
                        if isReadAll
                            splitIdx = 0;
                        else
                            splitIdx = imds.SplitIdx - 1;
                        end
                        % readUsingSplitReader reads from remote locations
                        % as well. SplitIdx points to the current file to
                        % be read errIdxes are 1:n, n - number of files to
                        % be read
                        data{errIdx} = readUsingSplitReader(imds, splitIdx + errIdx);
                    catch ME
                        % Once errored, reset batch reading states, so we try reading next time.
                        resetBatchReading(imds);
                        msg = message('MATLAB:datastoreio:imagedatastore:unableToReadFile', filesToRead{errIdx});
                        mexc = MException(msg);
                        mexc = addCause(mexc, ME);
                        throw(mexc);
                    end
                end
            end
        end

        function startBatchReading(imds, reader, filesToRead, formats)
            if ~imds.IsMaxThreadsDefault
                reader.MaxThreads = imds.MaxThreads;
            end
            % FileExts is a categorical now.
            startRead(reader, filesToRead, cellstr(formats));
        end

        function info = getInfoForBatch(imds, filesToRead, idxes)
            if nargin < 3
                [filesToRead, idxes] = nextFilesToRead(imds);
            end
            if imds.ReadSize == 1 && iscell(filesToRead)
                filesToRead = filesToRead{1};
            end
            info.Filename = filesToRead;
            fileSizes = imds.Splitter.getFileSizes(idxes);
            info.FileSize = fileSizes(:);
            info.Label = getLabelUsingIndex(imds, idxes);
        end

        function readSize = getTrueReadSize(imds)
            readSize = imds.ReadSize;
            remSize = imds.NumFiles - imds.SplitIdx + 1;
            if readSize > remSize
                readSize = remSize;
            end
        end

        function idxes = nextIndexes(imds, readSize)
            % Return the next set of indices corresponding to the next batch of data

            if readSize > imds.ReadSize && ~isempty(imds.DataBuffer)
                % If prefetching, read file in advance, i.e., start =
                % current index + readSize
                sIdx = imds.SplitIdx + readSize;
            else
                % Otherwise return the current index
                sIdx = imds.SplitIdx;
            end
            eIdx = min(sIdx + readSize - 1, imds.NumFiles);
            idxes = sIdx:eIdx;
        end

        function [files, idxes] = nextFilesToRead(imds, readSize)
            % Return the next set of file and indices for the next batch of
            % data to read
            if nargin == 1
                readSize = getTrueReadSize(imds);
            end
            idxes = nextIndexes(imds, readSize);
            % Right now we ask splitter for filenames, but once we integrate DsFileSet,
            % FileBuffer will help optimize the number of times we ask DsFileSet.
            if isempty(imds.FileBuffer) ||...
                    (~isempty(idxes) && idxes(1) > imds.FileBufferFirstIndex)
                files = imds.Splitter.getFilesAsCellStr(idxes);
            else
                % Get the available number of files from the buffer
                numReq = numel(idxes);
                numPre = numel(imds.FileBuffer);
                if numReq > numPre
                    % If not enough ask the splitter.
                    files = cell(numReq,1);
                    files(1:numPre) = imds.FileBuffer;
                    askSplitter = numPre+1:numReq;
                    askSplitter = idxes(askSplitter);
                    files(numPre+1:numReq) = imds.Splitter.getFilesAsCellStr(askSplitter);
                else
                    files = imds.FileBuffer(1:numReq);
                end
            end
        end

        function initDatastore(imds, files, nv)
            import matlab.io.datastore.ImageDatastore;
            import matlab.io.datastore.internal.validators.validateCustomReadFcn;
            import matlab.io.datastore.internal.isIRI;
            import matlab.io.datastore.internal.fileset.ResolvedFileSetFactory;

            validateCustomReadFcn(nv.ReadFcn, true, ImageDatastore.CONVENIENCE_CONSTRUCTOR_FCN_NAME);
            imds.IsReadFcnDefault = ismember('ReadFcn', nv.UsingDefaults);

            nv.DefaultFilterExtensions = ImageDatastore.getDefaultExtensions;

            nv.NeedFolderNames = ismember('Labels', nv.UsingDefaults) && strcmpi(nv.LabelSource, 'foldernames');
            origFiles = files;

            [files, fileExts, folderNames] = ResolvedFileSetFactory.buildCompressed(files, nv);
            imds.FileExts = categorical(lower(fileExts));
            imds.SplitterName = ImageDatastore.WHOLE_FILE_CUSTOM_READ_SPLITTER_NAME;

            if ~isempty(origFiles) && any(isIRI(origFiles) & ~isSupportedIRI(origFiles))
                imds.IsReadFcnDefault = false;
            end

            imds.NumFiles = files.NumFiles;
            if ~ismember('ReadSize', nv.UsingDefaults)
                iValidateReadSize(nv.ReadSize);
            end

            imds.ReadSize = nv.ReadSize;
            if nv.NeedFolderNames && imds.NumFiles ~= 0
                % When 'LabelSource' is 'foldernames', Labels is a categorical.
                nv.Labels = categorical(folderNames);
            end

            % initFromReadFcn sets the datastore's ReadFcn and passes rest
            % of the varargin inputs to the splitter.
            %  - initFromReadFcn(ds, readFcn, varargin)
            %
            %  - files - Pass files to the initialization of the splitter,
            %    so we don't lookup the path and verify the existence of files
            %    again
            initFromReadFcn(imds, nv.ReadFcn, files);

            % Set Labels after reset. Reset happens in initFromReadFcn.
            imds.Labels = nv.Labels;
            if imds.ReadSize == 1
                imds.PrivatePrefetchSize = min(ImageDatastore.PRE_FETCH_SIZE_FOR_READSIZE_ONE, imds.NumFiles);
                imds.PrefetchSizeSetOnConstruction = true;
            else
                imds.PrivatePrefetchSize = 0;
                imds.PrefetchSizeSetOnConstruction = false;
            end
        end

        function resolveLabelsIndexes(imds)
            % If the filenames are modified, Labels are not changed
            % If any additional files are added, we add default values
            % for the respective Labels.
            %
            %    Labels Type   Default
            %    -----------   -------
            %    cellstr        ''
            %    numerical      0
            %    logical        false
            %    categorical    <undefined>
            %
            if isempty(imds.Labels)
                return;
            end
            if imds.NumFiles == 0 || imds.FilesAssigned
                imds.Labels = {};
                return;
            end
            if ~isempty(imds.EmptyIndexes)
                imds.Labels(imds.EmptyIndexes) = [];
                setExistingCategories(imds);
            end
            if ~isempty(imds.AddedIndexes)
                nv = numel(imds.AddedIndexes);
                addLabels = iGetDefaultLabels(imds.Labels, nv);
                imds.Labels(imds.AddedIndexes) = addLabels;
            end
        end

        function label = getLabelUsingIndex(imds, idx)
            if isempty(imds.Labels)
                label = {};
                return;
            end

            if iscell(imds.Labels)
                label = imds.Labels{idx};
            else
                label = imds.Labels(idx);
            end
        end

        function labels = validateLabels(imds, labels)
            if iscell(labels)
                if isempty(labels)
                    return;
                end
                if ~iscellstr(labels)
                    error(message('MATLAB:datastoreio:imagedatastore:labelsNotCellstr'));
                end
            end
            classes = {'numeric', 'cell', 'categorical', 'logical'};
            attrs = {'numel', imds.NumFiles};
            import matlab.io.datastore.ImageDatastore;
            validateattributes(labels, classes, attrs, ...
                ImageDatastore.CONVENIENCE_CONSTRUCTOR_FCN_NAME, 'Labels');
            labels = labels(:);
        end

        function setExistingCategories(imds)
            % Create categorical with only the existing categories, so that
            % the resulting labels will not have categories of the
            % Labels.
            l = imds.Labels;
            if isa(l, 'categorical')
                imds.Labels = removecats(l);
            end
        end

        function initializeSubsAsgnIndexes(imds)
            % subsasgn for Files is called before set.Files.
            % reset EmptyIndexes and AddedIndexes if there's an error,
            % so we don't change the labels.
            imds.EmptyIndexes = [];
            imds.AddedIndexes = [];
            imds.FilesAssigned = false;
        end

        function initializeCachedFiles(imds)
            % Reset AllFilesCached and CacheAllFiles at the end of
            % subsasgn or if there's an error.
            imds.AllFilesCached = [];
            imds.CacheAllFiles = false;
        end

        function [u, c, g, n] = groupAndCountLabels(imds)
            l = imds.Labels;
            [g, u] = findgroups(l);
            c = splitapply(@numel, l, g);
            n = [];
            switch class(l)
                case 'categorical'
                    % count the number of undefined labels
                    [c, u, n] = iAddUngroupedCounts(isundefined(l), categorical(nan), c, u, n);
                case 'cell'
                    % count the number of empty strings
                    % empty string indexes are NaNs in grouping indexes
                    [c, u, n] = iAddUngroupedCounts(isnan(g), {''}, c, u, n);
                case 'logical'
                    % nothing to do for logical; all logicals are always grouped
                otherwise
                    % It has to be numerical at this point, since
                    % labels can only be numerical, logical, cellstr or categorical.
                    [c, u, n] = iAddUngroupedCounts(isnan(l), nan, c, u, n);
            end
        end

        function [cpy, files] = getCopyWithOriginalFiles(imds)
            %GETCOPYWITHORIGINALFILES A helper to get a datastore copy and the
            % original fileset object.
            cpy = copy(imds);
            files = imds.Splitter.Files;
        end

        function setFileIndices(imds, indexes, files, ~)
            %SETFILEINDICES Based on nargin set or copy or shuffle the fileset object
            % All of these cases and their examples are part of the comments in
            % set.Files
            switch nargin
                case 2
                    setShuffledIndices(imds.Splitter.Files, indexes);
                case 3
                    files = copyWithFileIndices(files, indexes);
                    imds.Splitter.setFiles(files);
                case 4
                    files = copyAndOrShuffle(files, indexes);
                    if ~isempty(files)
                        imds.Splitter.setFiles(files);
                    end
            end
        end

        function initWithIndices(imds, indexes, varargin)
            %INITWITHINDICES Initialize datastore with specific file indexes.
            %   This can be used to initialize the datastore with ReadFcn and files/fileSizes
            %   found previously or already existing in the splitter information.
            if ~isempty(imds.FileExts)
                imds.FileExts = imds.FileExts(indexes);
            end

            setFileIndices(imds, indexes, varargin{:});
            reset(imds);

            % Set labels after files are set, since the labels setter
            % checks for number of files to be equal.
            if ~isempty(imds.Labels)
                numLabels = numel(imds.Labels);
                imds.Labels = imds.Labels(indexes);
                if numLabels ~= numel(indexes)
                    setExistingCategories(imds);
                end
            end
        end

        function resetBatchReading(imds)
            imds.BatchReader = [];
            imds.DataBuffer = [];
            imds.ErrorBuffer = [];
            imds.FileBuffer = [];
            imds.FileBufferFirstIndex = 1;
            imds.StartIndexPrefetchFiles = 1;
        end
    end

    methods (Access = protected)

        function validateReadFcn(imds, readFcn)

            % validateReadFcn is called from set.ReadFcn
            import matlab.io.datastore.ImageDatastore;
            import matlab.io.datastore.internal.validators.validateCustomReadFcn;
            validateCustomReadFcn(readFcn, false, ImageDatastore.CONVENIENCE_CONSTRUCTOR_FCN_NAME);

            % Set the private IsReadFcnDefault value
            setIsReadFcnDefault(imds, readFcn);
        end

        function displayScalarObject(imds)
            % header
            disp(getHeader(imds));
            % Set NoOpDuringGetDotFiles to true, since imds.Files getter
            % need not get all the files for displaying the object.
            imds.NoOpDuringGetDotFiles = true;
            group = getPropertyGroups(imds);
            imds.NoOpDuringGetDotFiles = false;
            filesEmpty = imds.NumFiles == 0;
            labels = imds.Labels;
            labelsEmpty = isempty(labels);
            if ~filesEmpty || ~labelsEmpty
                % Get the details from an empty datastore so we don't pay
                % the penalty to look for millions of files
                emptyDs = matlab.io.datastore.ImageDatastore({}); %#ok<NASGU>
                detailsStr = evalc('details(emptyDs)');
                nsplits = strsplit(detailsStr, '\n');
            end
            import matlab.io.internal.cellArrayDisp;
            import matlab.io.datastore.internal.vectorDisp;
            import matlab.io.datastore.ImageDatastore;
            if ~filesEmpty
                filesStr = nsplits(contains(nsplits, 'Files: '));
                % Find the indent spaces from details
                nFilesIndent = strfind(filesStr{1}, 'Files: ') - 1;
                if nFilesIndent > 0
                    % File Properties
                    filesIndent = [sprintf(repmat(' ',1,nFilesIndent)) 'Files: '];
                    nlspacing = sprintf(repmat(' ',1,numel(filesIndent)));
                    if imds.NumFiles >= ImageDatastore.MAX_FILE_SIZE_FOR_DISPLAY
                        % Get only 3 files maximum. If there are millions of files
                        % this improves performance by many orders.
                        threeIndices = 1:ImageDatastore.MAX_FILE_SIZE_FOR_DISPLAY;
                        files = imds.Splitter.getFilesAsCellStr(threeIndices);
                    else
                        files = imds.Files;
                    end
                    filesStrDisp = cellArrayDisp(files, true, nlspacing, imds.NumFiles);
                    disp([filesIndent filesStrDisp]);
                    % Remove Files property from the group, since custom
                    % display is used for Files.
                    group.PropertyList = rmfield(group.PropertyList, 'Files');
                end
            end
            if ~labelsEmpty && imds.NumFiles > 1
                labelsStr = nsplits(contains(nsplits, 'Labels: '));
                nLabelsIndent = strfind(labelsStr{1}, 'Labels: ') - 1;
                if nLabelsIndent > 0
                    labelsIndent = [sprintf(repmat(' ',1,nLabelsIndent)) 'Labels: '];
                end
                if iscell(labels)
                    labelsStrDisp = cellArrayDisp(labels, false, '');
                else
                    labelsStrDisp = vectorDisp(labels);
                end
                disp([labelsIndent, labelsStrDisp]);
                group.PropertyList = rmfield(group.PropertyList, 'Labels');
            end
            matlab.mixin.CustomDisplay.displayPropertyGroups(imds, group);
            disp(getFooter(imds));
        end
    end

    methods (Hidden)
        function files = getUnresolvedFiles(imds)
            files = imds.UnResolvedFiles;
        end
    end

    methods (Static, Hidden)

        function defaultExtensions = getDefaultExtensions
            % Get imformats specific extensions
            i = imformats;
            defaultExtensions = strcat('.', [i.ext]);
        end

        function varargout = supportsLocation(loc, nvStruct)
            % This function is responsible for determining whether a given
            % location is supported by ImageDatastore. It also returns a
            % resolved filelist.
            import matlab.io.datastore.internal.lookupAndFilterExtensions;
            import matlab.io.datastore.ImageDatastore;
            nvStruct.ForCompression = true;
            [varargout{1:nargout}] = lookupAndFilterExtensions(loc, nvStruct, ImageDatastore.getDefaultExtensions);
        end

        function outds = loadobj(ds)
            import matlab.io.datastore.ImageDatastore;
            % ImageDatastore was introduced in 15b
            originatingVersion = '2015b';
            currVersion = version('-release');
            switch class(ds)
                case 'struct'
                    % load datastore from struct
                    if isfield(ds, 'SchemaVersion') && ~isempty(ds.SchemaVersion)
                        originatingVersion = ds.SchemaVersion;
                    end
                    ds = ImageDatastore.loadFromStruct(ds);
                case 'matlab.io.datastore.ImageDatastore'
                    if isprop(ds, 'SchemaVersion') && ~isempty(ds.SchemaVersion)
                        originatingVersion = ds.SchemaVersion;
                    end
                    oldSplitter = ds.Splitter;
                    ds.Splitter = ImageDatastore.getEmptySplitter(oldSplitter.ReadFcn);
                    ImageDatastore.setCorrectSplitter(ds, oldSplitter);
                    reset(ds);
            end
            switch originatingVersion
                case {'2015b', '2016a'}
                    % ReadSize was introduced in 16b
                    ds.ReadSize = 1;
                    if isequal(originatingVersion, '2015b') && isequal(currVersion, '2016a')
                        % 15b in 16a: Labels was introduced in 16a
                        ds.Labels = {};
                    end
            end
            ds.SplitterName = ImageDatastore.WHOLE_FILE_CUSTOM_READ_SPLITTER_NAME;
            % if saved version is less than 2017a,
            if ~iCompareVersion(originatingVersion, '2017a')
                fcnInfo = functions(ds.ReadFcn);
                % Re-assign default ReadFcn from ImageDatastore's
                % private readDatastoreImage
                if isfield(fcnInfo, 'class') && isequal(fcnInfo.class,  'matlab.io.datastore.ImageDatastore') ...
                    && isequal(fcnInfo.function, 'readDatastoreImage')
                    ds.ReadFcn = @readDatastoreImage;
                end
            end

            if isempty(ds.NumFiles)
                ds.NumFiles = ds.Splitter.Files.NumFiles;
            end
            if isempty(ds.FileExts)
                setFileExtensions(ds);
            end

            if ~iscategorical(ds.FileExts)
                ds.FileExts = categorical(ds.FileExts);
            end

            % Set if ReadFcn is the default in the saved datastore
            setIsReadFcnDefault(ds, ds.ReadFcn);

            if ds.Splitter.NumSplits ~= 0
                % create a split reader that points to the
                % first split index.
                if ds.SplitIdx == 0
                    ds.SplitIdx = 1;
                end
                % create a stub reader so copy() works fine as it expects
                % a non empty datastore to have a reader.
                ds.SplitReader = ds.Splitter.createReader(ds.SplitIdx);
            end
            outds = loadobj@matlab.io.datastore.FileBasedDatastore(ds);
        end
    end

    methods (Static, Access = private)
        function ds = loadFromStruct(dsStruct)

            import matlab.io.datastore.ImageDatastore;
            % empty datastore
            ds = ImageDatastore({});
            ImageDatastore.setCorrectSplitter(ds, dsStruct.Splitter);
            reset(ds);

            fieldsToRemove = {'Splitter', 'BatchReader',...
                              'DataBuffer', 'ErrorBuffer',...
                              'FileBuffer', 'FileBufferFirstIndex',...
                              'StartIndexPrefetchFiles',...
                              };
            fieldList = fields(dsStruct);
            % Prior to 16b, BatchReader, DataBuffer, ErrorBuffer might not be present
            % Prior to 18a, FileBuffer, FileBufferFirstIndex, etc, might not be present
            fieldsToRemove = iIntersectStrings(fieldList, fieldsToRemove);

            if ~isempty(fieldsToRemove)
                dsStruct = rmfield(dsStruct, fieldsToRemove);
                fieldList = fields(dsStruct);
            end

            for fieldIndex = 1: length(fieldList)
                field = fieldList{fieldIndex};
                ds.(field) = dsStruct.(field);
            end
        end

        function splitter = getEmptySplitter(readFcn)

            import matlab.io.datastore.ImageDatastore;
            f = matlab.io.datastore.DsFileSet({});
            splitterName = ImageDatastore.WHOLE_FILE_CUSTOM_READ_SPLITTER_NAME;
            splitter = feval([splitterName, '.create'], f);
            splitter.ReadFcn = readFcn;
        end

        function setCorrectSplitter(ds, splitter)
            import matlab.io.datastore.ImageDatastore;
            if isa(splitter, ImageDatastore.WHOLE_FILE_CUSTOM_READ_SPLITTER_NAME_15b_17b)
                fileSizes = [splitter.Splits.FileSize];
                fileSizes = fileSizes(:);
                ds.Splitter.setFilesAndFileSizes(splitter.Files, fileSizes);
            else
                ds.Splitter = copy(splitter);
            end
        end
    end
end

function parsedStruct = iParseNameValues(varargin)
    persistent inpP;
    if isempty(inpP)
        import matlab.io.datastore.ImageDatastore;
        inpP = inputParser;
        addParameter(inpP, 'ReadSize', 1);
        addParameter(inpP, 'ReadFcn', @readDatastoreImage);
        addParameter(inpP, 'Labels', {});
        addParameter(inpP, 'LabelSource', 'none', @(x)validateattributes(x, {'char','string'}, {'nonempty'}));
        addParameter(inpP, 'IncludeSubfolders', false);
        addParameter(inpP, 'FileExtensions', -1);
        addParameter(inpP, 'AlternateFileSystemRoots', {});
        inpP.FunctionName = ImageDatastore.CONVENIENCE_CONSTRUCTOR_FCN_NAME;
    end
    parse(inpP, varargin{:});
    parsedStruct = inpP.Results;
    parsedStruct.LabelSource = validatestring(parsedStruct.LabelSource, {'none', 'foldernames'});
    parsedStruct.UsingDefaults = inpP.UsingDefaults;
    if ~ismember('Labels', inpP.UsingDefaults) && ~ismember('LabelSource', inpP.UsingDefaults) ...
        && strcmpi(parsedStruct.LabelSource, 'foldernames')
        error(message('MATLAB:datastoreio:imagedatastore:labelsLabelSourceCombined'));
    end
end

function labels = iGetDefaultLabels(sampleLabels, numLabels)
    switch class(sampleLabels)
        case 'cell'
            labels = repmat({''}, numLabels, 1);
        case 'logical'
            labels = false(numLabels,1);
        case 'categorical'
            labels = categorical(nan(numLabels,1));
        otherwise
            % It has to be numerical at this point, since
            % labels can only be numerical, logical, cellstr or
            % categorical.
            labels = zeros(numLabels, 1,'like',sampleLabels);
    end
end

% Add ungrouped counts and values to the count c, unique groups u, and
% the ungrouped indexes to n;
function [c, u, n] = iAddUngroupedCounts(ungrouped, ungroupedValue, c, u, n)
    ungroupedCount = nnz(ungrouped);
    if ungroupedCount ~= 0
        c = [c; ungroupedCount];
        u = [u; ungroupedValue];
        n = ungrouped;
    end
end

function maxThreads = iValidateMaxThreads(maxThreads)
    if ischar(maxThreads)
        maxThreads = validatestring(maxThreads, {'default'}, mfilename, 'MaxThreads');
        return;
    end
    classes = {'numeric'};
    attrs = {'scalar', 'positive', 'integer'};
    import matlab.io.datastore.ImageDatastore;
    validateattributes(maxThreads, classes, attrs, mfilename, 'MaxThreads');
end

function iValidateReadSize(rsize)
    classes = {'numeric'};
    attrs = {'>=', 1, 'scalar', 'positive', 'integer', 'nonsparse'};
    import matlab.io.datastore.ImageDatastore;
    validateattributes(rsize, classes, attrs, ...
        ImageDatastore.CONVENIENCE_CONSTRUCTOR_FCN_NAME, 'ReadSize');
end

% Compares MATLAB versions vOne and vTwo
% vOne, vTwo are versions obtained from version('-release') command.
% Returns true iff vOne >= vTwo
function tf = iCompareVersion(vOne, vTwo)
tf = true;
if isequal(vOne, vTwo)
    return;
end
vOneNum = str2double(vOne(1:4));
vTwoNum = str2double(vTwo(1:4));
if vOneNum > vTwoNum
    return;
elseif vOneNum == vTwoNum
    tf = vOne(5) > vTwo(5);
    return;
end
tf = false;
end

% A for loop version of intersect. Remove string items from setTwo
% if not present in setOne argument.
function setTwo = iIntersectStrings(setOne, setTwo)
    num = numel(setTwo);
    idxes = false(num, 1);
    for ii = 1:num
        idxes(ii) = any(strcmp(setOne, setTwo(ii)));
    end
    setTwo(~idxes) = [];
end
