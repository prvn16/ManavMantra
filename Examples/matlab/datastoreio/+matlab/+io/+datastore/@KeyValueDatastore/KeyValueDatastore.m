classdef (Sealed) KeyValueDatastore < ...
                  matlab.io.datastore.MatSeqDatastore & ...
                  matlab.io.datastore.TabularDatastore & ...
                  matlab.mixin.CustomDisplay
%KEYVALUEDATASTORE Datastore for key-value pairs for use with mapreduce.
%   KVDS = datastore(LOCATION)
%   KVDS = datastore(LOCATION,'Type','keyvalue')  creates a
%   KEYVALUEDATASTORE if a key-value formatted file or a collection of
%   such files is present in LOCATION. LOCATION has the following
%   properties:
%      - Can be a filename or a folder name
%      - Can be a cell array or string vector of multiple file or folder names
%      - Can contain a relative path (HDFS requires full paths)
%      - Can contain a wildcard (*) character.
%      - All the files in LOCATION must be MAT-Files (or Sequence files)
%        containing key-value data, typically produced by mapreduce.
%
%   KVDS = datastore(__,'IncludeSubfolders',TF) specifies the logical
%   true or false to indicate whether the files in each folder and its
%   subfolders are included recursively or not.
%
%   KVDS = datastore(__,'FileExtensions',EXTENSIONS) specifies the
%   extensions of files to be included. Values for EXTENSIONS can be:
%      - A character vector or string scalar, such as '.mat' or '.seq'
%        (empty quotes '' are allowed for files without extensions)
%      - A cell array of character vectors or a string vector, such as {'.mat', ''}
%
%   KVDS = datastore(__,'AlternateFileSystemRoots',ALTROOTS) specifies
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
%   KVDS = datastore(_,'ReadSize',readSize) specifies the maximum number
%   of key-value pairs returned by read or preview. By default, ReadSize is
%   1. If the values are small, increase ReadSize.
%
%   KVDS = datastore(_,'FileType',fileType) specifies the type of files in
%   LOCATION. The default FileType is 'mat', for key-value pairs stored in
%   MAT-files, typically produced by mapreduce. FileType can also be 'seq',
%   for key-value pairs stored in one or more sequence files, typically
%   produced by running mapreduce with Hadoop.
%
%
%   KeyValueDatastore Methods:
%
%      preview       - Read a small amount of data from the start of the
%                      datastore.
%      read          - Read some data from the datastore.
%      readall       - Read all of the data from the datastore.
%      hasdata       - Returns true if there is more data in the datastore.
%      reset         - Reset the datastore to the start of the data.
%      partition     - Return a new datastore that represents a single
%                      partitioned part of the original datastore.
%      numpartitions - Return an estimate for a reasonable number of
%                      partitions to use with the partition function for
%                      the given information.
%
%   KeyValueDatastore Properties:
%
%      Files                    - Cell array of character vectors of filenames. You
%                                 can also set this property using a string array.
%      AlternateFileSystemRoots - Alternate file system root paths for the Files.
%      FileType                 - The type of file supported by this datastore.
%      ReadSize                 - Upper limit for the number of key-value pairs to read.
%
%   Example:
%   --------
%      % 'mapredout.mat' is the output file of a mapreduce function.
%      kvds = datastore('mapredout.mat')
%      % Read the first key-value pair
%      kv1 = read(kvds)
%      % Set the ReadSize = 6, to read the next 6 key-value pairs.
%      kvds.ReadSize = 6;
%      % Read the next 6 key-value pairs
%      kv6 = read(kvds)
%      % Read all of the key-value pairs
%      kvall = readall(kvds)
%
%   See also matlab.io.datastore.TabularTextDatastore, mapreduce, datastore.

