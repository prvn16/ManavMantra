function n = numpartitions(ds, varargin)
%NUMPARTITION Return a estimate for a reasonable number of partitions for the given information.
%
%   N = NUMPARTITIONS(DS) returns the default number of partitions for a
%   given SpreadsheetDatastore, DS, which is the total number of files.
%
%   N = NUMPARTITIONS(DS,POOL) returns a reasonable number of partitions
%   to parallelize DS over the parallel pool, POOL, based on the total
%   number of files and the number of workers in POOL.
%
%   Th number of partitions obtained from NUMPARTITIONS is recommended as
%   an input to PARTITION function.
%
%   Example:
%   --------
%      % SpreadsheetDatastore that contains 10 copies of the 'airlinesmall.xlsx'
%      % example dataset.
%      ssds = spreadsheetDatastore(repmat({'airlinesmall_subset.xlsx'},1,10));
%      ssds.SelectedVariableNames = 'ArrDelay';
%
%      N = numpartitions(ssds);
%      % Sum the Arrival Delays
%      sumAD = 0;
%      parfor ii = 1:N
%          subds = partition(ssds,N,ii);
%
%          while hasdata(ssds)
%              tab = read(ssds);
%              data = tab.ArrDelay(~isnan(tab.ArrDelay)); % filter data
%              sumAD = sumAD + sum(data);
%          end
%      end
%      sumAD
%
%   See also matlab.io.datastore.SpreadsheetDatastore, partition.

%   Copyright 2015 The MathWorks, Inc.

    try
        n = numpartitions@matlab.io.datastore.SplittableDatastore(ds, varargin{:});
    catch ME
        throw(ME);
    end
end
