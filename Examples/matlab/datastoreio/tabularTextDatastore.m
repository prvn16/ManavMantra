function ds = tabularTextDatastore(location, varargin)
%TABULARTEXTDATASTORE Datastore for a collection of tabular text files.
%   TDS = tabularTextDatastore(LOCATION) creates a TabularTextDatastore
%   based on a tabular text file or a collection of such files in LOCATION.
%   LOCATION has the following properties:
%      - Can be a filename or a folder name
%      - Can be a cell array of multiple file or folder names
%      - Can contain a relative path
%      - Can contain a wildcard (*) character
%      - All of the files in LOCATION must have the extension .csv, .txt,
%        .dat, .dlm, .asc, .text
%
%   TDS = tabularTextDatastore(__,'IncludeSubfolders',TF) specifies the
%   logical true or false to indicate whether the files in each folder and
%   its subfolders are included recursively or not.
%
%   TDS = tabularTextDatastore(__,'FileExtensions',EXTENSIONS) specifies
%   the extensions of files to be included in the TabularTextDatastore. The
%   extensions are not required to be either .csv, .txt, .dat, .dlm, .asc,
%   or .text. Values for EXTENSIONS can be:
%      - A character vector, such as '.txt' or '.csv' or '.myformat' (empty
%        quotes '' are allowed for files without extensions)
%      - A cell array of character vector, such as {'.csv', '.txt', '.myformat'}
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
%   See also datastore, mapreduce, readtable, textscan, matlab.io.datastore.TabularTextDatastore.

%   Copyright 2015-2016 The MathWorks, Inc.
    ds = matlab.io.datastore.TabularTextDatastore(location, varargin{:});
end
