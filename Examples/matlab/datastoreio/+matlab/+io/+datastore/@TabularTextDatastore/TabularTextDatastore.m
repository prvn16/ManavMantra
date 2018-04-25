classdef (Sealed) TabularTextDatastore < ...
                  matlab.io.datastore.FileBasedDatastore & ...
                  matlab.io.datastore.TabularDatastore & ...
                  matlab.io.datastore.mixin.HadoopFileBasedSupport & ...
                  matlab.io.datastore.mixin.CrossPlatformFileRoots & ...
                  matlab.io.datastore.internal.ScalarBase & ...
                  matlab.mixin.CustomDisplay
%TABULARTEXTDATASTORE Datastore for a collection of tabular text files.
%   TDS = tabularTextDatastore(LOCATION) creates a TabularTextDatastore
%   based on a tabular text file or a collection of such files in LOCATION.
%   LOCATION has the following properties:
%      - Can be a filename or a folder name
%      - Can be a cell array or string vector of multiple file or folder names
%      - Can contain a relative path
%      - Can contain a wildcard (*) character
%      - All of the files in LOCATION must have the extension .csv, .txt,
%        .dat, .dlm, .asc, .text or have no file extension
%
%   TDS = tabularTextDatastore(__,'IncludeSubfolders',TF) specifies the
%   logical true or false to indicate whether the files in each folder and
%   its subfolders are included recursively or not.
%
%   TDS = tabularTextDatastore(__,'FileExtensions',EXTENSIONS) specifies
%   the extensions of files to be included in the TabularTextDatastore. The
%   extensions are not required to be either .csv, .txt, .dat, .dlm, .asc,
%   or .text. Values for EXTENSIONS can be:
%      - A character vector or a string scalar, such as '.txt' or '.csv' or
%        '.myformat' (empty quotes '' are allowed for files without extensions)
%      - A cell array of character vectors or a string vector, such as
%        {'.csv', '.txt', '.myformat'}
%
%   TDS = tabularTextDatastore(__,'AlternateFileSystemRoots',ALTROOTS) specifies
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
%   TDS = tabularTextDatastore(__,'DatetimeType',DATETIMETYPE) specifies the
%   output type of datetime formatted data. When TextscanFormats is provided and
%   contains a %D, this option is ignored.
%   DATETIMETYPE can be either of the following values:
%       'datetime' - Return datetime as output of datetime formatted data (Default).
%       'text'     - Return text as output of datetime formatted data. The output is
%                    a character vector if TextType property is 'char' or a string if
%                    TextType property is 'string'.
%
%   TDS = tabularTextDatastore(__,'Name1',Value1,'Name2',Value2,...) specifies the
%   properties of TDS using optional name-value pairs.
%
%   TabularTextDatastore Methods:
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
%
%   TabularTextDatastore Properties:
%
%   Files                    - Files included in datastore.
%   FileEncoding             - Character encoding scheme.
%   AlternateFileSystemRoots - Alternate file system root paths for the Files.
%   ReadVariableNames        - Indicator for reading first row of first file as variable names.
%   VariableNames            - Names of variables.
%   NumHeaderLines           - Number of lines to skip at beginning of file.
%   Delimiter                - Field delimiter characters.
%   RowDelimiter             - Row delimiter character.
%   TreatAsMissing           - Values to treat as missing values.
%   MissingValue             - Value for missing numeric fields.
%   TextscanFormats          - Format of the data fields.
%   ExponentCharacters       - Exponent characters.
%   CommentStyle             - Comment Style.
%   Whitespace               - White-space characters.
%   MultipleDelimitersAsOne  - Multiple delimiter handling.
%   SelectedVariableNames    - Variables to read.
%   SelectedFormats          - Formats for selected variables.
%   ReadSize                 - Upper limit on the size of the data returned by the read method.
%   TextType                 - Select the return datatype for all text data.
%
%   Example:
%   --------
%      % Create a TabularTextDatastore
%      tabds = tabularTextDatastore('airlinesmall.csv')
%      % Handle erroneous data
%      tabds.TreatAsMissing = 'NA';
%      tabds.MissingValue = 0;
%      % We are only interested in the Arrival Delay data
%      tabds.SelectedVariableNames = 'ArrDelay'
%      % Preview the first 8 rows of the data as a table
%      tab8 = preview(tabds)
%      % Sum the Arrival Delays
%      sumAD = 0;
%      while hasdata(tabds)
%         tab = read(tabds);
%         sumAD = sumAD + sum(tab.ArrDelay);
%      end
%      sumAD
%
%   See also datastore, mapreduce, readtable, textscan, tabularTextDatastore.

