classdef (Sealed) SpreadsheetDatastore < ...
                  matlab.io.datastore.FileBasedDatastore & ...
                  matlab.io.datastore.mixin.CrossPlatformFileRoots & ...
                  matlab.io.datastore.TabularDatastore & ...
                  matlab.io.datastore.internal.ScalarBase & ...
                  matlab.mixin.CustomDisplay
%SPREADSHEETDATASTORE Datastore for a collection of spreadsheet files.
%   SSDS = spreadsheetDatastore(LOCATION) creates a SpreadsheetDatastore
%   based on a spreadsheet file or a collection of such files in LOCATION.
%   LOCATION has the following properties:
%      - Can be a filename or a folder name
%      - Can be a cell array or string vector of multiple file or folder names
%      - Can contain a relative path
%      - Can contain a wildcard (*) character
%      - All of the files in LOCATION must have the extension .xlsx, .xls,
%        .xlsm, .xltm, or .xltx
%
%   SSDS = spreadsheetDatastore(__,'IncludeSubfolders',TF) specifies the
%   logical true or false to indicate whether the files in each folder and
%   its subfolders are included recursively or not.
%
%   SSDS = spreadsheetDatastore(__,'FileExtensions',EXTENSIONS) specifies
%   the extensions of files to be included in the SpreadsheetDatastore. The
%   extensions are not required to be either .xlsx, .xls, .xlsm, .xltm, or
%   .xltx. Values for EXTENSIONS can be:
%      - A character vector or a string scalar, such as '.xls' or '.xlsm'
%        or '.myformat' (empty quotes '' are allowed for files without extensions)
%      - A cell array of character vectors or a string vector, such as
%        {'.xls', '.xlsm', '.myformat'}
%
%   SSDS = spreadsheetDatastore(__,'AlternateFileSystemRoots',ALTROOTS) specifies
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
%   SSDS = spreadsheetDatastore(__,'TextType', TEXTTYPE) specifies the
%   output data type of text variables, with TEXTTYPE specified as either
%   'char' or 'string'. If the output table from the read, readall or
%   preview functions contains text variables, then TEXTTYPE specifies the
%   data type of those variables. If TEXTTYPE is 'char', then the output is
%   a cell array of character vectors. If TEXTTYPE is 'string', then the
%   output has type string.
%
%   SSDS = spreadsheetDatastore(__,'Name1',Value1,'Name2',Value2,...) specifies the
%   properties of SSDS using optional name-value pairs.
%
%   SpreadsheetDatastore Methods:
%
%   preview         -    Read 8 rows from the start of the datastore.
%   read            -    Read subset of data from the datastore.
%   readall         -    Read all of the data from the datastore.
%   hasdata         -    Returns true if there is more data in the datastore.
%   reset           -    Reset the datastore to the start of the data.
%   partition       -    Return a new datastore that represents a single
%                        partitioned part of the original datastore.
%   numpartitions   -    Return an estimate for a reasonable number of
%                        partitions to use with the partition function for
%                        the given information.
%   sheetnames      -    returns sheetnames from a file or a file index.
%
%   SpreadsheetDatastore Properties:
%
%   Files                    - A cell array of character vectors of
%                              spreadsheet files. You can also set this property
%                              using a string array.
%   AlternateFileSystemRoots - Alternate file system root paths for the Files.
%   Sheets                   - Sheets of interest.
%   Range                    - Range of interest.
%   NumHeaderLines           - Number of header lines to skip from the
%                              beginning of the block specified by Range.
%   ReadVariableNames        - Indicator for reading first row of the block
%                              specified by Range as variable names.
%   VariableNames            - Names of variables.
%   VariableTypes            - Output types of the variables.
%   SelectedVariableNames    - Variables of interest.
%   SelectedVariableTypes    - Output types for the variables of interest.
%   ReadSize                 - Upper limit on the size of the data returned by the read method.
%
%   Example:
%   --------
%      % Create a SpreadsheetDatastore
%      ssds = spreadsheetDatastore('airlinesmall_subset.xlsx')
%      % We are only interested in the Arrival Delay data
%      ssds.SelectedVariableNames = 'ArrDelay'
%      % Preview the first 8 rows of the data as a table
%      tab8 = preview(ssds)
%      % Sum the Arrival Delays
%      sumAD = 0;
%      ssds.ReadSize = 'sheet';
%      while hasdata(ssds)
%         tab = read(ssds);
%         data = tab.ArrDelay(~isnan(tab.ArrDelay)); % filter data
%         sumAD = sumAD + sum(data);
%      end
%      sumAD
%
%   See also datastore, mapreduce, readtable, xlsread, spreadsheetDatastore.

