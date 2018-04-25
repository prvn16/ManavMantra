function n = numpartitions(ds, varargin)
%NUMPARTITION Return a estimate for a reasonable number of partitions for the given information.
%
%   N = NUMPARTITIONS(DS) returns the default number of partitions for a
%   given TabularTextDatastore, DS, which is the total number of files.
%
%   N = NUMPARTITIONS(DS,POOL) returns a reasonable number of partitions
%   to parallelize DS over the parallel pool, POOL, based on the total
%   number of files and the number of workers in POOL.
%
%   Th number of partitions obtained from NUMPARTITIONS is recommended as
%   an input to PARTITION function.
%
%   Example:
%      % A datastore that contains 10 copies of the 'airlinesmall.csv'
%      % example dataset.
%      files = repmat({'airlinesmall.csv'},1,10);
%      ds = tabularTextDatastore(files,'TreatAsMissing','NA','MissingValue',0);
%      ds.SelectedVariableNames = 'ArrDelay';
%
%      N = numpartitions(ds,gcp);
%      totalSum = 0;
%      parfor ii = 1:N
%          subds = partition(ds,N,ii);
%
%          while hasdata(subds)
%              data = read(subds)
%              totalSum = totalSum + sum(data.ArrDelay);
%          end
%      end
%      totalSum
%
%   See also matlab.io.datastore.TabularTextDatastore, partition.

%   Copyright 2014 The MathWorks, Inc.

try
    n = numpartitions@matlab.io.datastore.SplittableDatastore(ds, varargin{:});
catch e
    throw(e)
end
end