%   Copyright 2014-2017 The MathWorks, Inc.

    % exposed dependent public properties
    properties (Dependent)
        %FILES A cell array of character vectors of tabular text files. You 
        %can also set this property using a string array.
        %   Files included in the datastore, specified as a cell array of
        %   character vectors, where each character vector is a full path
        %   to a file. You can also set this property using a string array.
        %   These are the files defined by the location argument to the
        %   datastore function. The first file specified by the Files property
        %   determines the variable names and format information for all
        %   files in the datastore.
        Files;
        
        %FILEENCODING Character encoding scheme
        %   Character encoding scheme associated with the file, specified
        %   as a character vector. All the file encodings supported in the data
        %   import area can be provided as inputs.
        FileEncoding;
        
        %READVARIABLENAMES Indicator for reading first row of first file as variable names.
        %   Indicator for reading first row of the first file in the
        %   datastore as variable names, specified as either true (1) or
        %   false (0). If true, then the first non-header row of the first
        %   file determines the variable names for the data. If false, then
        %   the first non-header row of the first file contains the first
        %   row of data, and the data is assigned default variable names,
        %   Var1, Var2, and so on.
        ReadVariableNames;
        
        %VARIABLENAMES Names of variables.
        %   Names of variables in the datastore, specified as a character
        %   vector or a cell array of character vectors. Specify the variable
        %   names in the order in which they appear in the files. If you do
        %   not specify the variable names, they are detected from the first
        %   non-header line in the first file in the datastore. When
        %   modifying the VariableNames property, the number of new
        %   variable names must match the number of original variable
        %   names.
        VariableNames;
        
        %NUMHEADERLINES Number of lines to skip at beginning of file.
        %   Number of lines to skip at the beginning of the file, specified
        %   as a positive integer. datastore ignores the specified number
        %   of header lines before reading the variable names or data.
        NumHeaderLines;
        
        %DELIMITER Field delimiter characters.
        %   Field delimiter characters, specified as a character vector or
        %   a cell array of character vectors. You can also specify this
        %   property as a string array. Specify multiple delimiters in a 
        %   cell array of strings.
        Delimiter;
        
        %ROWDELIMITER Row delimiter character.
        %   Row delimiter character, specified as a character vector or a
        %   scalar string. The string must be a single character or one of
        %   the strings, '\r', '\n', or '\r\n'. The default end-of-line
        %   sequence depends on the format of your file.
        RowDelimiter;
        
        %TREATASMISSING Values to treat as missing values.
        %   Numeric values to treat as missing values, specified as a
        %   single character vector or cell array of character vectors.
        %   This option only applies to numeric fields.
        TreatAsMissing;
        
        %MISSINGVALUE Value for missing numeric fields.
        %   Value for missing numeric fields in delimited text files,
        %   specified as a scalar.
        MissingValue;
        
        %TEXTSCANFORMATS Format of the data fields.
        %   Format of the data fields, specified as a cell array of
        %   character vectors, where each character vector contains one 
        %   conversion specifier. When you specify or modify the 
        %   TextscanFormats property, you can use the same conversion 
        %   specifiers that the textscan function accepts, including 
        %   specifiers that skip fields using an asterisk (*) character and
        %   specifiers that skip literal text. The number of conversion 
        %   specifiers must match the number of variables in the VariableNames
        %   property. If the value of TextscanFormats includes conversion
        %   specifiers that skip fields using asterisk characters (*), then
        %   the value of the SelectedVariableNames property automatically 
        %   updates. If you do not specify a value for TextscanFormats, then
        %   datastore determines the format of the data fields by scanning
        %   text from the first file in the datastore.
        %
        %   See also, TextType
        TextscanFormats;
        
        %EXPONENTCHARACTERS Exponent characters.
        %   Exponent characters, specified as a character vector. The default
        %   exponent characters are e, E, d, and D.
        ExponentCharacters;
        
        %COMMENTSTYLE Comment Style.
        %   Comment style in the file, specified as a character vector or 
        %   cell array of character vectors. You can also set this property
        %   using a scalar array. For example, specify a string such as '%'
        %   to ignore characters following the string on the same line. 
        %   Specify a cell array of two strings, such as {'/*', '*/'}, to 
        %   ignore characters between the strings. When reading from a
        %   TabularTextDatastore, the read function checks for comments
        %   only at the start of each field, not within a field.
        CommentStyle;
        
        %WHITESPACE White-space characters.
        %   White-space characters, specified a character vector of one or
        %   more characters.
        Whitespace;
        
        %MULTIPLEDELIMITERSASONE Multiple delimiter handling.
        %   Multiple delimiter handling, specified as either true or false.
        %   If true, then datastore treats consecutive delimiters as a
        %   single delimiter. Repeated delimiters separated by white-space
        %   are also treated as a single delimiter.
        MultipleDelimitersAsOne;
        
        %SELECTEDVARIABLENAMES Variables to read.
        %   Variables to read from the file, specified as a character vector
        %   or a cell array of character vectors, where each character vector
        %   contains the name of one variable. You can specify the variable
        %   names in any order. You can also set this property using a
        %   string array.
        SelectedVariableNames;
        
        %SELECTEDFORMATS Formats for selected variables.
        %   Formats of the variables to read, specified as a cell array of
        %   character vectors, where each character vector contains one 
        %   conversion specifier. The variables to read are indicated by the
        %   SelectedVariableNames property. The number of character vectors
        %   in SelectedFormats must match the number of variables to read.
        %   You can use the same conversion specifiers that the textscan
        %   function accepts, including specifiers that skip literal text.
        %   However, you cannot use a conversion specifier that skips a
        %   field. That is, the conversion specifier cannot include an
        %   asterisk character (*).
        SelectedFormats;
        
        %READSIZE Upper limit on the size of the data returned by the read method.
        %   This property controls the size of the data returned by the
        %   read method. This property could be X rows, where X is the
        %   upper limit on the number of rows returned by the read method,
        %   or 'file', which indicates full file reading.
        ReadSize;
        
    end

    properties (SetAccess = 'private', Dependent)
        %TEXTTYPE The output type of text data.
        %   This property controls the output of %s, %q, and %[...] formats. It can have
        %   either of the following values:
        %       'char'   - Return text as a cell array of character vectors.
        %       'string' - Return text as a string array.
        %
        % See Also TextscanFormats
        TextType;
    end
    
    % private concrete properties for public Dependent properties
    properties (Access = 'private')        
        PrivateReadVariableNames;
        PrivateVariableNames;
        PrivateNumHeaderLines;
        PrivateDelimiter = '';
        PrivateTreatAsMissing;
        PrivateMissingValue;
        PrivateTextscanFormats;
        PrivateExponentCharacters;
        PrivateCommentStyle;
        PrivateWhitespace = '';
        PrivateMultipleDelimitersAsOne;
        PrivateSelectedFormats;
        PrivateReadSize;
        PrivateTextType = 'char';
        % properties added to support detection
        PrivateDelimiterSupplied;
        PrivateNumHeaderLinesSupplied;
        PrivateReadVariableNamesSupplied;
        PrivateMultipleDelimitersAsOneSupplied;
    end
    
    % internally used private properties
    properties (Access = 'private')
        %DATETIMETYPE The output type of datetime data.
        %   This property controls the output of datetime formatted data.
        %   When TextscanFormats is provided and contains a %D, this option
        %   is ignored.
        %   It can have either of the following values:
        %       'datetime' - Return datetime as output of datetime formatted data (Default).
        %       'text'     - Return text as output of datetime formatted data. The output is
        %                    a character vector if TextType property is 'char' or a string if
        %                    TextType property is 'string'.
        %
        % See Also TextscanFormats
        DatetimeType;
        
        %DURATIONTYPE The output type of time data.
        %   This property controls the output of time formatted data.
        %   When TextscanFormats is provided and contains a %T, this option
        %   is ignored.
        %   It can have either of the following values:
        %       'duration' - Return duration as output of time formatted data (Default).
        %       'text'     - Return text as output of time formatted data. The output is
        %                    a character vector if TextType property is 'char' or a string if
        %                    TextType property is 'string'.
        %
        % See Also TextscanFormats
        DurationType;

        %SELECTEDVARIABLENAMESIDX Logical Indices of SelectedVariableNames
        SelectedVariableNamesIdx;
        
        %INTROSPECTIONDONE Boolean to indicate if introspection is done
        %   This property controls the manner in which we re-introspect
        IntrospectionDone = false;
        
        %PRIVATEVARFORMATSTRUCT Struct to hold Variable and Format Info
        %   This is struct which holds variable name and format information
        %   as it was passed during construction. We use this information
        %   during re-introspection to populate the VariableNames,
        %   TextscanFormats, SelectedVariableNames, SelectedFormats.
        PrivateVarFormatStruct;
        
        %TEXTSCANFORMATASCELLSTR indicates if formats are passed as cellstr
        %   This property is used to indicate if formats are passed in as
        %   cells vs strings. This controls the manner in which we parse
        %   TextscanFormats
        TextscanFormatsAsCellStr = true;
        
        %UNRESOLVEDFILES property to store the un-resolved files
        %   This property is used to store the un-resolved files so that
        %   deployment modes can directly pass it to hadoop.
        UnResolvedFiles
        
        % To help support future forward compatibility. The value indicates
        % the version of MATLAB.
        SchemaVersion = 9.3;
    end
    
    % READ STATE RELATED PROPERTIES %
    properties (Transient, Access = 'private')
        %NUMCHARACTERSREADINCHUNK number of characters read in the chunk
        %   This property denotes the number of characters read in the
        %   current chunk that is available for conversion.
        NumCharactersReadInChunk = 0;
        
        %CURRBUFFER buffer to hold characters read
        %   This property is used to hold the transient buffer of
        %   characters that eventually are passed to TEXTSCAN. Always
        %   contains whole lines.
        CurrBuffer = '';
        
        %CURRSPLITINFO current split info being used
        %   This property holds the current split's information.
        CurrSplitInfo = [];
    end% READ STATE RELATED PROPERTIES %
    
    properties (Constant, Access = 'private')
        DEFAULT_PREVIEW_LINES = 8;
        DEFAULT_TEXTSCAN_STRING = 'datastore';
        DEFAULT_SKIP_FORMAT = '%*q';
        DEFAULT_READSIZE = 20000;
        READSIZE_FILE = 'file';
        DEFAULT_PEEK_SIZE = 100*1024; % 100KB
        DEFAULT_DETECTION_SIZE = 4*1024*1024; % 4MB
        RETURN_ON_ERROR = false;
        % max buffer size we use to detect variable names and formats, this
        % is also the chunksize we use currently for TabularTextDatastore.
        BUFFER_UPPERLIMIT = 32*1024*1024; % 32MB
        % max buffer size we use for hadoop tabular text files.
        HADOOP_BUFFER_UPPERLIMIT = 64*1024*1024; % 64MB
        SCHEMA_14B = 8.3;
        SCHEMA_15A = 8.4;
    end

    % constructor
    methods
        function ds = TabularTextDatastore(files, varargin)
            try
                % imports
                import matlab.io.datastore.TabularTextDatastore;

                % string adoption - convert all NV pairs specified as
                % string to char
                files = convertStringsToChars(files);
                [varargin{:}] = convertStringsToChars(varargin{:});

                % parse datastore properties
                resStruct = parseTextInputs(varargin{:});

                % get the list of resolved files
                [~, files, fileSizes] = TabularTextDatastore.supportsLocation(files, resStruct);

                ds.ReadSize = resStruct.ReadSize;

                % initialize the splitter and the splitreader using files,
                % file encoding and the row delimiter. We use fileSizes to
                % check if we need to re-resolve files.
                initSplitInfo(ds, files, resStruct.FileEncoding, ...
                                                   resStruct.RowDelimiter, fileSizes);

                % check if whitespace is passed during construction
                isWhitespaceUsingDefault = ismember('Whitespace', ...
                                                      resStruct.UsingDefaults);

                % handle delimiter and whitespace issues during construction
                [delim, whitespace] = ...
                    TabularTextDatastore.handleDelimWhitespaceConflicts(resStruct.Delimiter, ...
                           resStruct.Whitespace, isWhitespaceUsingDefault);

                % set the delimiter and whitespace
                ds.Delimiter = delim;
                ds.Whitespace = whitespace;

                % the below properties have already been setup
                resStruct = rmfield(resStruct, {'RowDelimiter', ...
                                                'ReadSize', 'FileEncoding', ...
                                                'Delimiter', 'Whitespace', ...
                                                'IncludeSubfolders', 'FileExtensions'});

                % initialize the rest of TabularTextDatastore properties.
                initTextProperties(ds, resStruct);

                % introspect the file
                introspectFile(ds);

                % flag to prevent re-initializing during every set
                ds.IntrospectionDone = true;
            catch ME
                throwAsCaller(ME);
            end
        end
    end
    
    % setter's and getter's
    methods
        % Files setter
        function set.Files(ds, files)
            try
                validateFiles(ds, files);
            catch ME
                throw(ME);
            end
        end
        
        % FileEncoding setter
        function set.FileEncoding(ds, fileEncoding)
            try
                fileEncoding = convertStringsToChars(fileEncoding);
                validateFileEncoding(ds, fileEncoding);
            catch ME
                throw(ME);
            end
        end
        
        % ReadVariableNames setter
        function set.ReadVariableNames(ds, readVarNames)
            try
                supplied = ds.PrivateReadVariableNamesSupplied;
                ds.PrivateReadVariableNamesSupplied = true;
                validateReadVariableNames(ds, readVarNames);
            catch ME
                ds.PrivateReadVariableNamesSupplied = supplied;
                throw(ME);
            end
        end
        
        % VariableNames setter
        function set.VariableNames(ds, varNames)            
            try
                [varNames{:}] = convertStringsToChars(varNames{:});
                validateVariableNames(ds, varNames);
            catch ME
                throw(ME);
            end
        end
        
        % NumHeaderLines setter
        function set.NumHeaderLines(ds, numHdrLines)
            try
                supplied = ds.PrivateNumHeaderLinesSupplied;
                ds.PrivateNumHeaderLinesSupplied = true;
                validateNumHeaderLines(ds, numHdrLines);
            catch ME
                ds.PrivateNumHeaderLinesSupplied = supplied;
                throw(ME);
            end
        end
        
        % Delimiter setter
        function set.Delimiter(ds, delim)            
            try
                supplied = ds.PrivateDelimiterSupplied;
                ds.PrivateDelimiterSupplied = true;
                delim = convertStringsToChars(delim);
                validateDelimiter(ds,delim);
            catch ME
                ds.PrivateDelimiterSupplied = supplied;
                throw(ME);
            end
        end
        
        % RowDelimiter setter
        function set.RowDelimiter(ds,rowDelim)            
            try
                rowDelim = convertStringsToChars(rowDelim);
                validateAndSetRowDelimiter(ds,rowDelim);
            catch ME
                throw(ME);
            end
        end
        
        % TreatAsMissing setter
        function set.TreatAsMissing(ds, treatAsMissing)            
            try
                treatAsMissing = convertStringsToChars(treatAsMissing);
                validateTreatAsMissing(ds, treatAsMissing);
            catch ME
                throw(ME);
            end            
        end
        
        % MissingValue setter
        function set.MissingValue(ds, missingVal)
            try
                missingVal = convertStringsToChars(missingVal);
                validateMissingValue(ds, missingVal);
            catch ME
                throw(ME);
            end            
        end
        
        % TextscanFormats setter
        function set.TextscanFormats(ds, formats)            
             try
                 formats = convertStringsToChars(formats);
                 validateTextscanFormats(ds, formats);
            catch ME
                throw(ME);
             end
        end
        
        % ExponentCharacters setter
        function set.ExponentCharacters(ds, expChars)
            try
                expChars = convertStringsToChars(expChars);
                validateExponentCharacters(ds, expChars);
            catch ME
                throw(ME);
            end            
        end
        
        % CommentStyle setter
        function set.CommentStyle(ds, commentStyle)
            try
                commentStyle = convertStringsToChars(commentStyle);
                validateCommentStyle(ds, commentStyle);
            catch ME
                throw(ME);
            end
        end
        
        % Whitespace setter
        function set.Whitespace(ds, whitespace)
            try
                whitespace = convertStringsToChars(whitespace);
                validateWhitespace(ds,whitespace);
            catch ME
                throw(ME);
            end
        end
        
        % MultipleDelimitersAsOne setter
        function set.MultipleDelimitersAsOne(ds, mDelimsAsOne)
            try
                supplied = ds.PrivateMultipleDelimitersAsOneSupplied;
                ds.PrivateMultipleDelimitersAsOneSupplied = true;
                validateMultipleDelimitersAsOne(ds,mDelimsAsOne);
            catch ME
                ds.PrivateMultipleDelimitersAsOneSupplied = supplied;
                throw(ME);
            end
        end
        
        % SelectedVaribleNames setter
        function set.SelectedVariableNames(ds, sVarNames)
            try
                sVarNames = convertStringsToChars(sVarNames);
                validateSelectedVariableNames(ds, sVarNames);
            catch ME
                throw(ME);
            end
        end
        
        % SelectedFormats setter
        function set.SelectedFormats(ds,fmtSpec)
            try
                fmtSpec = convertStringsToChars(fmtSpec);
                validateSelectedFormats(ds, fmtSpec);
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
        
        % hold the unskipped SelectedFormats
        function set.PrivateSelectedFormats(ds, formats)
            import matlab.io.datastore.TabularTextDatastore;
            ds.PrivateSelectedFormats = unSkipFormats(formats);
        end
        
        % TextType setter
        function set.TextType(ds,type)
            try
                type = convertStringsToChars(type);
                ds.PrivateTextType = validatestring(type, {'char', 'string'});
            catch
                error(message('MATLAB:textscan:TextType'));
            end
            
        end

        % Files getter
        function files = get.Files(ds)
            files = ds.Splitter.Files;
        end
        
        % FileEncoding getter
        function fileEncoding = get.FileEncoding(ds)
            fileEncoding = ds.Splitter.FileEncoding;
        end
        
        % ReadVariableNames getter
        function readVarNames = get.ReadVariableNames(ds)
            readVarNames = ds.PrivateReadVariableNames;
        end
        
        % VariableNames getter
        function allVars = get.VariableNames(ds)
            allVars = ds.PrivateVariableNames;
        end
        
        % NumHeaderLines getter
        function numHdrLines = get.NumHeaderLines(ds)
            numHdrLines = ds.PrivateNumHeaderLines;
        end
        
        % Delimiter getter
        function delim = get.Delimiter(ds)
            delim = ds.PrivateDelimiter;
        end
        
        % RowDelimiter getter
        function rowDelim = get.RowDelimiter(ds)
            rowDelim = ds.Splitter.EOR;
        end
        
        % TreatAsMissing getter
        function treatAsMissing = get.TreatAsMissing(ds)
            treatAsMissing = ds.PrivateTreatAsMissing;
        end
        
        % MissingValue getter
        function missingValue = get.MissingValue(ds)
            missingValue = ds.PrivateMissingValue;
        end
        
        % TextscanFormats getter
        function textScanFormats = get.TextscanFormats(ds)
            textScanFormats = ds.PrivateTextscanFormats;
        end
        
        % ExponentCharacters getter
        function expChars = get.ExponentCharacters(ds)
            expChars = ds.PrivateExponentCharacters;
        end
        
        % CommentStyle getter
        function commentStyle = get.CommentStyle(ds)
            commentStyle = ds.PrivateCommentStyle;
        end
        
        % Whitespace getter
        function whitespace = get.Whitespace(ds)
            whitespace = ds.PrivateWhitespace;
        end
        
        % MultipleDelimitersAsOne getter
        function mDelimsAsOne = get.MultipleDelimitersAsOne(ds)
            mDelimsAsOne = ds.PrivateMultipleDelimitersAsOne;
        end
        
        % SelectedVariableNames getter
        function sVarNames = get.SelectedVariableNames(ds)
            if isempty(ds.VariableNames)
                sVarNames = {};
            else
                sVarNames = ds.VariableNames(ds.SelectedVariableNamesIdx);
            end
        end
        
        % SelectedFormats getter
        function fmtSpec = get.SelectedFormats(ds)
            if isempty(ds.PrivateSelectedFormats)
                fmtSpec = {};
            else
                fmtSpec = ds.PrivateSelectedFormats(ds.SelectedVariableNamesIdx);
            end
        end
        
        % ReadSize getter
        function readSize = get.ReadSize(ds)
            readSize = ds.PrivateReadSize;
        end
        
        % TextType getter
        function type = get.TextType(ds)
            type = ds.PrivateTextType;
        end
    end
    
    % super class methods implemented.
    methods
        data = preview(ds);        
        reset(ds);
        subds = partition(ds, partitionStrategy, partitionIndex);
        n = numpartitions(ds, varargin);
    end
    
    % static methods for tabulartextdatastore
    methods (Static, Access = 'private')        
        [outCellStr, outputLog] = concatLiteral(inStr, strOrCellStrFlag);
        inCellStr = skipFormats(inCellStr);        
    end
    
    % private methods
    methods (Access = 'private')
        % function responsible to populate variable names and formats
        introspectFile(ds);
        
        % method for conversion from text to tables.
        [tData, tInfo, nbytes] = convertReaderData(ds, readerData, readerInfo, ...
                 readSize, fmts, txtScanArgs, prevNumCharsRead, nCharsBeforeData, calcbytes);
    end
    
    % protected methods
    methods (Access = 'protected')
        % this allows for non-standard display for datastore object.
        displayScalarObject(ds);

        % readData method protected declaration.
        [data, info] = readData(ds);

        % readAllData method protected declaration.
        data = readAllData(ds);

    end    
    
    methods (Hidden)
        % functionality for deployment to get unresolved files.
        function files = getUnresolvedFiles(ds)
            files = ds.UnResolvedFiles;
        end
        
        % return true if the splits of this datastore are file at a time
        function tf = areSplitsWholeFile(ds)
            tf = ds.Splitter.isFullFileSplitter();
        end

        % return true if the splits of this datastore span the all files
        % in the Files property in their entirety (non-paritioned)
        function tf = areSplitsOverCompleteFiles(ds)
            tf = ds.Splitter.isSplitsOverAllOfFiles();
        end

        % progress for datastore
        function frac = progress(ds)
            % after a fresh reset, we are at split 1 which has not yet been
            % read, so account for splits by asking if the reader has read
            % them
            readerHasData = hasNext(ds.SplitReader);
            numSplits = ds.Splitter.NumSplits;
            hasBuffer = ~isempty(ds.CurrBuffer);
            frac = (ds.SplitIdx - readerHasData - hasBuffer)/numSplits;
            if hasBuffer
                currSplit = ds.Splitter.Splits(ds.SplitIdx);
                fracRead = (ds.CurrSplitInfo.Offset - currSplit.Offset)/currSplit.Size;
                frac = frac + fracRead/numSplits;
            end
            frac = min(frac, 1.0);
        end
        
        % initialize this datastore given filename, offset and size to read
        % this is specifically used when initializing a hadoop split. we
        % also support non-utf8 encodings with hadoop.
        function initFromFileSplit(ds, filename, offset, len)
            import matlab.io.datastore.TabularTextDatastore;
            import matlab.io.datastore.splitter.TextFileSplitter;
            splits = TextFileSplitter.createBasicSplitsWithMaxSplitSize(filename, offset, len, TabularTextDatastore.HADOOP_BUFFER_UPPERLIMIT);
            ds.Splitter = ds.Splitter.createCopyWithSplits(splits);
            reset(ds);
        end
    end
    
    methods (Static, Hidden)
        %LOADOBJ controls custom loading from a mat file.
        function ds = loadobj(ds)
            
            import matlab.io.datastore.TabularTextDatastore;
            
            if isstruct(ds) && ~isfield(ds, 'SchemaVersion')
                % this must be a 14b datastore
                ds = TabularTextDatastore.loadFromStruct(ds, TabularTextDatastore.SCHEMA_14B);
            elseif isequal(ds.SchemaVersion, TabularTextDatastore.SCHEMA_15A)
                % this must be a 15a datastore
                ds = TabularTextDatastore.loadFromStruct(ds, TabularTextDatastore.SCHEMA_15A);
            elseif isstruct(ds) && isequal(ds.SchemaVersion, 9.3)
                ds = TabularTextDatastore.loadFrom18aStruct(ds);
            end
            
            % superclass loadobj
            ds = loadobj@matlab.io.datastore.FileBasedDatastore(ds);
            replaceUNCPaths(ds);
        end
    end
    
    methods (Static, Hidden)
        % supportsLocation for TabularTextDatastore  
        function varargout = supportsLocation(loc, nvStruct)
            % This function is responsible for determining whether a given
            % location is supported by TabularTextDatastore. It also returns
            % a resolved filelist and the appropriate file sizes.
            defaultExtensions = { '.txt', '.csv', '.dat', '.dlm', '.asc', '.text', ''};
            [varargout{1:nargout}] = matlab.io.datastore.FileBasedDatastore.supportsLocation(loc, nvStruct, defaultExtensions);
        end
    end

    methods (Access = 'private')
        
        function args = getTextscanArgs(ds)
        %GETTEXTSCANARGS convert stored parameters to name-value pairs for textscan
            
            args = {'Delimiter', ds.Delimiter, ...
                    'EmptyValue', ds.MissingValue, ...
                    'ExpChars', ds.ExponentCharacters, ...
                    'ReturnOnError', matlab.io.datastore.TabularTextDatastore.RETURN_ON_ERROR, ...
                    'Whitespace', ds.Whitespace, ...
                    'EndOfLine', ds.RowDelimiter, ...
                    'TreatAsEmpty', ds.TreatAsMissing, ...
                    'CommentStyle', ds.CommentStyle, ...
                    'MultipleDelimsAsOne', ds.MultipleDelimitersAsOne,...
                    'TextType', ds.PrivateTextType};
        end
        
        function initSplitInfo(ds, files, fileEncoding, rowDelim, fileSizes)
        %INITSPLITINFO initializes the splitter and the splitreader.
        %   This function is used to setup the splitter and the splitreader
        %   for TabularTextDatastore and resets it.

            % setup the TextFileSplitter and the RowDelimiter
            setUpSplitter(ds, files, fileEncoding, rowDelim, fileSizes);

            % reset the datastore
            reset(ds);
        end
        
        function validateReadSize(ds, readSize)
        %VALIDATEREADSIZE Validates ReadSize.
        
            % imports
            import matlab.io.internal.validators.isString;
            import matlab.io.datastore.TabularTextDatastore;
        
            % cache the previous value only if introspection is done
            if ds.IntrospectionDone
                prevReadSize = ds.ReadSize;
            end

            % flag to reset the datastore
            resetFlag = false;

            % validate readSize for 'file' or a positive integer
            if isString(readSize) && strcmpi(readSize, TabularTextDatastore.READSIZE_FILE)
                if ds.IntrospectionDone && ~isString(prevReadSize)
                    resetFlag = true;
                    % ask the splitter to use full file splits
                    ds.Splitter.useFullFile(true);
                end
                readSize = TabularTextDatastore.READSIZE_FILE;
            else
                try
                    validateattributes(readSize, {'numeric'}, ...
                                        {'scalar', 'positive', 'integer'});
                catch
                    error(message('MATLAB:datastoreio:tabulartextdatastore:invalidReadSize'));                    
                end
            
                if ds.IntrospectionDone && ~isnumeric(prevReadSize)
                    resetFlag = true;
                    % ask the splitter to NOT use full file splits
                    ds.Splitter.useFullFile(false);
                end
            end
            
            % set the ReadSize
            ds.PrivateReadSize = readSize;
            
            % reset if ReadSize changed from string to number or vice versa
            if resetFlag
                try
                    reset(ds);                    
                catch
                    % set the prev ReadSize
                    ds.PrivateReadSize = prevReadSize;
                    
                    % change to using the correct split size based on
                    % ReadSize
                    ds.Splitter.useFullFile(~isnumeric(ds.ReadSize));                    
                end
            end
        end
        
        function setUpSplitter(ds, files, fileEncoding, rowDelim, fileSizes)
        %SETUPSPLITTER Sets up the splitter on the datastore.
        %   This function is responsible to setup the splitter on the
        %   datastore using Files, FileEncoding and the ReadSize
        %   properties.
        
            % imports
            import matlab.io.datastore.splitter.TextFileSplitter;
            import matlab.io.datastore.TabularTextDatastore;
            
            % default file sizes when not passed in
            if nargin < 5
                fileSizes = [];
            end
            
            % set up splitter based on files, readsize and file encoding.
            if ~isnumeric(ds.ReadSize)
                ds.Splitter = ...
                         TextFileSplitter.create(files, Inf, fileEncoding, rowDelim, fileSizes);
            else
                ds.Splitter = TextFileSplitter.create(files, ...
                     TabularTextDatastore.BUFFER_UPPERLIMIT, fileEncoding, rowDelim, fileSizes);
            end
            
            % setting UnResolvedFiles for deployment usecase, expects a
            % cell
            ds.UnResolvedFiles = cellstr(files);
        end
        
        function validateAndSetRowDelimiter(ds, rowDelim)
        %VALIDATEANDSETROWDELIMITER validates and sets the row delimiter
        %   This function is responsible for validating a given row
        %   delimiter and setting the datastore object with the validated
        %   row delimiter.
        
            % cache the previous SplitReader if introspection is done
            if ds.IntrospectionDone
                prevSplitReader = ds.SplitReader;
                prevEOR = ds.Splitter.EOR;
            end
    
            % tabtext RowDelim is dependent on TextFileSplitter RowDelim
            ds.Splitter.EOR = rowDelim;

            if ds.IntrospectionDone                
                try
                    % introspect
                    introspectFile(ds);
            
                    % reset as splitter got modified
                    reset(ds);
                catch ME
                    % any exception must restore the splitReader and
                    % splitter's eor
                    ds.SplitReader = prevSplitReader;
                    ds.Splitter.EOR = prevEOR;
                    throw(ME);
                end
            end
        end
        
        function initTextProperties(ds, resStruct)
        %INITTEXTPROPERTIES Initializes the datastore text properties.
            
            % imports
            import matlab.io.datastore.internal.validators.validateVarsTypes;
            
            % TextscanFormats are treated differently when passed in as
            % strings vs cell array of strings, this boolean controls that
            % behaviour.
            if ischar(resStruct.TextscanFormats)
                ds.TextscanFormatsAsCellStr = false;
            end
            
            % deal with variable names and format properties in
            % introspectFile.m
            fieldsToRemove = {'VariableNames', 'TextscanFormats', ...
                               'SelectedVariableNames', 'SelectedFormats'};
            
            % create a struct with variable names and formats
            % (PrivateVarFormatStruct). This is useful during
            % re-introspection as this holds the values passed during
            % construction.
            for field_index = 1 : length(fieldsToRemove)
                field = fieldsToRemove{field_index};
                fieldValue = validateVarsTypes(resStruct.(field), field, true, resStruct.UsingDefaults);
                varFormatStruct.(field) = fieldValue;
            end
            
            notsupplied = ~ismember({'Delimiter','NumHeaderLines','ReadVariableNames','MultipleDelimitersAsOne'},resStruct.UsingDefaults);

            % no longer need UsingDefaults cell
            fieldsToRemove = [fieldsToRemove 'UsingDefaults'];
            
            % set the private struct with variable names and format information.
            ds.PrivateVarFormatStruct = varFormatStruct;

            ds.DatetimeType = validatestring(resStruct.DatetimeType, {'datetime', 'text'});
            ds.DatetimeType = validatestring(resStruct.DurationType, {'duration', 'text'});

            % set the rest of the textdatastore properties.
            resStruct = rmfield(resStruct, fieldsToRemove);
            structToDatastore(ds, resStruct);
            % Supplied Parameters used for reintrospection.
            ds.PrivateDelimiterSupplied = notsupplied(1);
            ds.PrivateNumHeaderLinesSupplied = notsupplied(2);
            ds.PrivateReadVariableNamesSupplied = notsupplied(3);
            ds.PrivateMultipleDelimitersAsOneSupplied = notsupplied(4);
        end
        
        function validateFiles(ds, files)
        %VALIDATEFILES Validates the Files.
        %   This function validates Files and is guaranteed to be called
        %   after datastore construction.
        
            % imports
            import matlab.io.datastore.splitter.TextFileSplitter;
            import matlab.io.datastore.TabularTextDatastore;
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
            
            % cache the old splitter, the first file, VariableNames and
            % TextscanFormats only after introspection is done and when
            % files are non-empty
            prevSplitter = ds.Splitter;
            prevFiles = ds.Splitter.Files;
            if ~isempty(prevFiles)
                prevFirstFile = prevFiles{1};
                varNames = ds.VariableNames;
                formats = ds.TextscanFormats;
            end
            
            try
                % setup the splitter
                setUpSplitter(ds, files, ds.FileEncoding, ds.RowDelimiter);
                
                % introspect, does not change props if it errors
                introspectFile(ds);
                
                % reset the datastore as splitter changed
                reset(ds);
            catch ME
                % any exception here must reset the splitter
                ds.Splitter = prevSplitter;
                throw(ME);
            end
            
            % reset the VariableNames and TextscanFormats only when the
            % current files and the previous files are non-empty and they
            % are identical
            currFiles = ds.Files;
            if ~isempty(currFiles) && ~isempty(prevFiles)
                currFirstFile = ds.Files{1};
                if strcmp(currFirstFile, prevFirstFile)
                    ds.VariableNames = varNames;
                    ds.TextscanFormats = formats;
                end
            end
        end
        
        function validateFileEncoding(ds, fileEncoding)
        %VALIDATEFILEENCODING validates the File Encoding.
        %   this function validates the file encoding and sets up the
        %   splitter based on file encoding. This function is guaranteed to
        %   be called after introspection.
        
            % cache the previous encoding
            prevFileEncoding = ds.FileEncoding;
            
            try
                % this could change splitSize being used
                ds.Splitter.FileEncoding = fileEncoding;
                
                % ensure SplitSize is Inf if ReadSize is 'file'
                if ~isnumeric(ds.ReadSize)
                    ds.Splitter.useFullFile(true);
                end
                
                % introspect with the new datastore
                introspectFile(ds);
                
                % FileEncoding resets the datastore
                reset(ds);
            catch ME
                % set the previous file encoding
                ds.Splitter.FileEncoding = prevFileEncoding;
                
                % ensure SplitSize is Inf if ReadSize is 'file'
                if ~isnumeric(ds.ReadSize)
                    ds.Splitter.useFullFile(true);
                end
                
                throw(ME);
            end
        end
        
        function validateTextscanFormats(ds, formats)
        %VALIDATEFORMATS Validates the TextscanFormats
        
            % imports
            import matlab.io.datastore.internal.validators.validateVarsTypes;
            import matlab.io.datastore.TabularTextDatastore;
            
            % validate formats
            formats = validateVarsTypes(formats, 'TextscanFormats');
            
            % check if the given specifiers are valid
            [formats, skippedVec] = TabularTextDatastore.concatLiteral(formats, true);
            
            % all the formats cannot contain skips
            if all(skippedVec)
                error(message('MATLAB:datastoreio:tabulartextdatastore:allSkips'));
            end
            
            % number of variable names must match the number of formats
            if numel(formats)~= numel(ds.VariableNames)
                error(message('MATLAB:datastoreio:tabulartextdatastore:varFormatMismatch', ...
                    'VariableNames', 'TextscanFormats'));
            end
            
            % set the formatspec for textscan
            ds.PrivateTextscanFormats = formats;
            
            % hold the unskipped formats
            ds.PrivateSelectedFormats = formats;
            
            % set the active variable names
            ds.SelectedVariableNames = ds.VariableNames(~skippedVec);
        end
        
        function validateSelectedFormats(ds, fmtSpec)
        %VALIDATEACTIVEFORMATS Validates the Active Formats
        %   This function ensures that the given Active Formats are valid
        %   and sets them accordingly.
        
            % imports
            import matlab.io.datastore.TabularTextDatastore;
            import matlab.io.datastore.internal.validators.validateVarsTypes;

            % validate SelectedFormats
            fmtSpec = validateVarsTypes(fmtSpec, 'SelectedFormats');

            % parse the formats
            [fmtSpec, skippedVec] = TabularTextDatastore.concatLiteral(fmtSpec, true);

            % lengths have to match
            if length(ds.SelectedVariableNames) ~= length(fmtSpec)
                error(message('MATLAB:datastoreio:tabulartextdatastore:varFormatMismatch', ...
                              'SelectedFormats', 'SelectedVariableNames'));
            end
            
            % skips not allowed in SelectedFormats
            if any(skippedVec)
                error(message('MATLAB:datastoreio:tabulartextdatastore:invalidSkips'));
            end
            
            % local vars
            nVars = numel(ds.VariableNames);
            varsUsedIdx = ds.SelectedVariableNamesIdx;
            varsNotUsedIdx = setdiff(1:nVars,varsUsedIdx);
            
            % setting all the private properties for the public getters to work
            ds.PrivateSelectedFormats(varsUsedIdx) = fmtSpec;
            ds.PrivateTextscanFormats(varsUsedIdx) = fmtSpec;
            ds.PrivateTextscanFormats(varsNotUsedIdx) = ...
                            TabularTextDatastore.skipFormats( ...
                                ds.PrivateTextscanFormats(varsNotUsedIdx));
        end
        
        function validateSelectedVariableNames(ds, sVarNames)
        %VALIDATEACTIVEVARIABLENAMES Validates the SelectedVariableNames
        
            % imports
            import matlab.io.datastore.TabularTextDatastore;
            import matlab.io.datastore.internal.validators.validateVarsTypes;
            import matlab.io.datastore.internal.validators.validateSizeOfSelectedVariableNames;

            % validate SelectedVariableNames
            sVarNames = validateVarsTypes(sVarNames, 'SelectedVariableNames');

            % Validate the size of SelectedVariableNames against VariableNames
            locb = validateSizeOfSelectedVariableNames(sVarNames, ds.VariableNames);

            % set the SelectedFormats based on SelectedVariableNamesIdx
            ds.SelectedVariableNamesIdx = locb;
            ds.SelectedFormats = ds.PrivateSelectedFormats(locb);
        end
        
        function validateVariableNames(ds, varNames)
        %VALIDATEVARIABLENAMES Validates the Variable Names
        %   This function ensures that the given variable names are valid
        %   and sets them accordingly.
        
            % imports   
            import matlab.io.datastore.internal.validators.validateVarsTypes;

            % validate variable names
            varNames = validateVarsTypes(varNames, 'VariableNames');
            
            if ds.IntrospectionDone
                % make valid variable names (valid and unique)
                varNames = matlab.internal.tabular.makeValidVariableNames(varNames, 'warn');
            end
            
            % number of variable names must match the number of formats
            if numel(varNames) ~= numel(ds.TextscanFormats)
                error(message('MATLAB:datastoreio:tabulartextdatastore:varFormatMismatch', ...
                                      'VariableNames', 'TextscanFormats'));
            end
            
            % no introspection on setting VariableNames
            ds.PrivateVariableNames = varNames;
        end
        
        function validateCommentStyle(ds, commentStyle)
        %VALIDATECOMMENTSTYLE Validates the Variable Names
        %   This function ensures that the given variable names are valid
        %   and sets them accordingly.
        
            % imports
            import matlab.io.datastore.TabularTextDatastore;

            % using the builtin textscan interface to validate CommentStyle
            try
                builtin('_textscan_interface', ...
                    TabularTextDatastore.DEFAULT_TEXTSCAN_STRING, '%s', ...
                                             'CommentStyle', commentStyle);
            catch ME
                error(message('MATLAB:datastoreio:tabulartextdatastore:invalidCommentStyle'));
            end
            
            % covert to column vectors to row vectors
            commentStyle = commentStyle(:)';
            
            % reinitialize the datastore
            reInit(ds, 'PrivateCommentStyle', commentStyle, true);
        end
        
        function validateDelimiter(ds, delim)
        %VALIDATEDELIMITER Validates the Delimiter
        %   This function is responsible to validate a given Delimiter and
        %   also ensure that the given whitespace characters are not
        %   present in the delimiter list.
        
            % imports
            import matlab.io.datastore.TabularTextDatastore;
            
            if ds.IntrospectionDone
                [delim, whitespace] = ...
                    TabularTextDatastore.handleDelimWhitespaceConflicts(delim, ...
                                                        ds.Whitespace, false);
                % set the whitespace on the private property as we do not
                % want to invoke the setter of whitespace
                ds.PrivateWhitespace = whitespace;
            end
            
            % reinitialize the datastore by introspection
            reInit(ds, 'PrivateDelimiter', delim, true);
        end
        
        function validateWhitespace(ds, whitespace)
        %VALIDATEWHITESPACE Validates the whitespace characters
        %   This function is responsible for validating a given whitespace
        %   character and also ensuring that the given whitespace character
        %   is not present in the delimiter list.
        
            % imports
            import matlab.io.datastore.TabularTextDatastore;
            
            if ds.IntrospectionDone
                [~, whitespace] = ...
                    TabularTextDatastore.handleDelimWhitespaceConflicts(ds.Delimiter, ...
                                                        whitespace, false);
            end
            
            % reinitialize the datastore by introspection
            reInit(ds, 'PrivateWhitespace', whitespace, true);
        end
        
        function validateTreatAsMissing(ds, treatAsMissing)
        %VALIDATETREATASMISSING Validates the TreatAsMissing characters
        %   This function ensures that the given TreatAsMissing characters
        %   are valid and sets them accordingly.

            % imports
            import matlab.io.datastore.TabularTextDatastore;

            % using the builtin textscan interface to validate TreatAsMissing
            try
                builtin('_textscan_interface', ...
                    TabularTextDatastore.DEFAULT_TEXTSCAN_STRING, '%s', ...
                                           'TreatAsEmpty', treatAsMissing);
            catch ME
                error(message('MATLAB:datastoreio:tabulartextdatastore:invalidTreatAsMissing'));
            end
            
            % covert to row vectors
            treatAsMissing = treatAsMissing(:)';
            
            % trim any leading or trailing insignificant whitespace
            treatAsMissing = strtrim(treatAsMissing);
            
            % treatAsEmpty should not contain numeric literals, all the
            % standard ones like ('1') etc are covered in builtin textscan
            % check
            if any(~isnan(str2double(treatAsMissing))) || any(strcmpi('nan', treatAsMissing))
                error(message('MATLAB:datastoreio:tabulartextdatastore:invalidTreatAsMissing'));
            end
            
            % cache the Variablenames and SelectedVariableNames only after
            % introspection. We should not cache TextscanFormats as they
            % can get modified during the course of re-introspection
            if ds.IntrospectionDone
                varNames = ds.VariableNames;
                sVarNames = ds.SelectedVariableNames;
            end
            
            % reinitialize the datastore by introspection
            reInit(ds, 'PrivateTreatAsMissing', treatAsMissing, true);
            
            % reset the VariableNames, SelectedVariableNames as these do
            % not get affected on TreatAsEmpty changes. Only
            % SelectedFormats get affected. Setting SelectedVariableNames
            % sets SelectedFormats using the TreatAsEmpty change
            if ds.IntrospectionDone
                try
                    ds.VariableNames = varNames;
                    ds.SelectedVariableNames = sVarNames;
                catch ME
                    throw(ME);
                end
            end
        end
        
        function validateReadVariableNames(ds, readVarNames)
        %VALIDATEREADVARIABLENAMES Validates ReadVariableNames to be logical.
        
            % imports
            import matlab.io.datastore.internal.validators.isNumLogical;
            
            % check for logical
            if ~isNumLogical(readVarNames)
                error(message('MATLAB:datastoreio:tabulartextdatastore:invalidLogical', ...
                                                     'ReadVariableNames'));
            end
            
            % reinitialize the datastore by introspection
            reInit(ds, 'PrivateReadVariableNames', ...
                                              logical(readVarNames), true);
        end
        
        function validateNumHeaderLines(ds, numHdrLines)
        %VALIDATENUMHEADERLINES Validates the number of header lines.
        %   This function validates the number of header lines and sets the
        %   property accordingly.
        
            % imports
            import matlab.io.datastore.TabularTextDatastore;

            % using the builtin textscan interface to validate header lines.
            try
                builtin('_textscan_interface', ...
                    TabularTextDatastore.DEFAULT_TEXTSCAN_STRING, '%s', ...
                                               'HeaderLines', numHdrLines);
            catch ME
                error(message('MATLAB:datastoreio:tabulartextdatastore:invalidNumHeaderLines'));
            end
            
            % reinitialize the datastore by introspection
            reInit(ds, 'PrivateNumHeaderLines', numHdrLines, true);
        end
        
        function validateMissingValue(ds, missingVal)
        %VALIDATEMISSINGVALUE Validates the missing value
        %   This function ensures that the given MissingValue is valid and sets
        %   them accordingly
        
            % imports
            import matlab.io.datastore.TabularTextDatastore;

            % using the builtin textscan interface to validate EmptyValue
            try
                builtin('_textscan_interface', ...
                    TabularTextDatastore.DEFAULT_TEXTSCAN_STRING, '%s', ...
                                                 'EmptyValue', missingVal);
            catch ME
                error(message('MATLAB:datastoreio:tabulartextdatastore:invalidMissingValue'));
            end
            
            % reinitialize the datastore by introspection
            reInit(ds, 'PrivateMissingValue', missingVal, false);
        end
        
        function validateMultipleDelimitersAsOne(ds, mDelimsAsOne)
        %VALIDATEMULTIPLEDELIMITERSASONE Validates MultipleDelimitersAsOne
        %   This function validates MultipleDelimitersAsOne and sets the property
        %   accordingly.
        
            % imports
            import matlab.io.datastore.TabularTextDatastore;
            
            % using the builtin textscan interface to validate
            % MultipleDelimitersAsOne
            try
                builtin('_textscan_interface', ...
                    TabularTextDatastore.DEFAULT_TEXTSCAN_STRING, '%s', ...
                                      'MultipleDelimsAsOne', mDelimsAsOne);
            catch ME
                error(message('MATLAB:datastoreio:tabulartextdatastore:invalidLogical', ...
                                               'MultipleDelimitersAsOne'));
            end
            
            % reinitialize the datastore by introspection
            reInit(ds, 'PrivateMultipleDelimitersAsOne', ...
                                              logical(mDelimsAsOne), true);
        end
        
        function validateExponentCharacters(ds, expChars)
        %VALIDATEEXPONENTCHARACTERS Validates the ExponentCharacters
        %   This function ensures that the given Exponent Characters are valid and
        %   sets them accordingly.
        
            % imports
            import matlab.io.datastore.TabularTextDatastore;

            % using the builtin textscan interface to validate ExponentCharacters
            try
                builtin('_textscan_interface', ...
                    TabularTextDatastore.DEFAULT_TEXTSCAN_STRING, '%s', ...
                                                     'ExpChars', expChars);
            catch ME
                error(message('MATLAB:datastoreio:tabulartextdatastore:invalidStr', ...
                                                    'ExponentCharacters'));
            end
            
            % reinitialize the datastore by introspection
            reInit(ds, 'PrivateExponentCharacters', expChars, false);
        end
        
        function reInit(ds, propName, propVal, flagToRead)
        %REINIT reinitializes the datastore.
        %   This function is used to reinitialize the datastore when some
        %   of the public properties change. We decided to re-read the file
        %   based on flagToRead. This also restores the datastore to a
        %   stable state if anything goes wrong in the re-read of the file.
        
            % save stable state values
            prevPropVal = ds.(propName);
            ds.(propName) = propVal;

            if ~ds.IntrospectionDone 
                return
            end
            
            % this part of the code is executed only after datastore
            % construction
            if flagToRead
                try
                    % here we try to read with the updated datastore and
                    % revert to original state if we fail.
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
        
            % Setting up the datastore.
            field_list = fields(inStruct);
            for field_index = 1: length(field_list)
                field = field_list{field_index};
                ds.(field) = inStruct.(field);
            end
        end
    end
    
    methods (Static, Access = 'private')
        
        function [currDelim, currWhitespace] = handleDelimWhitespaceConflicts(delim, whitespace, isWhitespaceUsingDefault)
        %HANDLEDELIMWHITESPACECONFLICTS handles delimiter, whitespace
        %conflicts.
        
            % imports
            import matlab.io.datastore.TabularTextDatastore;
            import matlab.internal.datatypes.warningWithoutTrace;            
            
            % using the builtin textscan interface to validate Delimiter
            try
                builtin('_textscan_interface', ...
                    TabularTextDatastore.DEFAULT_TEXTSCAN_STRING, '%s', ...
                                                       'Delimiter', delim);
            catch ME
                error(message('MATLAB:datastoreio:tabulartextdatastore:invalidStrOrCellStr', 'Delimiter'));
            end
            
            % using the builtin textscan interface to validate a whitespace
            try
                builtin('_textscan_interface', ...
                    TabularTextDatastore.DEFAULT_TEXTSCAN_STRING, '%s', ...
                                                 'Whitespace', whitespace);
            catch
                error(message('MATLAB:datastoreio:tabulartextdatastore:invalidStr', ...
                                                            'Whitespace'));
            end
            
            % convert delim to row vectors
            delim = delim(:)';
            
            % wrapping all strings into a cell array of strings. This is
            % done because of the following behavior: ';,' is treated as
            % {';', ','} instead of {';,'} by textscan
            if ischar(delim) && numel(sprintf(delim)) > 1
                delim = {delim};
            end
            
            if isWhitespaceUsingDefault
                % turn of the conflict warning if default whitespace is used
                warnState = warning('off', 'MATLAB:textscan:DelimiterSpaceConflict');
            else
                % just turn off the trace
                warnState = warning('off', 'backtrace');
            end
            
            % remove delimiter from the whitespace list if there are collisions.
            nvPairStruct = builtin('_textscan_interface', ...
                    TabularTextDatastore.DEFAULT_TEXTSCAN_STRING, '%s', ...
                             'Delimiter', delim, 'Whitespace', whitespace);
                         
            % restore the warning state
            cleanup = onCleanup(@() warning(warnState));
        
            currWhitespace = nvPairStruct.Whitespace;
            currDelim = nvPairStruct.Delimiter;
            
            % builtin interface gives unescaped delims, hence we use it.
            % for empty delim '' builtin interface returns 1 by 0 cell,
            % therefore use the delim passed in that case.
            if ischar(delim)
                if isempty(delim)
                    currDelim = delim;
                else
                    currDelim = currDelim{1};
                end
            end
            
            % warn if a space is added at the end to the currWhitespace and
            % the prevWhitespace did not have one
            if ~strcmp(whitespace, currWhitespace)
                if ~any(whitespace == ' ') && numel(sprintf(currWhitespace)) > 1 ...
                                              && currWhitespace(end) == ' '
                    warningWithoutTrace(message('MATLAB:datastoreio:tabulartextdatastore:addingSpace'));
                end
            end
        end
        
        function ds = loadFrom18aStruct(inStruct)
            %LOADFROM18ASTRUCT Set the struct fields to the datastore properties
            %   This is a private helper which assigns the struct field values to the
            %   datastore properties.
            ds = tabularTextDatastore({});
            % Setting up the datastore.
            inSplitter = inStruct.Splitter;
            inAlternateFileSystemRoots = inStruct.AlternateFileSystemRoots;
            inStruct = rmfield(inStruct, {'AlternateFileSystemRoots', 'Splitter'});
            field_list = fields(inStruct);
            for field_index = 1: length(field_list)
                field = field_list{field_index};
                ds.(field) = inStruct.(field);
            end
            import matlab.io.datastore.splitter.TextFileSplitter;
            ds.Splitter = TextFileSplitter.createFromSplits(inSplitter.Splits);
            ds.Splitter.EOR = inSplitter.EOR;
            c = onCleanup(@()defaultSetFromLoadObj(ds));
            ds.SetFromLoadObj = true;
            ds.AlternateFileSystemRoots = inAlternateFileSystemRoots;
        end

        function outds = loadFromStruct(ds, schemaVersion)
        %LOADFROMSTRUCT intializes a datastore loaded as a struct correctly.
        
            % imports
            import matlab.io.datastore.splitter.TextFileSplitter;
            import matlab.io.datastore.TabularTextDatastore;
            
            % construct an empty TabularTextDatastore
            outds = TabularTextDatastore({});
            
            % Here we directly set the private concrete properties instead
            % of invoking the public setters to avoid the additional
            % overhead of reset which some of these properties call.
            % Setting the renamed properties.
            if isequal(schemaVersion, TabularTextDatastore.SCHEMA_14B)
                outds.PrivateReadSize = ds.RowsPerRead;
                outds.PrivateSelectedFormats = ds.PrivateActiveFormats;
                outds.SelectedVariableNamesIdx = ds.VarsUsedIdx;
                outds.PrivateTextscanFormats = ds.TxtScanFormatSpec;
                outds.TextscanFormatsAsCellStr = ds.FormatsAsCellStr;
                
            % remove the fields which are already set above and the
            % unwanted fields which have now become transient in 15a
            fieldsToRemove = {'RowsPerRead', 'PrivateActiveFormats', ...
                          'VarsUsedIdx', 'TxtScanFormatSpec', ...
                          'FormatsAsCellStr', 'Splitter', 'SplitReader',...
                          'SkippedFormats', 'ReaderData', 'ReaderInfo', ...
                          'SplitIdx', 'ReturnOnError', 'SizeReadInChunk',...
                          'BytesReadInChunk', 'PrevReadError', ...
                          'DelimChangedWhitespace', 'PrevConvError', ...
                          'PrivateFiles', 'ConversionDone',...
                                                    'PrivateRowDelimiter'};
            else % 15a datastore
                outds.PrivateReadSize = ds.PrivateReadSize;
                outds.PrivateSelectedFormats = ds.PrivateSelectedFormats;
                outds.SelectedVariableNamesIdx = ds.SelectedVariableNamesIdx;
                outds.PrivateTextscanFormats = ds.PrivateTextscanFormats;
                outds.TextscanFormatsAsCellStr = ds.TextscanFormatsAsCellStr;
                
                % remove the fields which are already set above and the
                % unwanted fields which do not exist anymore
                fieldsToRemove = {'PrivateSelectedFormats', 'SelectedVariableNamesIdx', ...
                    'PrivateTextscanFormats', 'TextscanFormatsAsCellStr', ...
                          'Splitter', 'SplitReader','PrivateRowDelimiter'};
            end
            
            % set the splitter, a split added a field called FieldIndex in 15a
            splits = ds.Splitter.Splits;
            
            if ~isempty(splits)
                fileIdx = 1;
                splits(1).FileIndex = fileIdx;
                
                for i = 2:numel(splits)
                    if splits(i).Offset == 0
                        fileIdx = fileIdx + 1;
                    end
                    splits(i).FileIndex = fileIdx;
                end
            end
            
            % set the splitter
            outds.Splitter = TextFileSplitter.createFromSplits(splits);
            outds.Splitter.EOR = ds.PrivateRowDelimiter;
            
            % remove the fields created above
            ds = rmfield(ds, fieldsToRemove);
            
            % use a helper to set the remaining properties
            structToDatastore(outds, ds);
        end
    end
