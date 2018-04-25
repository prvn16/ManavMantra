function subds = partition(ds, partitionStrategy, partitionIndex)
%PARTITION Return a partitioned part of the TabularText Datastore.
%
%   SUBDS = PARTITION(DS,NUMPARTITIONS,INDEX) partitions DS into
%   NUMPARTITIONS parts and returns the partitioned TabularTextDatastore,
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
%      % A datastore that contains 10 copies of the 'airlinesmall.csv'
%      % example dataset.
%      files = repmat({'airlinesmall.csv'},1,10);
%      ds = tabularTextDatastore(files,'TreatAsMissing','NA','MissingValue',0);
%      ds.SelectedVariableNames = 'ArrDelay';
%
%      % This will parse approximately the first third of the example data.
%      subds = partition(ds,3,1);
%
%      totalSum = 0;
%      while hasdata(subds)
%         data = read(subds);
%         totalSum = totalSum + sum(data.ArrDelay);
%      end
%      totalSum
%
%   See also matlab.io.datastore.TabularTextDatastore, numpartitions.

%   Copyright 2014 The MathWorks, Inc.

try
    subds = partition@matlab.io.datastore.FileBasedDatastore(ds, partitionStrategy, partitionIndex);
catch e
    throw(e)
end
end
