function subds = partition(fds, partitionStrategy, partitionIndex)
%PARTITION Returns a partitioned portion of the FileDatastore.
%
%   SUBDS = PARTITION(FDS,NUMPARTITIONS,INDEX) partitions FDS into 
%   NUMPARTITIONS parts and returns the partitioned FileDatastore, SUBDS,
%   corresponding to INDEX. An estimate for a reasonable value for the
%   NUMPARTITIONS input can be obtained by using the NUMPARTITIONS function.
%
%   SUBDS = PARTITION(FDS,'Files',INDEX) partitions FDS by files in the
%   Files property and returns the partition corresponding to INDEX.
%
%   SUBDS = PARTITION(FDS,'Files',FILENAME) partitions FDS by files and
%   returns the partition corresponding to FILENAME.
%
%   Example:
%   --------
%      folder = fullfile(matlabroot,'toolbox','matlab','demos');
%      fds = fileDatastore(folder,'ReadFcn',@load,'FileExtensions','.mat');
%
%      % For FileDatastore, numpartitions returns the number of files by default
%      n = numpartitions(fds);
%
%      % subds contains the first file from the FileDatastore
%      subds = partition(fds,n,1);
%
%      % If not empty, read the file represented by subds
%      while hasdata(subds)
%         img = read(subds);
%      end
%
%   See also numpartitions, fileDatastore, load.

%   Copyright 2015 The MathWorks, Inc.

try
    subds = partition@matlab.io.datastore.FileBasedDatastore(fds, partitionStrategy, partitionIndex);
catch e
    throw(e)
end
end