end

function inCellStr = unSkipFormats(inCellStr)
%unSkipFormats removes skips in a cell array of strings.
%   This function is used to remove skips from a format string. This
%   function ensures guards against literals with * in them.

    % already validated cellstr is given
    nFormats = numel(inCellStr);

    for i = 1: nFormats
        formatStr = inCellStr{i};
    
        % create a formatParser struct
        tempStruct = matlab.iofun.internal.formatParser(formatStr);
    
        % check if there is a skipped only format (non-literal)
        skipIdx = tempStruct.IsSkipped & ~tempStruct.IsLiteral;
    
        % do not do anything to unskipped formats
        if ~any(skipIdx)
            continue;
        end
    
        % replace the skipped format with its unskipped version, we search only
        % for the skipped format to make it an unskipped one.
        percentPos = strfind(formatStr,tempStruct.Format{skipIdx});
        formatStr = [formatStr(1:percentPos) formatStr(percentPos + 2:end)];    
        inCellStr{i} = formatStr;
    end
end

function resStruct = parseTextInputs(varargin)
%PARSETEXTINPUTS parses the input arguments.
%   This function returns a struct containing the parsed Name-Value pairs
%   along with the ones which have default values. No validation of the
%   parameters is done in this function.

    persistent pTxt;
    if isempty(pTxt)
        % imports
        import matlab.io.datastore.TabularTextDatastore;
        import matlab.io.datastore.mixin.CrossPlatformFileRoots;

        pTxt = inputParser;
        
        % setting up the function name for error messages
        pTxt.FunctionName = 'datastore';

        % adding name-value pairs
        addParameter(pTxt, 'FileEncoding', 'UTF-8');
        addParameter(pTxt, 'ReadVariableNames', true);
        addParameter(pTxt, 'VariableNames', {});
        addParameter(pTxt, 'NumHeaderLines', 0);
        addParameter(pTxt, 'Delimiter', ',');
        addParameter(pTxt, 'RowDelimiter', '\r\n');
        addParameter(pTxt, 'TreatAsMissing', '');
        addParameter(pTxt, 'MissingValue', NaN);

        addParameter(pTxt, 'TextscanFormats', {});
        addParameter(pTxt, 'ExponentCharacters', 'eEdD');
        addParameter(pTxt, 'CommentStyle', '');
        addParameter(pTxt, 'Whitespace', ' \b\t');
        addParameter(pTxt, 'MultipleDelimitersAsOne', false);

        addParameter(pTxt, 'SelectedVariableNames', {});
        addParameter(pTxt, 'SelectedFormats', {});
        addParameter(pTxt, 'ReadSize', TabularTextDatastore.DEFAULT_READSIZE);
        
        addParameter(pTxt, 'IncludeSubfolders', false);
        addParameter(pTxt, 'FileExtensions', -1);        
        
        addParameter(pTxt, 'TextType', 'char');
        addParameter(pTxt, 'DatetimeType', 'datetime');
        addParameter(pTxt, CrossPlatformFileRoots.ALTERNATE_FILESYSTEM_ROOTS_NV_NAME, CrossPlatformFileRoots.DEFAULT_ALTERNATE_FILESYSTEM_ROOTS);
        addParameter(pTxt, 'DurationType', 'duration');
    end
    
    % parse the input
    parse(pTxt, varargin{:});
    resStruct = pTxt.Results;
    resStruct.UsingDefaults = pTxt.UsingDefaults;
end
