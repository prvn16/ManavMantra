function [startInd,endInd] = utTrimNans(h)
%
% tstool utility function

%   Copyright 2005-2006 The MathWorks, Inc.

%% For cell arrays of time series (all of the same length) utTrimNans
%% removes rows with NaNs from the start and end simultaneously until
%% all timeseries have start and end rows with no NaNs

if isempty(h)
    startInd = 0;
    endInd = 0;
    return
end

if iscell(h)
    overallStartInd = -inf;
    overallEndInd = inf;
    for k=1:length(h)
        thists = h{k};
        [startInd,endInd] = localTrimNaNs(thists.Data,thists.TimeInfo.Length);
        overallStartInd = max(startInd,overallStartInd);
        overallEndInd = min(endInd,overallEndInd);
    end
    startInd = overallStartInd;
    endInd = overallEndInd;
% Single time series case
else
    [startInd,endInd] = localTrimNaNs(h.Data,h.TimeInfo.Length);
end




function [startInd,endInd] = localTrimNaNs(data,totalLength);


%% End NaNs
endInd = totalLength;
startInd = 1;
I = find(all(isfinite(data),2));
if ~isempty(I)
    startInd = I(1);
    endInd = I(end); 
end

%{
while any(isnan(data(end,:))) && size(data,1)>1
    data = data(1:end-1,:);
    endInd = endInd-1;
end
%% Start NaNs
while any(isnan(data(1,:))) && size(data,1)>1
    data = data(2:end,:);
    startInd = startInd+1;
end
%}