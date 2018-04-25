function ts = detrend(ts,type,varargin) 
%DETREND  Remove a mean or a best-fit line
%
%   TS2 = DETREND(TS1,TYPE) removes a mean or a best-fit line from time series
%   data, usually for FFT processing. TYPE is a string that describes the
%   detrend method, specified as 'constant' or 'linear'.
%
%   TS2 = DETREND(TS1,TYPE,INDEX) uses the optional INDEX value to detrend
%   a specific column when TS1.IsTimeFirst is true, or row when
%   TS1.IsTimeFirst is false. INDEX is specified as an integer array.
%
%   NOTE: DETREND cannot be applied to time series data with more than 2 dimensions.
%
%   See also TIMESERIES/TIMESERIES

%   Copyright 2005-2011 The MathWorks, Inc.

b_state = warning('query','backtrace'); 
t_state = warning('query','MATLAB:detrend:InvalidTrendType');
warning('off','backtrace');

narginchk(2,3);

if numel(ts)~=1
    error(message('MATLAB:timeseries:detrend:singletimeseriesobject'));
end

if ts.Length==0
    return;
end
dataContent = ts.Data;
if ~isnumeric(dataContent) && ~islogical(dataContent)
    error(message('MATLAB:timeseries:detrend:nonnumeric'));
end
s = size(dataContent);

%% Detrends time series data
if (length(s)>2 && ts.IsTimeFirst) || ...
   (s(1)>1 && ~ts.IsTimeFirst) || ...
   length(s)>3
    warning(b_state);
    warning(t_state);
    error(message('MATLAB:timeseries:detrend:noarray'))
end

% Get column indices
if nargin==3 && isnumeric(varargin{1})
    colind = varargin{1};
else
    if ts.IsTimeFirst
        colind = 1:s(end);
    else
        colind = 1:s(1);
    end
end

% Detrend the ordinate data
if ts.IsTimeFirst
    data = dataContent(:,colind);
    for col=1:length(colind)
        nanvals = isnan(data(:,col));
        if col ~= 1
            warning('off','MATLAB:detrend:InvalidTrendType');
        end
        % Detrend if there are more than two non-nan samples
        if sum(~nanvals)>2
            data(~nanvals,col) = detrend(data(~nanvals,col),type);
        end
    end   
    tmpData = dataContent;
    tmpData(:,colind) = data;
    ts.Data = tmpData;
else
    data = dataContent(colind,1,:);
    for col=1:length(colind)
        nanvals = isnan(squeeze(data(col,1,:))); 
        if col ~= 1
            warning('off','MATLAB:detrend:InvalidTrendType');
        end
        % Detrend if there are more than two non-nan samples
        if sum(~nanvals)>2
            data(col,1,~nanvals) = ...
               reshape(detrend(squeeze(data(col,1,~nanvals))',type)',...
                [1 1 sum(~nanvals)]);
        end
    end
    tmpData = dataContent;   
    tmpData(colind,1,:) = data;
    ts.Data = tmpData;
end

warning(b_state);
warning(t_state);