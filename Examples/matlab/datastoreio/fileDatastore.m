function ds = fileDatastore(location, varargin)
%FILEDATASTORE Create a datastore for a collection of files with custom data format.
%   FDS = fileDatastore(LOCATION,'ReadFcn',@MYCUSTOMREADER) creates a
%   FileDatastore if a file or a collection of files are present in LOCATION.
%   LOCATION has the following properties:
%      - Can be a filename or a folder name
%      - Can be a cell array of multiple file or folder names
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
%      - A character vector, such as '.jpg' or '.png' (empty quotes '' are
%        allowed for files without extensions)
%      - A cell array of character vector, such as {'.jpg', '.mat'}
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
%   See also datastore, mapreduce, load, matlab.io.datastore.FileDatastore.

%   Copyright 2017 The MathWorks, Inc.
    ds = matlab.io.datastore.FileDatastore(location, varargin{:});
end
