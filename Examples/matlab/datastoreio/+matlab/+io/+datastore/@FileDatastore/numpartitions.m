function n = numpartitions(fds, varargin)
%NUMPARTITIONS Returns an estimate of a reasonable number of partitions.
%
%   N = NUMPARTITIONS(FDS) returns the default number of partitions for a
%   given FileDatastore, FDS, which is the total number of files.
%
%   N = NUMPARTITIONS(FDS,POOL) returns a reasonable number of partitions
%   to parallelize FDS over the parallel pool, POOL, based on the total
%   number of files and the number of workers in POOL.
%
%   Th number of partitions obtained from NUMPARTITIONS is recommended as
%   an input to PARTITION function.
%
%   Example:
%   --------
%      folder = fullfile(matlabroot,'toolbox','matlab','demos');
%      fds = fileDatastore(folder,'ReadFcn',@load,'FileExtensions','.mat');
%
%      % For FileDatastore, numpartitions is the number of files by default
%      n = numpartitions(fds);
%
%   See also partition, fileDatastore, imageDatastore.

%   Copyright 2015 The MathWorks, Inc.

try
    n = numpartitions@matlab.io.datastore.FileBasedDatastore(fds, varargin{:});
catch e
    throw(e)
end
end
