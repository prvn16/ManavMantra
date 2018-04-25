function maxArrivalDelayMapper (data, info, intermKVStore)
% Mapper function for the MaxMapreduceExample.

% Copyright 1984-2014 The MathWorks, Inc. 

% Data is an n-by-1 table of the ArrDelay. As the data source is tabular,
% the return of read is a table object.
partMax = max(data.ArrDelay);
add(intermKVStore, 'PartialMaxArrivalDelay',partMax);