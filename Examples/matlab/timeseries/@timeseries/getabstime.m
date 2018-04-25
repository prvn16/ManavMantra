function outtimes = getabstime(h)
%GETABSTIME  Extract a date string time vector into a cell array
%
%   GETABSTIME(TS) extracts the time vector from the time series object TS 
%   as a cell array of date strings (see DATESTR for help on date strings). 
%   The time vector must be defined relative to a calendar date, i.e. the property 
%   TimeInfo.StateDate must be defined. When the TimeInfo.StartDate format 
%   is a valid DATESTR format, the output strings from getAbsTime have the same format.
%
%   Example:
% 
%   Create a time series object:
%   ts=timeseries(rand(5))
%
%   Set the StartDate property:
%   ts.TimeInfo.StartDate='10/27/1974 07:05:36'
%
%   Extract the time vector:
%   getabstime(ts)
%
%   See also TIMESERIES/SETABSTIME, TIMESERIES/TIMESERIES

% Copyright 2005-2012 The MathWorks, Inc.

if numel(h)~=1
    error(message('MATLAB:timeseries:getabstime:noarray'));
end
if h.Length==0
    outtimes={};
    return
end

% Only work if the time vector is absolute
if isempty(h.TimeInfo.Startdate)
    error(message('MATLAB:timeseries:getabstime:notabs'))
end

% Get numeric time vector in days
t = datenum(h.TimeInfo.Startdate) + h.Time * tsunitconv('days',h.TimeInfo.Units);
if isempty(t)
    outtimes={};
    return
end

% If a valid datestr format is specified then use it
if tsIsDateFormat(h.TimeInfo.Format)
    outtimes = cellstr(datestr(t,h.TimeInfo.Format));
else
    outtimes = cellstr(datestr(t,'dd-mmm-yyyy HH:MM:SS'));
end
