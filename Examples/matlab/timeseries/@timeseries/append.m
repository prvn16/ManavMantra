function tsout = append(ts1,ts2,varargin)
%APPEND  Concatenation of time series objects in the time dimension.
%
%   This operation appends time series objects.  The time vectors must not
%   overlap by a non-zero amount, i.e., the last time in TS1 must be earlier 
%   than or equal to the first time in TS2.  The sample size of the time 
%   series must agree. 

%   Copyright 2009-2012 The MathWorks, Inc.


% All inputs must be timeseries objects
if nargin>=2    
    if ~isa(ts2,'timeseries')
        error(message('MATLAB:timeseries:append:invts'));
    end
    tsArray = [ts1,ts2];
    if nargin>=3 
        if ~all(cellfun(@(x) isa(x,'timeseries'),varargin))
           error(message('MATLAB:timeseries:append:invts'));
        end
        tsArray = [tsArray,[varargin{:}]];
    end
else
   tsArray = ts1;
end

% Return for empty timeseries
if length(tsArray)<=0
    tsout = tsArray;
    return
end

% Process arguments pairwise
tsout = tsArray(1);
for k=2:length(tsArray)
    tsout = localConcat(tsout,tsArray(k));
end

function tsout = localConcat(ts1,ts2)

if ts1.Length==0
    tsout = ts2;
    return
elseif ts2.Length==0
    tsout = ts1;
    return
end

% Merge time vectors onto a common basis
[ts1timevec, ts2timevec, outprops] = ...
    timemerge(ts1.TimeInfo, ts2.TimeInfo,ts1.Time,ts2.Time);

% Concatenate time and data.

if ts1timevec(end)>ts2timevec(1) 
    error(message('MATLAB:timeseries:append:nooverlap'))
end
time = vertcat(ts1timevec,ts2timevec);

% Build the output data array
if ~isequal(ts1.getdatasamplesize,ts2.getdatasamplesize)
    error(message('MATLAB:timeseries:append:errdim'))
end

% Merge the time alignment
% Rule: if both of their IsTimeFirst are false, out is false, otherwise, true
[data1,data2] = tsAlignSizes(ts1.Data, ts1.IsTimeFirst,ts2.Data,ts2.IsTimeFirst);
if ~ts1.IsTimeFirst && ~ts2.IsTimeFirst
    if isequal(size(data1),ts1.getdatasamplesize)
        dataout = cat(ndims(data1)+1,data1,data2);
    elseif isequal(size(data2),ts2.getdatasamplesize)
        dataout = cat(ndims(data2)+1,data1,data2);
    else
        dataout = cat(ndims(data1),data1,data2);
    end
else    
    dataout = [data1;data2];
end

% Build output time series. If both time series are subclasses,
% try to make the output the same class
tsout = ts1;
tsout.DataInfo = cat(ts1.DataInfo,ts2.DataInfo);
tsout = init(tsout,dataout,time,'IsTimeFirst',ts1.IsTimeFirst || ts2.IsTimeFirst,...
    'Name','unnamed');
tsout.TimeInfo.StartDate = outprops.ref;
tsout.TimeInfo.Units = outprops.outunits;
tsout.TimeInfo.Format = outprops.outformat;

% Quality arithmetic - merge quality info and combine quality codes
if ~isempty(ts1.QualityInfo) && ~isempty(ts2.QualityInfo)
    tsout.QualityInfo = qualitymerge(ts1.QualityInfo,ts2.QualityInfo);
end
if ~isempty(ts1.Quality) && ~isempty(ts2.Quality)
    tsout.Quality = [ts1.Quality;ts2.Quality];
end

% Event concat
tsout.Events = [ts1.Events,ts2.Events];