%   Copyright 2014-2017 The MathWorks, Inc.

    properties (Dependent)
        %Files -
        % MAT files or SEQUENCE files in the KeyValueDatastore.
        Files;
        %ReadSize -
        % Maximum number of key-value pairs to read. Default is 1.
        ReadSize;
    end

    properties (SetAccess = protected)
        %FileType -
        % The type of file supported by the KeyValueDatastore. FileType
        % must be 'mat' or 'seq'. By default, FileType is 'mat'.
        FileType;
    end

    properties (Access = protected)
        % Deployment needs a way to get files before resolving them
        UnresolvedFiles
        %ErrorCatalogName - Error catalog name for error handling
        ErrorCatalogName;
        %MFilename - mfilename of the subclasses for error handling
        MFilename;
        %ValuesOnly- Only values are supported from the MAT-files or Sequence files
        ValuesOnly;
    end

    properties (Access = private)
        % To help support future forward compatibility.  The value
        % indicates the version of MATLAB.
        SchemaVersion;
    end

    properties (Constant, Access = private)
       M_FILENAME = mfilename;
       ERROR_CATALOG_NAME = 'keyvaluedatastore';
       TABLE_OUTPUT_VARIABLE_NAMES = {'Key', 'Value'};
    end

    % Constructor
    methods
        % KeyValueDataStore can be constructed with files argument,
        % optionally providing FileType and ReadSize Name-Value pairs.
        function kvds = KeyValueDatastore(files, varargin)
            try
                import matlab.io.datastore.KeyValueDatastore;
                % string adoption - convert all NV pairs specified as
                % string to char
                files = convertStringsToChars(files);
                [varargin{:}] = convertStringsToChars(varargin{:});
                nameValues = KeyValueDatastore.parseNameValues(varargin{:});

                % SchemaVersion indicates the release number of MATLAB. This will be empty in
                % 14b or the appropriate release, if we set it in the constructor.
                kvds.SchemaVersion = version('-release');
                initializeForConstruction(kvds, files, nameValues);
            catch e
                throwAsCaller(e);
            end
        end
    end

    % Set and Get methods for properties
    methods
        % Set method for Files
        function set.Files(kvds, files)
            try
                % initialize the datastore with files, current filetype and current readsize
                [files, info] = preambleSetFiles(kvds, files);
                initDatastore(kvds, files, info);
            catch e
                throw(e)
            end
        end
         % Set method for ReadSize
        function set.ReadSize(kvds, readSize)
            try
                validateReadSize(kvds, readSize);
            catch e
                throw(e);
            end
            kvds.Splitter.KeyValueLimit = readSize;
            % if we have a non empty splitter, then a reader is guaranteed.
            if kvds.Splitter.NumSplits ~= 0
                kvds.SplitReader.KeyValueLimit = readSize;
            end
        end
        % Get Files
        function files = get.Files(kvds)
            files = kvds.Splitter.Files;
        end
        % Get ReadSize
        function readSize = get.ReadSize(kvds)
            readSize = kvds.Splitter.KeyValueLimit;
        end
    end

    methods (Access = private)
        % Initialize datastore values before passing to initDatastore of the superclass
        % MatSeqDatastore
        function initializeForConstruction(ds, files, info)
            import matlab.io.datastore.KeyValueDatastore;
            import matlab.io.datastore.MatSeqDatastore;

            ds.UnresolvedFiles = files;
            ds.ErrorCatalogName = KeyValueDatastore.ERROR_CATALOG_NAME;
            ds.MFilename = KeyValueDatastore.M_FILENAME;
            ds.ValuesOnly = false;
            info.ValuesOnly = false;
            info.FromConstruction = true;
            initDatastore(ds, files, info);
        end
    end

    methods (Static, Hidden)

        % This function is responsible for determining whether a given
        % location is supported by a KeyValueDatastore.
        function tf = supportsLocation(files, nvStruct)
            tf = false;
            if isempty(files) && iscell(files)
                % From datastore gateway, one will be able to construct an empty
                % KeyValueDatastore.
                tf = true;
                return;
            end
            nvStruct.ValuesOnly = false;
            tf = matlab.io.datastore.MatSeqDatastore.supportsLocation(files, nvStruct);
        end

        function outds = loadobj(ds)
            if ~isempty(ds.Splitter.Splits)
                if ~isfield(ds.Splitter.Splits, 'SchemaAvailable')
                    % This must be a 14b datastore being loaded in 15a or 15b
                    % Add SchemaAvailable false field to all the Splits, if not available
                    setSchemaAvailable(ds.Splitter, false);
                end
                if ~isfield(ds.Splitter.Splits, 'ValuesOnly')
                    % This must be a 14b datastore being loaded in 15a or 15b
                    % Add ValuesOnly false field to all the Splits, if not available
                    setSplitsWithValuesOnly(ds.Splitter, false);
                end

                if isfield(ds.Splitter.Splits, 'File')
                    % In MATLAB releases prior to 17b, the 'File' property existed
                    % in the Splits struct, this is being changed to 'Filename' for
                    % consistency with other datastores. Code here is to make this
                    % change in the Splits struct.
                    [ds.Splitter.Splits.Filename] = deal(ds.Splitter.Splits.File);
                    ds.Splitter.Splits = rmfield(ds.Splitter.Splits,'File');
                end
            end

            if isa(ds, 'struct') && isfield(ds, 'SchemaVersion') && ...
                    string(ds.SchemaVersion) >= "2018a"
                ds = matlab.io.datastore.KeyValueDatastore.loadFrom18aStruct(ds);
            elseif isprop(ds, 'SchemaVersion') && isequal(ds.SchemaVersion, [])
                % This must be a 14b datastore being loaded in 15a as
                % SchemaVersion was introduced only in 15a.
                matlab.io.datastore.KeyValueDatastore.load14bin15a(ds);
            elseif isa(ds, 'struct')
                % This must be a 14b datastore loaded in 15b
                ds = matlab.io.datastore.KeyValueDatastore.load14bIn15b(ds);
            end
            % At this point we have a KeyValueDatastore object which
            % calls the super class loadobj for safe loading.
            outds = loadobj@matlab.io.datastore.FileBasedDatastore(ds);
            replaceUNCPaths(outds);
        end
    end
    methods (Access = protected)
        function displayScalarObject(kvds)
            % header
            disp(getHeader(kvds));
            group = getPropertyGroups(kvds);
            detailsStr = evalc('details(kvds)');
            nsplits = strsplit(detailsStr, '\n');
            filesStr = nsplits(~cellfun(@isempty, strfind(nsplits, 'Files: ')));
            % Find the indent spaces from details
            nFilesIndent = strfind(filesStr{1}, 'Files: ') - 1;
            if nFilesIndent > 0
                % File Properties
                filesIndent = [sprintf(repmat(' ',1,nFilesIndent)) 'Files: '];
                nlspacing = sprintf(repmat(' ',1,numel(filesIndent)));
                if isempty(kvds.Files)
                    nlspacing = '';
                end
                import matlab.io.internal.cellArrayDisp;
                filesStrDisp = cellArrayDisp(kvds.Files, true, nlspacing);
                disp([filesIndent filesStrDisp]);
                % Remove Files property from the group, since custom
                % display is used for Files.
                group.PropertyList = rmfield(group.PropertyList, 'Files');
            end
            readSizeStr = nsplits(~cellfun(@isempty, strfind(nsplits, 'ReadSize: ')));
            nReadSizeIndent = strfind(readSizeStr{1}, 'ReadSize: ') - 1;
            readSizeIndent = [sprintf(repmat(' ',1,nReadSizeIndent)) 'ReadSize: '];
            disp([readSizeIndent getString(message('MATLAB:datastoreio:keyvaluedatastore:keyValueString', num2str(kvds.ReadSize)))]);
            group.PropertyList = rmfield(group.PropertyList, 'ReadSize');
            matlab.mixin.CustomDisplay.displayPropertyGroups(kvds, group);
            disp(getFooter(kvds));
        end

        % readData method protected declaration.
        [data, info] = readData(obj);

        % readAllData method protected declaration.
        data = readAllData(obj);
    end

    methods (Static, Access = private)

        function parsedStruct = parseNameValues(varargin)
            import matlab.io.datastore.MatSeqDatastore;
            import matlab.io.datastore.KeyValueDatastore;
            import matlab.io.datastore.mixin.CrossPlatformFileRoots;
            persistent inpP;
            if isempty(inpP)
                inpP = inputParser;
                addParameter(inpP, MatSeqDatastore.FILETYPE_PROP_NAME, KeyValueDatastore.DEFAULT_FILE_TYPE);
                addParameter(inpP, MatSeqDatastore.READSIZE_PROP_NAME, KeyValueDatastore.DEFAULT_READ_SIZE);
                addParameter(inpP, MatSeqDatastore.INCLUDE_SUBFOLDERS_NV_NAME, KeyValueDatastore.DEFAULT_INCLUDE_SUBFOLDERS);
                addParameter(inpP, MatSeqDatastore.FILE_EXTENSIONS_NV_NAME, KeyValueDatastore.DEFAULT_FILE_EXTENSIONS);
                addParameter(inpP, CrossPlatformFileRoots.ALTERNATE_FILESYSTEM_ROOTS_NV_NAME, CrossPlatformFileRoots.DEFAULT_ALTERNATE_FILESYSTEM_ROOTS);
                inpP.FunctionName = KeyValueDatastore.M_FILENAME;
            end
            parse(inpP, varargin{:});
            parsedStruct = inpP.Results;
            parsedStruct.UsingDefaults = inpP.UsingDefaults;
        end

        function ds = loadFrom18aStruct(inStruct)
            %LOADFROM18ASTRUCT Set the struct fields to the datastore properties
            %   This is a private helper which assigns the struct field values to the
            %   datastore properties.
            import matlab.io.datastore.KeyValueDatastore;
            ds = KeyValueDatastore({});
            % Setting up the datastore.
            inSplitter = inStruct.Splitter;
            inAlternateFileSystemRoots = inStruct.AlternateFileSystemRoots;
            inStruct = rmfield(inStruct, {'AlternateFileSystemRoots', 'Splitter'});
            field_list = fields(inStruct);
            for field_index = 1: length(field_list)
                field = field_list{field_index};
                ds.(field) = inStruct.(field);
            end

            switch inStruct.FileType
                case 'mat'
                    ds.FileType = 'mat';
                    import matlab.io.datastore.splitter.MatKVFileSplitter;
                    ds.Splitter = MatKVFileSplitter.createFromSplits(inSplitter.Splits);
                    ds.Splitter.KeyValueLimit = inSplitter.KeyValueLimit;
                case 'seq'
                    ds.FileType = 'seq';
                    import matlab.io.datastore.splitter.SequenceFileSplitter;
                    ds.Splitter = SequenceFileSplitter.createFromSplits(inSplitter.Splits);
                    ds.Splitter.KeyValueLimit = inSplitter.KeyValueLimit;
            end
            if ds.Splitter.NumSplits ~= 0
                % create a stub reader so copy() works fine as it expects
                % a non empty datastore to have a reader.
                ds.SplitReader = ds.Splitter.createReader(1);
            end

            c = onCleanup(@()defaultSetFromLoadObj(ds));
            ds.SetFromLoadObj = true;
            ds.AlternateFileSystemRoots = inAlternateFileSystemRoots;
        end

        function ds = load14bIn15b(dsStruct)
            import matlab.io.datastore.KeyValueDatastore;
            %empty datastore
            ds = KeyValueDatastore({});
            import matlab.io.datastore.splitter.*;
            switch dsStruct.SplitReader.FileType
                case 'mat'
                    ds.FileType = 'mat';
                    ds.Splitter = MatKVFileSplitter.createFromSplits(dsStruct.Splitter.Splits);
                    ds.Splitter.KeyValueLimit = dsStruct.SplitReader.KeyValueLimit;
                case 'seq'
                    ds.FileType = 'seq';
                    ds.Splitter = SequenceFileSplitter.createFromSplits(dsStruct.Splitter.Splits);
                    ds.Splitter.KeyValueLimit = dsStruct.SplitReader.KeyValueLimit;
            end
            if ds.Splitter.NumSplits ~= 0
                % create a stub reader so copy() works fine as it expects
                % a non empty datastore to have a reader.
                ds.SplitReader = ds.Splitter.createReader(1);
            end
        end

        function load14bin15a(ds)
            import matlab.io.datastore.KeyValueDatastore;
            [~, support] = KeyValueDatastore.supportsLocation(ds.Splitter.Files);
            switch support
                % 14b version automatically sets the FileType based on
                % Files property.
                case 'MATSupport'
                    ds.FileType = 'mat';
                case 'SEQSupport'
                    ds.FileType = 'seq';
            end
        end
    end

    methods (Hidden)
        % method used by deployment to get KeyValueLimit.
        function kvlimit = getKeyValueLimit(kvds)
            kvlimit = kvds.Splitter.KeyValueLimit;
        end
    end
end
