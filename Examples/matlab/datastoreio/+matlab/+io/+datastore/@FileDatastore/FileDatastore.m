classdef (Sealed) FileDatastore < ...
                  matlab.io.datastore.CustomReadDatastore & ...
                  matlab.io.datastore.mixin.CrossPlatformFileRoots & ...
                  matlab.io.datastore.internal.ScalarBase & ...
                  matlab.mixin.CustomDisplay
%FILEDATASTORE Datastore for a collection of files with custom data format.
%   FDS = fileDatastore(LOCATION,'ReadFcn',@MYCUSTOMREADER) creates a
%   FileDatastore if a file or a collection of files are present in LOCATION.
%   LOCATION has the following properties:
%      - Can be a filename or a folder name
%      - Can be a cell array or string vector of multiple file or folder names
%      - Can contain a relative path (HDFS requires a full path)
%      - Can contain a wildcard (*) character.
%   'ReadFcn',@MYCUSTOMREADER Name-Value pair specifies the user-defined
%   function to read files. The value of 'ReadFcn' must be a function handle
%   with a signature similar to the following:
%      function data = MYCUSTOMREADER(filename)
%      ..
%      end
%
%   FDS = fileDatastore(__,'UniformRead',TF) specifies the logical
%   true or false to indicate whether multiple reads of FileDatastore will
%   return uniform data that can be vertically concatenated. The default
%   value is false. If true, the ReadFcn must return vertically concatenable
%   data or the readall method will error. If true, the readall method will
%   return vertically concatenated data, otherwise returns a cell array with
%   data from each read method call added to the cell array.
%
%   FDS = fileDatastore(__,'IncludeSubfolders',TF) specifies the logical
%   true or false to indicate whether the files in each folder and its
%   subfolders are included recursively or not.
%
%   FDS = fileDatastore(__,'FileExtensions',EXTENSIONS) specifies the
%   extensions of files to be included. Values for EXTENSIONS can be:
%      - A character vector or string scalar, such as '.jpg' or '.png'
%        (empty quotes '' are allowed for files without extensions)
%      - A cell array of character vectors or a string vector, such as {'.jpg', '.mat'}
%
%   FDS = fileDatastore(__,'AlternateFileSystemRoots',ALTROOTS) specifies
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
%   FileDatastore Properties:
%
%      Files                    - Cell array of character vectors of file names. You
%                                 can also set this property using a string array.
%      AlternateFileSystemRoots - Alternate file system root paths for the Files.
%      ReadFcn                  - Function handle used to read files.
%      UniformRead              - Indicates whether or not the output of multiple
%                                 read method calls can be vertically concatenated.
%
%   FileDatastore Methods:
%
%      hasdata       - Returns true if there is more data in the datastore
%      read          - Reads the next consecutive file
%      reset         - Resets the datastore to the start of the data
%      preview       - Reads the first file from the datastore for preview
%      readall       - Reads all of the files from the datastore
%      partition     - Returns a new datastore that represents a single
%                      partitioned portion of the original datastore
%      numpartitions - Returns an estimate for a reasonable number of
%                      partitions according to the total data size to use
%                      with the partition function
%
%   Example:
%   --------
%      folder = fullfile(matlabroot,'toolbox','matlab','demos');
%      fds = fileDatastore(folder,'ReadFcn',@load,'FileExtensions','.mat');
%
%      data1 = read(fds);                   % Read the first MAT-file
%      data2 = read(fds);                   % Read the next MAT-file
%      readall(fds)                         % Read all of the MAT-files
%      dataArr = cell(numel(fds.Files),1);
%      i = 1;
%      reset(fds);                          % Reset to the beginning of data
%      while hasdata(fds)                   % Read files using a while-loop
%          dataArr{i} = read(fds);
%          i = i + 1;
%      end
%
%   See also datastore, mapreduce, load, fileDatastore.

