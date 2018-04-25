function ds = spreadsheetDatastore(location, varargin)
%SPREADSHEETDATASTORE Datastore for a collection of spreadsheet files.
%   SSDS = spreadsheetDatastore(LOCATION) creates a SpreadsheetDatastore
%   based on a spreadsheet file or a collection of such files in LOCATION.
%   LOCATION has the following properties:
%      - Can be a filename or a folder name
%      - Can be a cell array of multiple file or folder names
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
%      - A character vector, such as '.xls' or '.xlsm' or '.myformat' (empty
%        quotes '' are allowed for files without extensions)
%      - A cell array of character vector, such as {'.xls', '.xlsm', '.myformat'}
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
%   See also datastore, mapreduce, readtable, xlsread, matlab.io.datastore.SpreadsheetDatastore.

%   Copyright 2015-2016 The MathWorks, Inc.
    ds = matlab.io.datastore.SpreadsheetDatastore(location, varargin{:});
end
