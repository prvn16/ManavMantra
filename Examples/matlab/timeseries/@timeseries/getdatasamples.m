function data = getdatasamples(this,I)
%GETDATASAMPLES Obtain a subset of timeseries samples using a subscript/index
%array.
%
%   This operation returns the data from a subset of timeseries samples
%   extracted based in the supplied subscript/index array.
%
%   DATA = GETDATASAMPLES(TS,I) returns the data obtained from the samples of the
%   timeseries TS corresponding to the time(s) TS.TIME(I).
%
%   See also TIMESERIES/GETSAMPLES, TIMESERIES/RESAMPLE

%   Copyright 2009-2011 The MathWorks, Inc.

if numel(this)~=1
    error(message('MATLAB:timeseries:getdatasamples:noarray'));
end
if isempty(I)
    data = [];
    return;
elseif islogical(I)
    if length(I)>this.Length
        error(message('MATLAB:timeseries:getdatasamples:badlogicalsubscript'))
    end
elseif isnumeric(I) && isvector(I) && isreal(I)
    if this.Length==0 || any(I<1) || any(I>this.Length) || ~isequal(round(I),I)
        error(message('MATLAB:timeseries:getdatasamples:badsubscript'))
    end
else
    error(message('MATLAB:timeseries:getdatasamples:badind'));
end   

% Slice and return the data 
data = this.Data;
ind = repmat({':'},[ndims(data) 1]);
if isempty(I)
    data = [];
elseif this.IsTimeFirst
    data = data(I,ind{2:end});
else
    if this.TimeInfo.Length==1
        data = data(ind{1:end},I);
    else
        data = data(ind{1:end-1},I);
    end
end


