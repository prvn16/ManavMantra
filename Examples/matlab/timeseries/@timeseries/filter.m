function ts = filter(ts,n,d,varargin) 
%FILTER  Shape time series data
%
%   TS2=FILTER(TS1,N,D) applies the transfer function filter
%   N(z^-1)/D(z^-1) to the data in the time series object TS1. N and D are
%   the coefficient arrays of the transfer function.
%   Note: The time series must be uniformly sampled to use this filter.
%
%   TS2=FILTER(TS1,N,D,INDEX) uses the optional INDEX value to filter a
%   specific column when TS.IsTimeFirst is true, or row when TS.IsTimeFirst
%   is false. INDEX is specified as an integer array.
%
%   See also TIMESERIES/TIMESERIES, TIMESERIES/IDEALFILTER

%   Copyright 2005-2011 The MathWorks, Inc.

if numel(ts)~=1
    error(message('MATLAB:timeseries:filter:singletimeseriesobject'));
end
if ts.Length==0
    return
end

dataContent = ts.Data;
if ~isnumeric(dataContent) && ~islogical(dataContent)
     error(message('MATLAB:timeseries:filter:nonnumeric'));
end
s = size(dataContent);
if (length(s)>2 && ts.IsTimeFirst) || ...
        (s(2)>1 && ~ts.IsTimeFirst) || length(s)>3
    error(message('MATLAB:timeseries:filter:noarray'))
end

if nargin>=4  && ~isempty(varargin{1})
    colinds = varargin{1};
else
    if ts.IsTimeFirst
        colinds = 1:s(end);
    else
        colinds = 1:s(1);
    end
end

% Remove any NaNs
if any(isnan(dataContent(:)))
    ts = ts.resample(ts.Time);
    dataContent = ts.Data;
end
if any(isnan(dataContent(:)))
    error(message('MATLAB:timeseries:filter:allnans'))
end

% Filter
tmpData = dataContent;
if ts.IsTimeFirst    
    tmpData(:,colinds) = filter(n,d,dataContent(:,colinds));   
else
    tmpData(colinds,1,:) = filter(n,d,dataContent(colinds,1,:));
end
ts.Data = tmpData;
