function ds = imageDatastore(location, varargin)
%IMAGEDATASTORE Create an ImageDatastore to work with collections of images.
%   IMDS = imageDatastore(LOCATION) creates an ImageDatastore IMDS given the
%   LOCATION of the image files. LOCATION has the following properties:
%      - Can be a filename or a folder name
%      - Can be a cell array of multiple file or folder names
%      - Can contain a relative path (HDFS requires a full path)
%      - Can contain a wildcard (*) character.
%      - All the files in LOCATION must have extensions supported by IMFORMATS
%
%   IMDS = imageDatastore(__,'IncludeSubfolders',TF) specifies the logical
%   true or false to indicate whether the files in each folder and its
%   subfolders are included recursively or not.
%
%   IMDS = imageDatastore(__,'FileExtensions',EXTENSIONS) specifies the
%   extensions of files to be included. The extensions are not required to
%   be supported by IMFORMATS. Values for EXTENSIONS can be:
%      - A character vector, such as '.jpg' or '.png' (empty quotes '' are
%        allowed for files without extensions)
%      - A cell array of character vector, such as {'.jpg', '.png'}
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
%      Labels                   - A set of labels for images.i
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
%      imgarr = cell(numel(imds.Files),1);
%      for i = 1:numel(imds.Files)         % Read images using a for loop
%          imgarr{i} = readimage(imds,i);
%      end
%
%   See also datastore, mapreduce, imformats, matlab.io.datastore.ImageDatastore.

%   Copyright 2015 The MathWorks, Inc.
    ds = matlab.io.datastore.ImageDatastore(location, varargin{:});
end
