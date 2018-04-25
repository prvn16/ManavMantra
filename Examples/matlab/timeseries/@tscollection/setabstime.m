function h = setAbsTime(h,timeArray,varargin)
%SETABSTIME  Set date strings as the times of a tscollection object.
%
%   TSC = SETABSTIME(TSC, TIMES) sets the times in TSC using the date strings
%   TIMES. TIMES must be either a cell array of strings, or a char array,
%   containing valid date or time values in the same date format. See
%   DATESTR for help on date string formats. 
%
%   TSC = SETABSTIME(TSC, TIMES, FORMAT) specifies FORMAT used in TIMES
%   explicitly.  
%
%   Example:
% 
%   Create a tscollection object:
%   tsc = tscollection(timeseries(rand(3,1)))
%
%   Set the absolute time vector:
%   tsc = setabstime(tsc,{'12-DEC-2047 12:34:56','12-DEC-2047 13:34:56','12-DEC-2047 14:34:56'})
%
%   See also TSCOLLECTION/GETABSTIME, TSCOLLECTION/TSCOLLECTION

%   Copyright 2004-2006 The MathWorks, Inc.
 
if (iscell(timeArray) || ischar(timeArray))&& length(timeArray)>0
    [thisTime,h.TimeInfo.Startdate] = ...
        tsAnalyzeAbsTime(timeArray,h.TimeInfo.Units,[],varargin{:});
    h.Time = thisTime;
end
 
