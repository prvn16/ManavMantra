function n = numpartitions(imds, varargin)
%NUMPARTITIONS Returns an estimate of a reasonable number of partitions.
%
%   N = NUMPARTITIONS(IMDS) returns the default number of partitions for a
%   given ImageDatastore, IMDS, which is the total number of files.
%
%   N = NUMPARTITIONS(IMDS,POOL) returns a reasonable number of partitions
%   to parallelize IMDS over the parallel pool, POOL, based on the total
%   number of files and the number of workers in POOL.
%
%   Th number of partitions obtained from NUMPARTITIONS is recommended as
%   an input to PARTITION function.
%
%   Example:
%   --------
%      folders = fullfile(matlabroot,'toolbox','matlab',{'demos','imagesci'});
%      exts = {'.jpg','.png','.tif'};
%      imds = imageDatastore(folders,'FileExtensions',exts);
%
%      % For images, numpartitions is the number of files by default
%      n = numpartitions(imds)
%
%   See also imageDatastore, partition.

%   Copyright 2015 The MathWorks, Inc.

try
    n = numpartitions@matlab.io.datastore.SplittableDatastore(imds, varargin{:});
catch e
    throw(e)
end
end
