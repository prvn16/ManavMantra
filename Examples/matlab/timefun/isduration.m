function tf = isduration(t)
%ISDURATION True for durations.
%   ISDURATION(T) returns logical 1 (true) if T is a duration array and
%   logical 0 (false) otherwise.
%
%   See also DURATION, CALENDARDURATION, DATETIME, ISCALENDARDURATION, ISDATETIME.

%   Copyright 2014 The MathWorks, Inc.

tf = isa(t,'duration');
