function subds = partition(ds, partitionStrategy, partitionIndex)
%PARTITION Return a partitioned part of the SpreadsheetDatastore.
%
%   SUBDS = PARTITION(DS,NUMPARTITIONS,INDEX) partitions DS into
%   NUMPARTITIONS parts and returns the partitioned SpreadsheetDatastore,
%   SUBDS, corresponding to INDEX. An estimate for a reasonable value for the
%   NUMPARTITIONS input can be obtained by using the NUMPARTITIONS function.
%
%   SUBDS = PARTITION(DS,'Files',INDEX) partitions DS by files in the
%   Files property and returns the partition corresponding to INDEX.
%
%   SUBDS = PARTITION(DS,'Files',FILENAME) partitions DS by files and
%   returns the partition corresponding to FILENAME.
%
%   Example:
%   --------
%      % A datastore that contains 10 copies of the 'airlinesmall.xlsx'
%      % example dataset.
%      ssds = spreadsheetDatastore(repmat({'airlinesmall_subset.xlsx'},1,10));
%      ssds.SelectedVariableNames = 'ArrDelay';
%
%      % This will parse approximately the first third of the example data.
%      subds = partition(ssds,3,1);
%      % Sum the Arrival Delays
%      sumAD = 0;
%
%      while hasdata(subds)
%          tab = read(subds);
%          data = tab.ArrDelay(~isnan(tab.ArrDelay)); % filter data
%          sumAD = sumAD + sum(data);
%      end
%      sumAD
%
%   See also matlab.io.datastore.SpreadsheetDatastore, numpartitions.

%   Copyright 2015 The MathWorks, Inc.

    try
        subds = partition@matlab.io.datastore.FileBasedDatastore(ds, partitionStrategy, partitionIndex);
    catch ME
        throw(ME);
    end
end
