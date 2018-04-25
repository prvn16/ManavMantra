function outtimes = getabstime(h)
%GETABSTIME  Extract a date string time vector into a cell array.
%
%   GETABSTIME(TSC) extracts the time vector from the tscollection object TSC 
%   as a cell array of date strings (see DATESTR for help on date strings). 
%   The time vector must be defined relative to a calendar date, i.e. the property 
%   TimeInfo.StateDate must be defined. When the TimeInfo.StartDate format 
%   is a valid DATESTR format, the output strings from getAbsTime have the same format.
%
%   Example:
% 
%   Create a tscollection object:
%   tsc=tscollection(timeseries(rand(5,1)))
%
%   Set the StartDate property:
%   tsc.TimeInfo.StartDate='10/27/1974 07:05:36'
%
%   Extract a vector of absolute time values:
%   getabstime(tsc)
%
%   See also TIMESERIES/SETABSTIME, TIMESERIES/TIMESERIES

%   Copyright 2004-2011 The MathWorks, Inc.

% Only work if the time vector is absolute
if isempty(h.TimeInfo.StartDate)
    error(message('MATLAB:tscollection:getabstime:notabs'))
end

% Get numeric time vector in days
t = datenum(h.TimeInfo.StartDate) + h.Time * tsunitconv('days',h.TimeInfo.Units);

% If a valid datestr format is specified then use it
if tsIsDateFormat(h.TimeInfo.Format)
    outtimes = cellstr(datestr(t,h.TimeInfo.Format));
else
    outtimes = cellstr(datestr(t,'dd-mmm-yyyy HH:MM:SS'));
end
