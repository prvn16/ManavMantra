function subsettingMapper(data, ~, intermKVStore)
% Select flights from 1995 and later that had exceptionally long
% elapsed flight times (including both time on the tarmac and time in 
% the air).

% Copyright 2014 The MathWorks, Inc.

idx = data.Year > 1994 & (data.ActualElapsedTime - data.CRSElapsedTime)...
    > 1.50 * data.CRSElapsedTime;
intermVal = data(idx,:);

add(intermKVStore,'Null',intermVal);