%   Copyright 2015-2017 The MathWorks, Inc.

    properties (Dependent)
        %Files
        % A cell array of character vectors of file names. You can also set
        % this property using a string array.
        Files;
    end

    properties (Access = private)
        %UnResolvedFiles
        % Deployement needs a way to get files before resolving them.
        UnResolvedFiles;

        %BufferedZero1DimData
        % preview and readall methods needs buffered data with zero first
        % dimension if UniformRead is true.
        BufferedZero1DimData;
    end

    properties (SetAccess = private)
        %UniformRead
        % Indicates whether multiple reads of FileDatastore will
        % return uniform data that can be vertically concatenated.
        % The default value is false. If true, the ReadFcn must return
        % vertically concatenable data or the readall method will error.
        % If true, the readall method will return vertically concatenated
        % data, otherwise returns a cell array with data from each read
        % method call added to the cell array.
        UniformRead = false; %  Loading objects saved in previous versions will just have the default value.
    end

    properties (Constant, Access = private)
        WHOLE_FILE_CUSTOM_READ_SPLITTER_NAME = 'matlab.io.datastore.splitter.WholeFileCustomReadSplitter';
        CONVENIENCE_CONSTRUCTOR_FCN_NAME = 'fileDatastore';
    end
    % Constructor
    methods
        % FileDataStore can be constructed with files argument, optionally
        % with ReadFcn, IncludeSubfolders, FileExtensions Name-Value pairs.
        function fds = FileDatastore(files, varargin)
            try
                import matlab.io.datastore.FileDatastore;
                % string adoption - convert all NV pairs specified as
                % string to char
                files = convertStringsToChars(files);
                [varargin{:}] = convertStringsToChars(varargin{:});
                nv = iParseNameValues(varargin{:});
                initDatastore(fds, files, nv);
                fds.UnResolvedFiles = files;
            catch e
                throwAsCaller(e);
            end
        end
    end

    % Set and Get methods for properties
    methods
        % Set method for Files
        function set.Files(fds, files)
            try
                [diffIndexes, ~, files, fileSizes, diffPaths] = setNewFilesAndFileSizes(fds, files);
                files(diffIndexes) = diffPaths;
                initFromReadFcn(fds, fds.ReadFcn, files, fileSizes, false);
            catch e
                throw(e)
            end
        end
        % Get Files
        function files = get.Files(fds)
            files = fds.Splitter.Files;
        end
    end

    methods (Access = private)

        function initDatastore(fds, files, nv)
            import matlab.io.datastore.FileDatastore;
            import matlab.io.datastore.internal.validators.validateCustomReadFcn;
            import matlab.io.datastore.internal.validators.validateLogicalOption;


            fds.UniformRead = validateLogicalOption(nv.UniformRead,...
                'MATLAB:datastoreio:filedatastore:invalidUniformRead');
            readFcn = nv.ReadFcn;
            if ismember('ReadFcn', nv.UsingDefaults) && ...
                    isnumeric(readFcn) && readFcn == -1
                error(message('MATLAB:datastoreio:filedatastore:readFcnNotProvided'));
            end
            validateCustomReadFcn(readFcn, true, FileDatastore.CONVENIENCE_CONSTRUCTOR_FCN_NAME);

            [~, files, fileSizes] = FileDatastore.supportsLocationHelper(files, nv);
            fds.SplitterName = FileDatastore.WHOLE_FILE_CUSTOM_READ_SPLITTER_NAME;
            % Files are resolved @supportsLocationHelper
            initFromReadFcn(fds, readFcn, files, fileSizes, nv.IncludeSubfolders);
            fds.AlternateFileSystemRoots = nv.AlternateFileSystemRoots;
            setBufferedData(fds);
        end

        function setBufferedData(fds)
            if ~fds.UniformRead
                % empty cell for non-uniform read
                fds.BufferedZero1DimData = cell(0,1);
                return;
            end
            % empty matrix for an uninitialized SplitReader
            fds.BufferedZero1DimData = zeros(0,1);
            if isempty(fds.SplitReader)
                % This will not happen for empty datastores created from partition
                % of non-empty datastores
                return;
            end
            % Used by preview and readall
            % This subsrefs the value from the first available data
            % using a substruct with zero first dimension.
            if hasNext(fds.SplitReader)
                data = getNext(fds.SplitReader);
                reset(fds.SplitReader);
                % colon : for all non-tall dimensions
                col = repmat({':'}, 1, ndims(data) - 1);
                % () subsref'ing with zero 1st dimension.
                substr = substruct('()', [{[]}, col]);
                fds.BufferedZero1DimData = subsref(data, substr);
            end
        end
    end

    methods (Access = protected)

        function validateReadFcn(~, readFcn)
            import matlab.io.datastore.FileDatastore;
            import matlab.io.datastore.internal.validators.validateCustomReadFcn;
            validateCustomReadFcn(readFcn, false, FileDatastore.CONVENIENCE_CONSTRUCTOR_FCN_NAME);
        end

        function displayScalarObject(fds)
            % header
            disp(getHeader(fds));
            group = getPropertyGroups(fds);
            detailsStr = evalc('details(fds)');
            nsplits = strsplit(detailsStr, '\n');
            filesStr = nsplits(contains(nsplits, 'Files: '));
            % Find the indent spaces from details
            nFilesIndent = strfind(filesStr{1}, 'Files: ') - 1;
            if nFilesIndent > 0
                % File Properties
                filesIndent = [sprintf(repmat(' ',1,nFilesIndent)) 'Files: '];
                nlspacing = sprintf(repmat(' ',1,numel(filesIndent)));
                if isempty(fds.Files)
                    nlspacing = '';
                end
                import matlab.io.internal.cellArrayDisp;
                filesStrDisp = cellArrayDisp(fds.Files, true, nlspacing);
                disp([filesIndent filesStrDisp]);
                % Remove Files property from the group, since custom
                % display is used for Files.
                group.PropertyList = rmfield(group.PropertyList, 'Files');
            end
            matlab.mixin.CustomDisplay.displayPropertyGroups(fds, group);
            disp(getFooter(fds));
        end
    end

    methods (Hidden)
        function files = getUnresolvedFiles(fds)
            files = fds.UnResolvedFiles;
        end
    end

    methods (Static, Hidden)

        function tf = supportsLocation(~, ~)
            % This function is responsible for determining whether a given
            % location is supported by FileDatastore. For FileDatastore
            % 'Type' Name-Value pair must be provided for datastore function.

            tf = false;
        end

        function varargout = supportsLocationHelper(loc, nvStruct)
            % This function is responsible for determining whether a given
            % location is supported by FileDatastore. It also returns a
            % resolved filelist.
            defaultExtensions = {};
            % validate file extensions, include subfolders is validated in
            % pathlookup
            import matlab.io.datastore.internal.validators.validateFileExtensions;
            import matlab.io.datastore.FileBasedDatastore;

            isDefaultExts = validateFileExtensions(nvStruct.FileExtensions, nvStruct.UsingDefaults);
            [varargout{1:nargout}] = FileBasedDatastore.supportsLocation(loc, nvStruct, defaultExtensions, ~isDefaultExts);
        end

        function outds = loadobj(ds)
            if isa(ds, 'struct')
                ds = matlab.io.datastore.FileDatastore.structToDatastore(ds);
            end
            if ds.Splitter.NumSplits ~= 0
                % create a split reader that points to the
                % first split index.
                if ds.SplitIdx == 0
                    ds.SplitIdx = 1;
                end
                ds.SplitReader = ds.Splitter.createReader(ds.SplitIdx);
            end
            outds = loadobj@matlab.io.datastore.FileBasedDatastore(ds);
            replaceUNCPaths(outds);
        end
    end

    methods (Static, Access = private)
        function ds = structToDatastore(inStruct)
            %STRUCTTODATASTORE Set the struct fields to the datastore properties
            %   This is a private helper which assigns the struct field values to the
            %   datastore properties.
            ds = fileDatastore({}, 'ReadFcn', inStruct.Splitter.ReadFcn);
            % Setting up the datastore.
            inSplitter = inStruct.Splitter;
            inAlternateFileSystemRoots = inStruct.AlternateFileSystemRoots;
            inStruct = rmfield(inStruct, {'AlternateFileSystemRoots', 'Splitter'});
            field_list = fields(inStruct);
            for field_index = 1: length(field_list)
                field = field_list{field_index};
                ds.(field) = inStruct.(field);
            end
            files = inSplitter.getFilesAsCellStr();
            fileSizes = inSplitter.getFileSizes();
            initFromReadFcn(ds, inSplitter.ReadFcn, files, fileSizes, false);
            c = onCleanup(@()defaultSetFromLoadObj(ds));
            ds.SetFromLoadObj = true;
            ds.AlternateFileSystemRoots = inAlternateFileSystemRoots;
            ds.ReadFcn = inSplitter.ReadFcn;
        end
    end
end

function parsedStruct = iParseNameValues(varargin)
    persistent inpP;
    if isempty(inpP)
        import matlab.io.datastore.FileDatastore;
        import matlab.io.datastore.mixin.CrossPlatformFileRoots;
        inpP = inputParser;
        addParameter(inpP, 'ReadFcn', -1);
        addParameter(inpP, 'UniformRead', false);
        addParameter(inpP, 'IncludeSubfolders', false);
        addParameter(inpP, 'FileExtensions', -1);
        addParameter(inpP, CrossPlatformFileRoots.ALTERNATE_FILESYSTEM_ROOTS_NV_NAME, CrossPlatformFileRoots.DEFAULT_ALTERNATE_FILESYSTEM_ROOTS);
        inpP.FunctionName = FileDatastore.CONVENIENCE_CONSTRUCTOR_FCN_NAME;
    end
    parse(inpP, varargin{:});
    parsedStruct = inpP.Results;
    parsedStruct.UsingDefaults = inpP.UsingDefaults;
end
