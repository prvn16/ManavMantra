classdef (Sealed) TallDatastore < ...
                  matlab.io.datastore.MatSeqDatastore & ...
                  matlab.mixin.CustomDisplay
%TALLDATASTORE Datastore for use with files produced by write method of tall.
%   TDS = datastore(LOCATION)
%   TDS = datastore(LOCATION,'Type','tall') creates an TALLDATASTORE if a
%   file or a collection of files that were outputs of write method on tall,
%   is present in LOCATION. LOCATION has the following properties:
%      - Can be a filename or a folder name
%      - Can be a cell array or string vector of multiple file or folder names
%      - Can contain a relative path (HDFS requires full paths)
%      - Can contain a wildcard (*) character.
%      - All the files in LOCATION must be MAT-Files (or Sequence files)
%        containing data, typically produced by write method of tall.
%
%   TDS = datastore(__,'ReadSize',readSize) specifies the maximum number of
%   data rows returned by read. By default, ReadSize is determined by the
%   datastore. If the values are small, increase ReadSize.
%
%   TDS = datastore(__,'FileType',fileType) specifies the type of files in
%   LOCATION. The default FileType is 'mat', for data stored in MAT-files,
%   typically produced by tall write method. FileType can also be 'seq',
%   for data stored in one or more sequence files, typically produced by
%   write method of tall.
%
%   TDS = datastore(__,'AlternateFileSystemRoots',ALTROOTS) specifies
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
%   TallDatastore Methods:
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
%   TallDatastore Properties:
%
%      Files                    - Cell array of character vectors of filenames. You
%                                 can also set this property using a string array.
%      AlternateFileSystemRoots - Alternate file system root paths for the Files.
%      FileType                 - The type of file supported by this datastore.
%      ReadSize                 - Upper limit for the number of key-value pairs to read.
%
%   Example:
%   --------
%      % Create a simple tall double.
%      t = tall(rand(500,1))
%      % Write to a new folder.
%      newFolder = fullfile(pwd, 'myTest');
%      write(newFolder, t)
%      % Create an TallDatastore from newFolder
%      tds = datastore(newFolder)
%      % Create a new tall using TallDatastore
%      t1 = tall(tds)
%
%   See also tall, tall/write, matlab.io.datastore.TallDatastore, mapreduce, datastore.

