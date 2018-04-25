function [tf, dt] = isregular(tt, unit)
%ISREGULAR TRUE for a regular timetable.
%   ISREGULAR(T) returns TRUE if the timetable T is regular, and FALSE if
%   not. A timetable is regular if its time vector is monotonically
%   increasing or decreasing by a fixed time step, in other words, if
%   UNIQUE(DIFF(TT.PROPERTIES.ROWTIMES)) is a positive or negative scalar.
%   
%   ISREGULAR(T, UNIT) returns true if the timetable T is regular with
%   respect to the calendar duration UNIT that is specified by one of the
%   character vectors: 'years', 'quarters, 'months', 'weeks', 'days', or
%   'time'.  A time vector that is a duration can only be regular with
%   respect to 'time', and will return false for all other calendar
%   duration UNITs.
%
%   Passing the UNIT 'time' is equivalent to ISREGULAR(T).  
%
%   Examples: 
%
%   % Construct a timetable using a monthly time vector. This timetable is
%   % regular with respect to months.
%   monthlyValues = timetable(datetime(2016,1:5,3)', [1:5]')
%   isregular(monthlyValues,'months')
%   caldiff(monthlyValues.Time)
%
%   % The monthly timetable is not regular with respect to either days or
%   % absolute time, because the 1-month time steps are not equal lengths
%   % when measured in days, or in absolute time.
%   isregular(monthlyValues,'days')
%   caldiff(monthlyValues.Time,'days')
%   isregular(monthlyValues)
%   diff(monthlyValues.Time)
%
%   See also ISSORTED.

%   Copyright 2016-2017 The MathWorks, Inc.

if nargin < 2
    [tf, dt] = tt.rowDim.isregular();
else
    [tf, dt] = tt.rowDim.isregular(unit);
end