%   Copyright 2015-2017 The MathWorks, Inc.

    properties (Constant, Access = 'private')
        READSIZE_FILE = 'file';
        READSIZE_SHEET = 'sheet';
        RANGE_SEPARATOR = ':';
        SUPPORTED_TYPES = {'string', 'char', 'double', 'datetime', 'duration', 'categorical'};
        DEFAULT_PREVIEW_LINES = 8;
        SCHEMA_16B = '2016b';
    end
    
    properties (Dependent)
        %FILES A cell array of character vectors of spreadsheet files. You 
        %can also set this property using a string array.
        %   Files included in the datastore, specified as a cell array of
        %   character vectors, where each character vector is a full path
        %   to a file. You can also specify this property using a string
        %   array. These are the files defined by the location argument
        %   to the datastore function. The first file specified by the
        %   Files property determines the variable names and format
        %   information for all files in the datastore.
        Files;
        
        %Sheets Represents the sheets of interest.
        %   This property represents the sheets of interest. Can be a
        %   single sheet name specified a character vector or a scalar
        %   string, multiple sheet names specified as a cell array of
        %   character vectors, or a string array, or a numeric vector of
        %   sheet numbers.
        Sheets;
        
        %Range Rectangular block of interest
        %   Signifies a rectangular block of interest. This is basically
        %   the block within which all the data lives.
        Range;
        
        %NUMHEADERLINES Number of lines to skip from the beginning of the
        %block specified by Range.
        %   Number of lines to skip, specified as a positive integer.
        %   datastore ignores the specified number of header lines before
        %   reading the variable names or data.
        NumHeaderLines;
        
        %READVARIABLENAMES Indicator for reading first row relative to the
        %Range as variable names.
        ReadVariableNames;
        
        %VARIABLENAMES Names of variables 
        VariableNames;
        
        %VARIABLETYPES Output types of the variables.
        VariableTypes;
        
        %SELECTEDVARIABLENAMES Names of variables of interest
        SelectedVariableNames;
        
        %SELECTEDVARIABLETYPES Output types for the variables of interest.
        SelectedVariableTypes;       
        
        %READSIZE Upper limit on the size of the data returned by the read
        %method.
        ReadSize;
    end
    
    properties (Access = 'private')
        PrivateSheets = '';
        PrivateRange = '';
        PrivateNumHeaderLines;
        PrivateReadVariableNames;
        PrivateVariableNames;
        PrivateVariableTypes;
        PrivateSelectedVariableNames;
        PrivateSelectedVariableTypes;
        PrivateReadSize;
    end

    % These properties are transient as they can change between releases
    % and can issue warning while save-loading. loadobj needs to create these
    % objects to make sure they are available with appropriate values between
    % releases.
    properties (Access = private, Transient)
        %BOOK Workbook object created from the first file.
        BookObject;

        %SHEET Sheet object created from the first sheet name or number.
        SheetObject;
    end

    properties (Access = 'private')
        %PRIVATESHEETFORMATINFO Struct to hold the sheet format information
        %   This is struct which holds VariableNames, VariableTypes,
        %   SelectedVariableNames, SelectedVariableTypes. This is useful
        %   information which is used in introspection and reintrospection.
        PrivateSheetFormatInfo;
       
        %CONSTRUCTIONDONE Boolean to indicate if construction is done        
        ConstructionDone = false;
        
        %RANGEVECTOR  is a 4 element row-vector 
        %   This is a 4 element row vector containing 1 based indexes. e.g.
        %   [4, 5, 6, 7] represents a range starting at the 4th row, 5th
        %   column of the sheet spanning the next 6 rows and 7 columns.
        RangeVector;
        
        %SELECTEDVARIABLENAMESIDX Logical Indices of SelectedVariableNames
        SelectedVariableNamesIdx;
        
        %SHEETSTOREADIDX Indicates the index of the sheet
        SheetsToReadIdx = 1;
        
        %ISDATAAVAILABLETOCONVERT boolean which indicates if there is data
        % passed on from the splitreader for conversion
        IsDataAvailableToConvert = false;

        %ISFIRSTFILEBOOK boolean to indicate if the BookObject owned
        % by the datastore has been created from a file other than the first file
        % or if BookObject needs to be created for the first file (eg., after construction,
        % or after loading from a MAT-file), during reset.
        IsFirstFileBook = false;

        %CURRINFO represents the info struct from the split reader.
        CurrInfo;
        
        %CURRRANGEVECTOR represents the current range vector in the
        %sheet being read.
        CurrRangeVector;
        
        %NUMROWSAVAILABLEINSHEET number of rows available to read in sheet
        NumRowsAvailableInSheet = 0;

        % To help support backward compatibility. The value indicates
        % the version of MATLAB.
        SchemaVersion;

        %TEXTTYPE The output type of text data.
        %   'char'   - Return text as a cell array of character vectors.
        %   'string' - Return text as a string array.
        TextType;
    end
    
    % constructor
    methods
        function ds = SpreadsheetDatastore(files, varargin)
            try
                % imports
                import matlab.io.datastore.splitter.SpreadsheetSplitter;
                import matlab.io.datastore.SpreadsheetDatastore;

                % string adoption - convert all NV pairs specified as
                % string to char
                [files, varargin{:}] = convertStringsToChars(files, varargin{:});

                % parse datastore properties
                resStruct = parseSpreadsheetInputs(varargin{:});

                % get the list of resolved files
                [~, files, fileSizes] = SpreadsheetDatastore.supportsLocation(files, resStruct);

                % set up the splitter
                ds.Splitter = SpreadsheetSplitter.create(files, fileSizes);

                % reset the datastore
                reset(ds);

                % initialize the SpreadsheetDatastore properties
                initSheetProperties(ds, resStruct);

                % introspect the first file
                introspectFile(ds);

                % complete construction of the datastore
                completeConstruction(ds);

                % SchemaVersion indicates the release number of MATLAB.
                ds.SchemaVersion = version('-release');
            catch ME
                throwAsCaller(ME);
            end
        end
    end
    
    methods
        % Files setter
        function set.Files(ds, files)
            try
                validateFiles(ds, files);
            catch ME
                throw(ME);
            end
        end
        
        % Sheets setter
        function set.Sheets(ds, sheets)
            try
                if isstring(sheets)
                    sheets = convertStringsToChars(sheets);
                end
                validateSheets(ds, sheets);
            catch ME
                throw(ME);
            end
        end
        
        % Range setter
        function set.Range(ds, range)
            try
                range = convertStringsToChars(range);
                validateRange(ds, range);
            catch ME
                throw(ME);
            end
        end
        
        % NumHeaderLines setter
        function set.NumHeaderLines(ds, hdrLines)
            try
                validateNumHeaderLines(ds, hdrLines);
            catch ME
                throw(ME);
            end
        end
        
        % ReadVariableNames setter
        function set.ReadVariableNames(ds, readVarNames)
            try
                validateReadVariableNames(ds, readVarNames);
            catch ME
                throw(ME);
            end
        end
        
        % VariableNames setter
        function set.VariableNames(ds, varNames)
            try
                varNames = convertStringsToChars(varNames);
                validateVariableNames(ds, varNames);
            catch ME
                throw(ME);
            end
        end
        
        % VariableTypes setter
        function set.VariableTypes(ds, varTypes)
            try
                varTypes = convertStringsToChars(varTypes);
                validateVariableTypes(ds, varTypes);
            catch ME
                throw(ME);
            end
        end
        
        % SelectedVariableNames setter
        function set.SelectedVariableNames(ds, svarNames)
            try
                svarNames = convertStringsToChars(svarNames);
                validateSelectedVariableNames(ds, svarNames);
            catch ME
                throw(ME);
            end
        end
        
        % SelectedVariableTypes setter
        function set.SelectedVariableTypes(ds, svarTypes)
            try
                svarTypes = convertStringsToChars(svarTypes);
                validateSelectedVariableTypes(ds, svarTypes);
            catch ME
                throw(ME);
            end
        end
        
        % ReadSize setter
        function set.ReadSize(ds, readSize)
            try
                readSize = convertStringsToChars(readSize);
                validateReadSize(ds, readSize);
            catch ME
                throw(ME);
            end
        end
        
        % Files getter
        function files = get.Files(ds)
            files = ds.Splitter.Files;
        end
        
        % Sheets getter
        function sheets = get.Sheets(ds)
            sheets = ds.PrivateSheets;
        end
        
        % Range getter
        function range = get.Range(ds)
            range = ds.PrivateRange;
        end
        
        % NumHeaderLines getter
        function hdrLines = get.NumHeaderLines(ds)
            hdrLines = ds.PrivateNumHeaderLines;
        end
        
        % ReadVariableNames getter
        function readVarNames = get.ReadVariableNames(ds)
            readVarNames = ds.PrivateReadVariableNames;
        end
        
        % VariableNames getter
        function varNames = get.VariableNames(ds)
            varNames = ds.PrivateVariableNames;
        end
        
        % VariableTypes getter
        function varTypes = get.VariableTypes(ds)
            varTypes = ds.PrivateVariableTypes;
        end
        
        % SelectedVariableNames getter
        function sVarNames = get.SelectedVariableNames(ds)
            if isempty(ds.VariableNames)
                sVarNames = {};
            else
                sVarNames = ds.VariableNames(ds.SelectedVariableNamesIdx);
            end
        end
        
        % SelectedVariableTypes getter
        function sVarTypes = get.SelectedVariableTypes(ds)
            if isempty(ds.VariableTypes)
                sVarTypes = {};
            else
                sVarTypes = ds.VariableTypes(ds.SelectedVariableNamesIdx);
            end
        end
        
        % ReadSize getter
        function readSize = get.ReadSize(ds)
            readSize = ds.PrivateReadSize;
        end

    end
    
    % super class methods implemented.
    methods
        data = preview(ds);
        tf = hasdata(ds);
        reset(ds);
        subds = partition(ds, partitionStrategy, partitionIndex);
        n = numpartitions(ds, varargin);
        sheetNames = sheetnames(ds, fileNameOrIdx);
    end
    
    methods (Static, Hidden, Access = 'private')
        sheetObj = getSheetObject(bookObj, sheets);
        rangeVector = getRangeVector(sheetObj, range);
    end
    
    methods (Access = 'private')
        
        introspectFile(ds);
        data = convertReaderData(ds, numRowsToRead);
        
        function rdOpts = getBasicReadOpts(~, bookObj, sheetObj, readVarNames, txtType)
            rdOpts.file = bookObj;
            rdOpts.sheet = sheetObj;
            rdOpts.readVarNames = readVarNames;
            rdOpts.basic = true;
            rdOpts.treatAsEmpty = '';
            rdOpts.datetimeType = 'datetime';
            rdOpts.logicalType  = 'char';
            rdOpts.textType = txtType;
        end

        function initSheetProperties(ds, resStruct)
        %INITSHEETPROPERTIES Initialize the SpreadsheetDatastore properties
                    
            % imports
            import matlab.io.datastore.internal.validators.validateVarsTypes;
            import matlab.io.spreadsheet.internal.createWorkbook;
            
            % deal with VariableNames, VariableTypes,
            % SelectedVariableNames, SelectedVariableTypes later in
            % introspectFile.
            fieldsToRemove = {'VariableNames', 'VariableTypes', ...
                              'SelectedVariableNames', 'SelectedVariableTypes'};

            % validate the above fields for types and create a struct
            % (PrivateSheetFormatInfo) with these fields. This is useful
            % during re-introspection as this holds the values passed
            % during construction.
            for field_index = 1 : length(fieldsToRemove)
                field = fieldsToRemove{field_index};
                fieldValue = validateVarsTypes(resStruct.(field), field, true, resStruct.UsingDefaults);
                sheetformatInfo.(field) = fieldValue;
            end
            sheetformatInfo.TextType = resStruct.TextType;
            
            % remove the fields which have already been used up
            fieldsToRemove = [fieldsToRemove {'UsingDefaults', ...
                                   'IncludeSubfolders', 'FileExtensions', 'TextType'}];

            % save this struct for use in introspectFile, update resStruct
            ds.PrivateSheetFormatInfo = sheetformatInfo;
            resStruct = rmfield(resStruct, fieldsToRemove);
            
            % set the rest of the SpreadsheetDatastore properties.
            ds.Sheets = resStruct.Sheets;
            ds.Range = resStruct.Range;
            ds.NumHeaderLines = resStruct.NumHeaderLines;
            ds.ReadVariableNames = resStruct.ReadVariableNames;
            ds.ReadSize = resStruct.ReadSize;
            ds.AlternateFileSystemRoots = resStruct.AlternateFileSystemRoots;
        end
        
        function validateFiles(ds, files)
        %VALIDATEFILES Validates the Files.
        %   This function validates Files and is guaranteed to be called
        %   after datastore construction.
        
            % imports
            import matlab.io.datastore.splitter.SpreadsheetSplitter;
            import matlab.io.datastore.SpreadsheetDatastore;
            import matlab.io.datastore.internal.validators.validatePaths;
            import matlab.io.datastore.internal.indexOfFirstFolderOrWildCard;            
                        
            % ensure the given paths are valid strings or cell array of
            % strings
            files = validatePaths(files);
            
            % get the appended or modifled file list
            appendedPaths = setdiff(files, ds.Files, 'stable');
            
            % get the index of the first string which is a folder or
            % contains a wildcard
            idx = indexOfFirstFolderOrWildCard(appendedPaths);
            
            % error for folder or wild card inputs
            if (-1 ~= idx)
                error(message('MATLAB:datastoreio:filebaseddatastore:nonFilePaths', appendedPaths{idx}));
            end
            
            % cache the previous splitter, first file, VariableNames,
            % VariableTypes, SelectedVariableNames, SelectedVariableTypes
            prevSplitter = ds.Splitter;
            prevFiles = ds.Splitter.Files;
            if ~isempty(prevFiles)
                prevFirstFile = prevFiles{1};
                varNames = ds.VariableNames;
                varTypes = ds.VariableTypes;
                sVarNames = ds.SelectedVariableNames;
                sVarTypes = ds.SelectedVariableTypes;
            end

            try
                % setup the splitter
                ds.Splitter = SpreadsheetSplitter.create(files);
                
                % introspect the file
                introspectFile(ds);
                
                % reset the datastore as splitter changed
                reset(ds);
            catch ME
                % any exception here must restore the splitter, book, sheet
                % and range vector.
                ds.Splitter = prevSplitter;
                throw(ME);
            end
            
            % reset VariableNames, VariableTypes, SelectedVariableNames,
            % SelectedVariableTypes only when the current files and the
            % previous files are non-empty and they are identical.
            currFiles = ds.Files;
            if ~isempty(currFiles) && ~isempty(prevFiles)
                currFirstFile = ds.Files{1};
                if strcmp(currFirstFile, prevFirstFile)
                    ds.VariableNames = varNames;
                    ds.VariableTypes = varTypes;
                    ds.SelectedVariableNames = sVarNames;
                    ds.SelectedVariableTypes = sVarTypes;
                end
            end
        end
        
        function validateSheets(ds, sheetNamesOrNumbers)
        %VALIDATESHEETS Validates the sheets.
        
            % imports
            import matlab.io.internal.validators.isString;
            import matlab.io.internal.validators.isCellOfStrings;
            import matlab.io.datastore.SpreadsheetDatastore;
            
            % early return if files are empty
            if isempty(ds.Files)
                return;
            end

            bookObj = ds.BookObject;
            sheetNames = bookObj.SheetNames;

            % sheets can be a numeric vector
            if isnumeric(sheetNamesOrNumbers)
                try
                    validateattributes(sheetNamesOrNumbers, {'numeric'}, {'positive', 'integer', 'row'});
                catch ME
                    error(message('MATLAB:datastoreio:spreadsheetdatastore:invalidSheets', ds.Files{1}));
                end

                % sheet numbers must be unique
                if numel(sheetNamesOrNumbers) ~= numel(unique(sheetNamesOrNumbers))
                    error(message('MATLAB:datastoreio:spreadsheetdatastore:invalidSheets', ds.Files{1}));
                end

                numSheets = numel(sheetNames);

                % sheet numbers muse be <= number of sheets
                if ~all(arrayfun(@(x) x <= numSheets, sheetNamesOrNumbers))
                    error(message('MATLAB:datastoreio:spreadsheetdatastore:invalidSheets', ds.Files{1}));
                end
            elseif isString(sheetNamesOrNumbers)
                % sheets provided must match the sheet names in the file
                if ~isempty(sheetNamesOrNumbers) && ~ismember(sheetNamesOrNumbers, sheetNames)
                    error(message('MATLAB:spreadsheet:book:openSheetName', sheetNamesOrNumbers));
                end
            else
                % sheets must be cell array of strings
                if ~isCellOfStrings(sheetNamesOrNumbers)
                    error(message('MATLAB:datastoreio:spreadsheetdatastore:invalidSheets', ds.Files{1}));
                end

                % sheets provided must match the sheet names in the file
                lia = ismember(sheetNamesOrNumbers, sheetNames);
                if ~all(lia)
                    error(message('MATLAB:datastoreio:spreadsheetdatastore:invalidSheetNames', sheetNamesOrNumbers{find(~lia,1)}, ds.Files{1}));
                end

                % sheet names cannot contain repeats.
                if numel(cellstr(sheetNamesOrNumbers)) ~= numel(unique(cellstr(sheetNamesOrNumbers)))
                    error(message('MATLAB:datastoreio:spreadsheetdatastore:invalidSheets', ds.Files{1}));
                end
            end

            % setup sheet object only before construction, after
            % construction it is setup automatically in introspectFile.m
            if ~ds.ConstructionDone
                ds.SheetObject = SpreadsheetDatastore.getSheetObject(bookObj, sheetNamesOrNumbers);
            end
            
            % reinitialize the datastore by introspection
            reInit(ds, 'PrivateSheets', sheetNamesOrNumbers, true);
        end
        
        function validateRange(ds, range)
        %VALIDATERANGE Validates the Range.
        
            % imports
            import matlab.io.internal.validators.isString;
            import matlab.io.datastore.SpreadsheetDatastore;
            
            % early return if files are empty
            if isempty(ds.Files)
                return;
            end
            
            sheetObj = ds.SheetObject;
            
            % early return for empty range
            if isString(range) && isempty(range)
                ds.RangeVector = SpreadsheetDatastore.getRangeVector(sheetObj, range);
                reInit(ds, 'PrivateRange', range, true);
                return;
            end

            try
                % get the range type for validation and throw custom
                % exception on error
                [~, rangetype] = sheetObj.getRange(range, false);
            catch
                error(message('MATLAB:datastoreio:spreadsheetdatastore:inValidRange'));
            end

            switch rangetype
                case {'named', 'single-cell', 'row-only'}
                    error(message('MATLAB:datastoreio:spreadsheetdatastore:inValidRange'));
            end

            % set the RangeVector which is used during introspeciton.
            if ~ds.ConstructionDone
                ds.RangeVector = SpreadsheetDatastore.getRangeVector(sheetObj, range);
            end

            % reinitialize the datastore by introspection
            reInit(ds, 'PrivateRange', range, true);
        end

        function validateNumHeaderLines(ds, numHdrLines)
        %VALIDATENUMHEADERLINES Validates the number of header lines.
            try
                validateattributes(numHdrLines, {'numeric'}, ...
                                     {'scalar', 'nonnegative', 'integer'});
            catch ME
                error(message('MATLAB:datastoreio:spreadsheetdatastore:invalidNumHeaderLines'));
            end
        
            % reinitialize the datastore by introspection
            reInit(ds, 'PrivateNumHeaderLines', numHdrLines, true);
        end
        
        function validateReadVariableNames(ds, readVarNames)
        %VALIDATEREADVARIABLENAMES Validates ReadVariableNames to be logical.
        
            % imports
            import matlab.io.datastore.internal.validators.isNumLogical;
            
            % check for logical
            if ~isNumLogical(readVarNames)
                error(message('MATLAB:datastoreio:spreadsheetdatastore:invalidLogical', ...
                                                     'ReadVariableNames'));
            end
            
            % reinitialize the datastore by introspection
            reInit(ds, 'PrivateReadVariableNames', ...
                                              logical(readVarNames), true);
        end
        
        function validateVariableNames(ds, varNames)
        %VALIDATEVARIABLENAMES Validates the Variable Names
        
            % imports   
            import matlab.io.datastore.internal.validators.validateVarsTypes;

            if ds.ConstructionDone
                % validate variable names
                varNames = validateVarsTypes(varNames, 'VariableNames');
            
                % make valid variable names (valid and unique)
                varNames = matlab.internal.tabular.makeValidVariableNames(varNames, 'warn');
                
                % size of VariableNames must match size of VariableTypes
                if numel(varNames) ~= numel(ds.VariableTypes)
                    error(message('MATLAB:datastoreio:tabulartextdatastore:varFormatMismatch', ...
                                        'VariableNames', 'VariableTypes'));
                end
            end
            
            % no introspection on setting VariableNames
            ds.PrivateVariableNames = varNames;            
        end
        
        function validateVariableTypes(ds, varTypes)
        %VALIDATEFORMATS Validates the VariableTypes
        
            % imports
            import matlab.io.datastore.internal.validators.validateVarsTypes;
            import matlab.io.datastore.SpreadsheetDatastore;
            
            if ds.ConstructionDone
                % validate formats
                varTypes = validateVarsTypes(varTypes, 'VariableTypes');
                
                % number of variable names must match the number of formats
                if numel(varTypes)~= numel(ds.VariableNames)
                    error(message('MATLAB:datastoreio:tabulartextdatastore:varFormatMismatch', ...
                                        'VariableNames', 'VariableTypes'));
                end                
            end
            
            % must be one of the supported types
            if ~all(ismember(varTypes, SpreadsheetDatastore.SUPPORTED_TYPES))
                error(message('MATLAB:datastoreio:spreadsheetdatastore:unSupportedType', 'VariableTypes'));
            end
            
            ds.PrivateVariableTypes = varTypes;
        end
        
        function validateSelectedVariableNames(ds, sVarNames)
        %VALIDATESELECTEDVARIABLENAMES Validates the SelectedVariableNames
        
            % imports
            import matlab.io.datastore.TabularTextDatastore;
            import matlab.io.datastore.internal.validators.validateVarsTypes;
            import matlab.io.datastore.internal.validators.validateSizeOfSelectedVariableNames;
            
            if ds.ConstructionDone
                % validate SelectedVariableNames
                sVarNames = validateVarsTypes(sVarNames, 'SelectedVariableNames');
            end

            % Validate the size of SelectedVariableNames against VariableNames
            locb = validateSizeOfSelectedVariableNames(sVarNames, ds.VariableNames);
            
            % set the SelectedFormats based on SelectedVariableNamesIdx
            ds.SelectedVariableNamesIdx = locb;
        end
        
        function validateSelectedVariableTypes(ds, sVarTypes)
        %VALIDATESELECTEDVARIABLETYPES Validates the SelectedVariableTypes
        
            % imports
            import matlab.io.datastore.SpreadsheetDatastore;
            import matlab.io.datastore.internal.validators.validateVarsTypes;

            if ds.ConstructionDone                
                sVarTypes = validateVarsTypes(sVarTypes, 'SelectedVariableTypes');
            end

            % lengths have to match
            if length(ds.SelectedVariableNames) ~= length(sVarTypes)
                error(message('MATLAB:datastoreio:tabulartextdatastore:varFormatMismatch', ...
                              'SelectedVariableTypes', 'SelectedVariableNames'));
            end
            
            % must be one of the supported types
            if ~all(ismember(sVarTypes, SpreadsheetDatastore.SUPPORTED_TYPES))
                error(message('MATLAB:datastoreio:spreadsheetdatastore:unSupportedType', 'SelectedVariableTypes'));
            end
            
            varsUsedIdx = ds.SelectedVariableNamesIdx;
            ds.PrivateVariableTypes(varsUsedIdx) = sVarTypes;
        end
        
        function validateReadSize(ds, readSize)
        %VALIDATEREADVARIABLENAMES Validates ReadSize to be either a
        %postive interger or the strings 'file' or 'sheet'
        
            % imports
            import matlab.io.internal.validators.isString;
            import matlab.io.datastore.SpreadsheetDatastore;
            import matlab.io.spreadsheet.internal.createWorkbook;
            
            % cache the previous value only if introspection is done
            if ds.ConstructionDone
                prevReadSize = ds.ReadSize;
            end
            
            % flag to reset the datastore
            resetFlag = false;
            
            % validate readSize for 'file' or 'sheet' or a positive integer
            if isString(readSize) && strcmpi(readSize, SpreadsheetDatastore.READSIZE_FILE)
                if ds.ConstructionDone && ~strcmpi(prevReadSize, SpreadsheetDatastore.READSIZE_FILE)
                    resetFlag = true;
                end
                readSize = SpreadsheetDatastore.READSIZE_FILE;
            elseif isString(readSize) && strcmpi(readSize, SpreadsheetDatastore.READSIZE_SHEET)
                if ds.ConstructionDone && ~strcmpi(prevReadSize, SpreadsheetDatastore.READSIZE_SHEET)
                    resetFlag = true;
                end
                readSize = SpreadsheetDatastore.READSIZE_SHEET;
            else
                try
                    validateattributes(readSize, {'numeric'}, ...
                                        {'scalar', 'positive', 'integer'});
                catch
                    error(message('MATLAB:datastoreio:spreadsheetdatastore:invalidReadSize'));                    
                end
            
                if ds.ConstructionDone && ~isnumeric(prevReadSize)
                    resetFlag = true;                    
                end
            end
            
            % set the private property
            ds.PrivateReadSize = readSize;
            
            % early return if construction is not done
            if ~ds.ConstructionDone
                return;
            end
            
            % we only reset when we ReadSize changes between supported
            % options
            if ~resetFlag
                return;
            end

            % we only create workbook, sheet objects with non-empty files
            if isEmptyFiles(ds)
                return;
            end

            try
                fmt = matlab.io.spreadsheet.internal.getExtension(ds.Files{1});

                % set up book, sheet and range using the first file
                bookObj = createWorkbook(fmt, ds.Files{1});
                sheetObj = SpreadsheetDatastore.getSheetObject(bookObj, ds.Sheets);
                rangeVec = SpreadsheetDatastore.getRangeVector(sheetObj, ds.Range);
                
                % reset
                reset(ds);
            catch ME
                ds.PrivateReadSize = prevReadSize;
                throw(ME);
            end
            
            % setup the datastores book, sheet and range objects
            ds.BookObject = bookObj;
            ds.SheetObject = sheetObj;
            ds.RangeVector = rangeVec;
        end
        
        function completeConstruction(ds)
        %COMPLETECONSTRUCTION this fucntion is responsible to convey to
        %certain properties that construction of the datastore is complete
        
                % flag to prevent re-initializing during every set
                ds.ConstructionDone = true;
                
                % set the PrivateVarFormatStruct fields to empty as they
                % should not be used for re-introspeciton
                ds.PrivateSheetFormatInfo.VariableNames = {};
                ds.PrivateSheetFormatInfo.VariableTypes = {};
                ds.PrivateSheetFormatInfo.SelectedVariableNames = {};
                ds.PrivateSheetFormatInfo.SelectedVariableTypes = {};
                ds.PrivateSheetFormatInfo.TextType = 'char';
        end
                    
        function reInit(ds, propName, propVal, flagToRead)
        %REINIT reinitializes the datastore.
        %   This function is used to reinitialize the datastore when some
        %   of the public properties change. We decide to re-introspect the
        %   file based on flagToRead. This also restores the datastore to a
        %   stable state if anything goes wrong in the re-introspection.
            
            % save stable state values
            prevPropVal = ds.(propName);
            ds.(propName) = propVal;

            if ~ds.ConstructionDone
                return
            end
            
            % this part of the code is executed only after datastore
            % construction
            if flagToRead
                try
                    % introspects the first file, this sets up book, sheet,
                    % range for the datastore only if introspection
                    % succeeds.
                    introspectFile(ds);
                    
                    % reset the datastore
                    reset(ds);
                catch ME
                    ds.(propName) = prevPropVal;
                    throw(ME);
                end
            end
        end

        function structToDatastore(ds, inStruct)
        %STRUCTTODATASTORE Set the struct fields to the datastore properties
        %   This is a private helper which assigns the struct field values to the
        %   datastore properties.
            field_list = fields(inStruct);
            for field_index = 1: length(field_list)
                field = field_list{field_index};
                ds.(field) = inStruct.(field);
            end
        end
    end
    
    methods (Static, Hidden)
        % supportsLocation for SpreadsheetDatastore
        function varargout = supportsLocation(loc, nvStruct)
            % This function is responsible for determining whether a given
            % location is supported by SpreadsheetDatastore. It also returns
            % a resolved filelist and the appropriate file sizes.
            defaultExtensions = {'.xls', '.xlsx', '.xlsm', '.xltm', '.xltx'};
            [varargout{1:nargout}] = matlab.io.datastore.FileBasedDatastore.supportsLocation(loc, nvStruct, defaultExtensions);
        end

        function ds = loadobj(ds)
            %LOADOBJ Control how SpreadsheetDatastore loads from a mat file.
            import matlab.io.datastore.SpreadsheetDatastore;
            switch class(ds)
                case 'struct'
                    ds = SpreadsheetDatastore.loadFromStruct(ds);
            end
            if isprop(ds, 'SchemaVersion')
                if isequal(ds.SchemaVersion, SpreadsheetDatastore.SCHEMA_16B)
                    % Save load between 16b versions need splitter recreated.
                    import matlab.io.datastore.splitter.SpreadsheetSplitter;
                    ds.Splitter = SpreadsheetSplitter.createFromSplits(ds.Splitter.Splits);
                elseif isequal(ds.SchemaVersion, [])
                    % loading 16a version (SchemaVersion introduced in 16b).
                    % TextType property and a respective field is introduced
                    % to PRIVATESHEETFORMATINFO in 16b.
                    ds.PrivateSheetFormatInfo.TextType = '';
                end
            end
            % Setup transient objects BookObject and SheetObject in reset
            if ~isEmptyFiles(ds)
                % create a split reader that points to the
                % first split index.
                if ds.SplitIdx == 0
                    ds.SplitIdx = 1;
                end
                % create a stub reader so copy() works fine as it expects
                % a non empty datastore to have a reader.
                ds.SplitReader = ds.Splitter.createReader(ds.SplitIdx);
            end

            % Need to start from the beginning to read data.
            ds.IsDataAvailableToConvert = false;
            % Need BookObject created for the first file.
            ds.IsFirstFileBook = false;
            % superclass loadobj
            ds = loadobj@matlab.io.datastore.FileBasedDatastore(ds);
            replaceUNCPaths(ds);
        end
    end
     methods (Static, Access = private)
        function ds = loadFromStruct(inStruct)
            %LOADFROMSTRUCT Set the struct fields to the datastore properties
            %   This is a private helper which assigns the struct field values to the
            %   datastore properties.
            ds = spreadsheetDatastore({});
            % Setting up the datastore.
            inSplitter = inStruct.Splitter;
            inAlternateFileSystemRoots = inStruct.AlternateFileSystemRoots;
            inStruct = rmfield(inStruct, {'AlternateFileSystemRoots', 'Splitter'});
            field_list = fields(inStruct);
            for field_index = 1: length(field_list)
                field = field_list{field_index};
                ds.(field) = inStruct.(field);
            end
            import matlab.io.datastore.splitter.SpreadsheetSplitter;
            ds.Splitter = SpreadsheetSplitter.createFromSplits(inSplitter.Splits);
            c = onCleanup(@()defaultSetFromLoadObj(ds));
            ds.SetFromLoadObj = true;
            ds.AlternateFileSystemRoots = inAlternateFileSystemRoots;
        end
    end
    methods (Hidden)
        % return true if the splits of this datastore are file at a time
        function tf = areSplitsWholeFile(ds)
            tf = ds.Splitter.isFullFileSplitter();
        end

        % return true if the splits of this datastore span the all files
        % in the Files property in their entirety (non-paritioned)
        function tf = areSplitsOverCompleteFiles(ds)
            tf = ds.Splitter.isSplitsOverAllOfFiles();
        end
    end
    
    % protected methods
    methods (Access = 'protected')
        function copiedObj = copyElement(obj)
            % copy using parent
            copiedObj = copyElement@matlab.io.datastore.FileBasedDatastore(obj);
            % Need BookObject created for each copy.
            copiedObj.IsFirstFileBook = false;
        end

        function displayScalarObject(ds)
            %DISPLAYSCALAROBJECT controls the display of the datastore.
            import matlab.io.internal.cellArrayDisp;
            import matlab.io.internal.validators.isString;

            % header
            header = matlab.mixin.CustomDisplay.getSimpleHeader(ds);
            disp(header);

            % File Properties
            filesIndent = '                      Files: ';
            nFilesIndent = sprintf(repmat(' ',1,numel(filesIndent)));
            if isempty(ds.Files)
                nFilesIndent = '';
            end
            filesStrDisp = cellArrayDisp(ds.Files, true, nFilesIndent);
            disp([filesIndent, filesStrDisp]);
            
            if isempty(ds.AlternateFileSystemRoots)
                altRootsDisp = '{}';
            else
                altRootsDisp = char(join(string(size(ds.AlternateFileSystemRoots)), 'x'));
                altRootsDisp = ['{' altRootsDisp ' cell}'];
            end
            disp(['   ', 'AlternateFileSystemRoots: ', altRootsDisp]);
            % Sheets
            sheets = ds.Sheets;
            if isString(sheets)
                disp(['    ', '                 Sheets: ''' , sheets, '''']);
            elseif isnumeric(sheets)
                if numel(sheets) == 1
                    disp(['    ', '                 Sheets: ' , num2str(sheets), '']);
                else
                    disp(['    ', '                 Sheets: ', '[', num2str(sheets), ']']);
                end
            else
                sheetsStrDisp = cellArrayDisp(sheets, false, '');
                disp(['    ', '                 Sheets: ', sheetsStrDisp]);
            end
            
            % Range
            disp(['    ', '                  Range: ''' , ds.Range, '''']);
            fprintf('\n');
            
            % Sheet Format Properties            
            sheetPropsTitle = getString(message('MATLAB:datastoreio:spreadsheetdatastore:sheetProperties'));
            disp(['  ', sheetPropsTitle]);
            
            % NumHeaderLines
            disp(['    ', '         NumHeaderLines: ', num2str(ds.NumHeaderLines)]);
            
            % ReadVariableNames
            if ds.ReadVariableNames
                disp(['    ', '      ReadVariableNames: ', 'true']);    
            else
                disp(['    ', '      ReadVariableNames: ', 'false']);
            end
            
            % VariableNames
            varNamesDisp = cellArrayDisp(ds.VariableNames, false, '');
            disp(['    ', '          VariableNames: ', varNamesDisp]);
            
            % VariableTypes
            varTypesDisp = cellArrayDisp(ds.VariableTypes, false, '');
            disp(['    ', '          VariableTypes: ', varTypesDisp]);
            
            fprintf('\n');

            % Returned Table Properties
            if feature('hotlinks')
                previewLink = '<a href="matlab: help(''matlab.io.datastore.SpreadsheetDatastore\preview'')">preview</a>';
                readLink = '<a href="matlab: help(''matlab.io.datastore.SpreadsheetDatastore\read'')">read</a>';
                readallLink = '<a href="matlab: help(''matlab.io.datastore.SpreadsheetDatastore\readall'')">readall</a>';
                retrievalPropsTitle = getString(message('MATLAB:datastoreio:spreadsheetdatastore:retrievalPropertiesWithLinks', ...
                                      previewLink, readLink, readallLink));
            else
                retrievalPropsTitle = getString(message('MATLAB:datastoreio:tabulartextdatastore:retrievalProperties'));
            end
            
            disp(['  ', retrievalPropsTitle]);
            
            % SelectedVariableNames
            sVarNamesDisp = cellArrayDisp(ds.SelectedVariableNames, false, '');
            disp(['    ', '  SelectedVariableNames: ', sVarNamesDisp]);

            % SelectedVariableTypes
            sVarTypesDisp = cellArrayDisp(ds.SelectedVariableTypes, false, '');
            disp(['    ', '  SelectedVariableTypes: ', sVarTypesDisp]);

            % TextType
            %disp(['    ', '               TextType: ''', ds.TextType '''']);

            % ReadSize
            if isString(ds.ReadSize)
                disp(['    ', '               ReadSize: ''', ds.ReadSize, '''']);
            else
                disp(['    ', '               ReadSize: ', getString(message('MATLAB:datastoreio:spreadsheetdatastore:rowsString', num2str(ds.ReadSize)))]);
            end
            fprintf('\n');
        end

        % readData method protected declaration.
        [t, info] = readData(ds);

        % readAllData method protected declaration.
        t = readAllData(ds);

    end
end

function txtType = validateTextType(txtType)
    try
        txtType = validatestring(txtType, {'char', 'string'});
    catch
        error(message('MATLAB:spreadsheet:sheet:invalidTextType'));
    end
end

function resStruct = parseSpreadsheetInputs(varargin)
%PARSESPREADSHEETINPUTS parses the input arguments.
%   This function returns a struct containing the parsed Name-Value pairs
%   along with the ones which have default values. No validation of the
%   parameters is done in this function.
    
    persistent pSheet;
    if isempty(pSheet)
        % imports
        import matlab.io.datastore.SpreadsheetDatastore;
        import matlab.io.datastore.mixin.CrossPlatformFileRoots;
        
        pSheet = inputParser;
        
        % setting up the function name for error messages
        pSheet.FunctionName = 'datastore';
        
        % adding name-value pairs
        addParameter(pSheet, 'Sheets', '');
        addParameter(pSheet, 'Range', '');
        
        addParameter(pSheet, 'NumHeaderLines', 0);
        addParameter(pSheet, 'ReadVariableNames', true);
        addParameter(pSheet, 'VariableNames', {});
        addParameter(pSheet, 'VariableTypes', {});
        
        addParameter(pSheet, 'SelectedVariableNames', {});
        addParameter(pSheet, 'SelectedVariableTypes', {});
        addParameter(pSheet, 'ReadSize', SpreadsheetDatastore.READSIZE_FILE);
        addParameter(pSheet, 'TextType', 'char');
        
        addParameter(pSheet, 'IncludeSubfolders', false);
        addParameter(pSheet, 'FileExtensions', -1);
        addParameter(pSheet, CrossPlatformFileRoots.ALTERNATE_FILESYSTEM_ROOTS_NV_NAME, CrossPlatformFileRoots.DEFAULT_ALTERNATE_FILESYSTEM_ROOTS);
    end
    
    % parse the input
    parse(pSheet, varargin{:});
    resStruct = pSheet.Results;
    resStruct.UsingDefaults = pSheet.UsingDefaults;
    resStruct.TextType = validateTextType(resStruct.TextType);
end
