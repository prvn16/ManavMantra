function tf = iscalendarduration(t)
%ISCALENDARDURATION True for calendar durations.
%   ISCALENDARDURATION(T) returns logical 1 (true) if T is a
%   calendarDuration array and logical 0 (false) otherwise.
%
%   See also CALENDARDURATION, DURATION, DATETIME, ISDURATION, ISDATETIME.

%   Copyright 2014 The MathWorks, Inc.

tf = isa(t,'calendarDuration');