%   Copyright 2016-2017 The MathWorks, Inc.

    properties (Dependent = true)
        %Files -
        % MAT files or SEQUENCE files in the TallDatastore.
        Files;
    end

    properties
        %ReadSize -
        % Maximum number of data rows to read.
        ReadSize;
    end

    properties (SetAccess = protected)
        %FileType -
        % The type of file supported by the TallDatastore. FileType
        % must be 'mat' or 'seq'. By default, FileType is determined
        % by the type of file in the location provided.
        FileType;
    end

    properties (Access = protected)
        % deployment needs a way to get files before resolving them
        UnresolvedFiles
        %ErrorCatalogName - Error catalog name for error handling
        ErrorCatalogName;
        %MFilename - mfilename of the subclasses for error handling
        MFilename;
        %ValuesOnly- Only values are supported from the MAT-files or Sequence files
        ValuesOnly;
    end

    properties (Access = private)
        % Data buffered to support variable ReadSize
        BufferedData;
        % Size of the data buffered
        BufferedSize;
        % Info of the data buffered
        BufferedInfo;
        % Substruct used to subsref into BufferedData
        BufferedSubstruct;
        % Information about complexity of underlying type
        BufferedComplexityInfo;
    end

    properties (Constant, Access = protected)
        M_FILENAME = mfilename;
        ERROR_CATALOG_NAME = 'talldatastore';
    end
    % Constructor
    methods
        % TallDatastore can be constructed with files argument,
        % optionally providing FileType and ReadSize Name-Value pairs.
        function tds = TallDatastore(files, varargin)
            try
                import matlab.io.datastore.TallDatastore;

                % string adoption - convert all NV pairs specified as
                % string to char
                files = convertStringsToChars(files);
                [varargin{:}] = convertStringsToChars(varargin{:});
                nameValues = TallDatastore.parseNameValues(varargin{:});

                initializeForConstruction(tds, files, nameValues);
            catch e
                throwAsCaller(e);
            end
        end
    end

    % Set and Get methods for properties
    methods
        % Set method for Files
        function set.Files(tds, files)
            try
                % initialize the datastore with files, current filetype and current readsize
                [files, info] = preambleSetFiles(tds, files);
                initialize(tds, files, info);
            catch e
                throw(e)
            end
        end

        % Set method for ReadSize
        function set.ReadSize(tds, readSize)
            try
                validateReadSize(tds, readSize);
            catch e
                throw(e);
            end
            tds.ReadSize = readSize;
        end

        % Get Files
        function files = get.Files(tds)
            files = tds.Splitter.Files;
        end
    end

    methods (Access = private)
        % Initialize datastore values before passing to initDatastore of the superclass
        % MatSeqDatastore
        function initializeForConstruction(ds, files, info)
            import matlab.io.datastore.TallDatastore;
            import matlab.io.datastore.MatSeqDatastore;

            ds.UnresolvedFiles = files;
            ds.ErrorCatalogName = TallDatastore.ERROR_CATALOG_NAME;
            ds.MFilename = TallDatastore.M_FILENAME;
            ds.ValuesOnly = true;
            info.ValuesOnly = true;
            info.FromConstruction = true;
            % IncludeSubfolders and FileExtensions are not supported currently
            % Assign default values, so to use the underlying superclass code.
            info.UsingDefaults = horzcat(info.UsingDefaults, {MatSeqDatastore.FILE_EXTENSIONS_NV_NAME,...
                MatSeqDatastore.INCLUDE_SUBFOLDERS_NV_NAME});
            info.FileExtensions = -1;
            info.IncludeSubfolders = false;
            initialize(ds, files, info);
        end

        % Initialize using superclass common code and set private
        % properties after reset
        function initialize(tds, files, info)
            import matlab.io.datastore.MatSeqDatastore;

            % initialize using superclass common code
            initDatastore(tds, files, info);

            % This needs to be called after splitter (and splitreader, if any)
            % are initialized.
            setKeyValueLimit(tds);

            % Get the correct ReadSize from the SplitReader, if any
            [readSize, numDims] = getBestReadSize(tds);
            % If ReadSize is to be default, use the correct one from the SplitReader
            if ismember(MatSeqDatastore.READSIZE_PROP_NAME, info.UsingDefaults)
                tds.ReadSize = readSize;
            end
            setBufferedDataInfo(tds, numDims);
            setBufferedComplexityInfo(tds);
        end

        % Set the KeyValueLimit for Splitter and SplitReader during initialization
        function setKeyValueLimit(tds)
            import matlab.io.datastore.MatSeqDatastore;
            tds.Splitter.KeyValueLimit = MatSeqDatastore.DEFAULT_READ_SIZE;
            % if we have a non empty splitter, then a reader is guaranteed.
            if tds.Splitter.NumSplits ~= 0
                tds.SplitReader.KeyValueLimit = MatSeqDatastore.DEFAULT_READ_SIZE;
            end
        end

        % Set the private buffered substruct and buffered size values
        % This is called after setting BufferedData
        %
        % See also read, getDataUsingSubstructInfo
        function setBufferedDataInfo(tds, numDims)
            % colon : for all non-ReadSize dimensions
            col = repmat({':'}, 1, numDims - 1);
            tds.BufferedSubstruct = substruct('()', [{[]}, col]);
            tds.BufferedSize = 0;
            tds.BufferedData = [];
        end

        % Set the private buffered complexity infomation about the output
        % data. This exists to ensure all chunks of tall complex data
        % persist their complexity attribute, even if the chunk has no
        % complex values.
        function setBufferedComplexityInfo(tds)
            complexityInfo.HasComplexVariables = false;
            if ~isempty(tds.SplitReader)
                data = getBufferedValue(tds.SplitReader);
                [complexityInfo.HasComplexVariables, complexityInfo.ComplexVariables] ...
                    = matlab.io.datastore.internal.getComplexityInfo(data);
            end
            tds.BufferedComplexityInfo = complexityInfo;
        end

        % Get data using the private buffered substruct and buffered size values
        % This is called after setting BufferedSubstruct
        %
        % See also read, setBufferedDataInfo 
        function data = getDataUsingSubstructInfo(tds, readSize)
            % Set the subs field value to the readsize amount
            tds.BufferedSubstruct.subs{1} = 1:readSize;
            data = subsref(tds.BufferedData, tds.BufferedSubstruct);
            tds.BufferedSubstruct.subs{1} = readSize+1:tds.BufferedSize;
            % Reset the buffered data to the remaining data
            tds.BufferedData = subsref(tds.BufferedData, tds.BufferedSubstruct);
            tds.BufferedSize = tds.BufferedSize - readSize;
            if tds.BufferedComplexityInfo.HasComplexVariables
                data = matlab.io.datastore.internal.applyComplexityInfo(...
                    data, tds.BufferedComplexityInfo.ComplexVariables);
                tds.BufferedData = matlab.io.datastore.internal.applyComplexityInfo(...
                    tds.BufferedData, tds.BufferedComplexityInfo.ComplexVariables);
            end
        end

        % This gets the best readsize based on the values
        % in the underlying file container - MAT-Files or Sequence Files
        function [readSize, numDims] = getBestReadSize(tds)
            readSize = 1;
            numDims = 2;
            if isempty(tds.SplitReader)
                % empty matrix [0x1] for an uninitialized SplitReader
                % Not for empty datastores created from partition of non-empty datastore
                return;
            end
            
            while hasNext(tds.SplitReader) || hasdata(tds)
                data = getBufferedValue(tds.SplitReader);
                % if the first value is cell, rest of them are
                % cell as well. So ReadSize = 1, is safe for default.
                if iscell(data)
                    return;
                end
                
                if ~isempty(data)
                    break;
                end
                getNext(tds.SplitReader);
            end
            
            if isempty(data)
                % Must be entirely empty.  Use ReadSize = 1.
                return;
            end
                         
            % if the value is an N-D array, get the first dimension
            % which is the ReadSize dimension.
            readSize = size(data, 1);
            numDims = ndims(data);
        end

        % Used by preview
        % This subsrefs the value from the underlying container - MAT-Files or Sequence Files,
        % using the stored substruct, with zero first dimension.
        function data = getZeroFirstDimData(tds)
            if isempty(tds.SplitReader)
                % empty matrix for an uninitialized SplitReader
                % This will not happen for empty datastores created from partition
                % of non-empty datastore
                data = zeros(0,1);
                return;
            end
            data = getBufferedValue(tds.SplitReader);
            tds.BufferedSubstruct.subs{1} = [];
            data = subsref(data, tds.BufferedSubstruct);
        end
    end

    methods (Static, Access = private)

        % Parse the Name-Value pairs for TallDatastore
        function parsedStruct = parseNameValues(varargin)
            persistent inpP;
            if isempty(inpP)
                import matlab.io.datastore.MatSeqDatastore;
                import matlab.io.datastore.TallDatastore;
                import matlab.io.datastore.mixin.CrossPlatformFileRoots;
                inpP = inputParser;
                addParameter(inpP, MatSeqDatastore.FILETYPE_PROP_NAME, MatSeqDatastore.DEFAULT_FILE_TYPE);
                addParameter(inpP, MatSeqDatastore.READSIZE_PROP_NAME, MatSeqDatastore.DEFAULT_READ_SIZE);
                addParameter(inpP, CrossPlatformFileRoots.ALTERNATE_FILESYSTEM_ROOTS_NV_NAME, CrossPlatformFileRoots.DEFAULT_ALTERNATE_FILESYSTEM_ROOTS);
                inpP.FunctionName = TallDatastore.M_FILENAME;
            end
            parse(inpP, varargin{:});
            parsedStruct = inpP.Results;
            parsedStruct.UsingDefaults = inpP.UsingDefaults;
        end

        function ds = loadFrom18aStruct(inStruct)
            %LOADFROM18ASTRUCT Set the struct fields to the datastore properties
            %   This is a private helper which assigns the struct field values to the
            %   datastore properties.
            import matlab.io.datastore.TallDatastore;
            ds = TallDatastore({});
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
    end

    methods (Static, Hidden)

        % This function is responsible for determining whether a given
        % location is supported by a TallDatastore.
        function tf = supportsLocation(files, nvStruct)
            tf = false;
            if isempty(files)
                %From datastore gateway, one will not be able to construct an empty
                % datastore, except with a type Name-Value pair.
                return;
            end
            nvStruct.ValuesOnly = true;
            tf = matlab.io.datastore.MatSeqDatastore.supportsLocation(files, nvStruct);
        end

        function outds = loadobj(ds)
            if isa(ds, 'struct')
                ds = matlab.io.datastore.TallDatastore.loadFrom18aStruct(ds);
            end
            % At this point we have a TallDatastore object which
            % calls the super class loadobj for safe loading.
            outds = loadobj@matlab.io.datastore.MatSeqDatastore(ds);
            replaceUNCPaths(outds);
        end
    end

    methods (Access = protected)
        % matlab.mixin.CustomDisplay method.
        % Used for custom display the properties of the object.
        function displayScalarObject(tds)
            % header
            disp(getHeader(tds));
            group = getPropertyGroups(tds);
            detailsStr = evalc('details(tds)');
            nsplits = strsplit(detailsStr, '\n');
            filesStr = nsplits(~cellfun(@isempty, strfind(nsplits, 'Files: ')));
            % Find the indent spaces from details
            nFilesIndent = strfind(filesStr{1}, 'Files: ') - 1;
            if nFilesIndent > 0
                % File Properties
                filesIndent = [sprintf(repmat(' ',1,nFilesIndent)) 'Files: '];
                nlspacing = sprintf(repmat(' ',1,numel(filesIndent)));
                if isempty(tds.Files)
                    nlspacing = '';
                end
                import matlab.io.internal.cellArrayDisp;
                filesStrDisp = cellArrayDisp(tds.Files, true, nlspacing);
                disp([filesIndent filesStrDisp]);
                % Remove Files property from the group, since custom
                % display is used for Files.
                group.PropertyList = rmfield(group.PropertyList, 'Files');
            end
            matlab.mixin.CustomDisplay.displayPropertyGroups(tds, group);
            disp(getFooter(tds));
        end

    end
end
