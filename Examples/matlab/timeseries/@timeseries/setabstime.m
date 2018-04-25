function h = setabstime(h,timeArray,varargin)
%SETABSTIME  Set date strings as the times of a time series.
%
%   TS = SETABSTIME(TS, TIMES) sets the times in TS using the date strings
%   TIMES. TIMES must be either a cell array of strings, or a char array,
%   containing valid date or time values in the same date format. See
%   DATESTR for help on date string formats. 
%
%   TS = SETABSTIME(TS, TIMES, FORMAT) specifies FORMAT used in TIMES
%   explicitly.  
%
%   Example:
% 
%   Create a time series object:
%   ts = timeseries(rand(3,1))
%
%   Set the absolute time vector:
%   ts = setabstime(ts,{'12-DEC-2047 12:34:56','12-DEC-2047 13:34:56','12-DEC-2047 14:34:56'})
%
%   See also TIMESERIES/GETABSTIME, TIMESERIES/TIMESERIES

%   Copyright 2005-2016 The MathWorks, Inc.

if numel(h)~=1
    error(message('MATLAB:timeseries:setabstime:noarray'));
end
if ~isempty(timeArray) && (iscell(timeArray) || ischar(timeArray) || isstring(timeArray))
    [thisTime,h.TimeInfo.Startdate] = ...
        tsAnalyzeAbsTime(timeArray,h.TimeInfo.Units,[],varargin{:});
    h.Time = thisTime;
end
 