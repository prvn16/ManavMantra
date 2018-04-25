function statsByGroupMapper(data, ~, intermKVStore, groupVarName)
% Mapper function for the StatisticsByGroupMapReduceExample.

% Copyright 2014 The MathWorks, Inc.

% Data is a n-by-3 table. Remove missing values first
delays = data.ArrDelay;
groups = data.(groupVarName);
notNaN =~isnan(delays);
groups = groups(notNaN);
delays = delays(notNaN);

% find the unique group levels in this chunk
[intermKeys,~,idx] = unique(groups, 'stable');

% group delays by idx and apply @grpstatsfun function to each group
intermVals = accumarray(idx,delays,size(intermKeys),@grpstatsfun);
addmulti(intermKVStore,intermKeys,intermVals);

function out = grpstatsfun(x)
n = length(x); % count
m = sum(x)/n; % mean
v = sum((x-m).^2)/n; % variance
s = sum((x-m).^3)/n; % skewness without normalization
k = sum((x-m).^4)/n; % kurtosis without normalization
out = {[n, m, v, s, k]};