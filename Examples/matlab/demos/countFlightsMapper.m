function countFlightsMapper(data, ~, intermKVStore)

% Copyright 2014 The MathWorks, Inc.

dayNumber = days((datetime(data.Year, data.Month, data.DayofMonth) - datetime(1987,10,1)))+1;
daysSinceEpoch = days(datetime(2008,12,31) - datetime(1987,10,1))+1;

[airlineName, ~, airlineIndex] = unique(data.UniqueCarrier, 'stable');

for i = 1:numel(airlineName)
    dayTotals = accumarray(dayNumber(airlineIndex==i), 1, [daysSinceEpoch, 1]);
    add(intermKVStore, airlineName{i}, dayTotals);
end
end