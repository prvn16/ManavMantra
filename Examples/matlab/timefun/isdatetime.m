function tf = isdatetime(t)
%ISDATETIME True for datetimes.
%   ISDATETIME(T) returns logical 1 (true) if T is a datetime array and
%   logical 0 (false) otherwise.
%
%   See also DATETIME, DURATION, CALENDARDURATION, ISDURATION, ISCALENDARDURATION.

%   Copyright 2014 The MathWorks, Inc.

tf = isa(t,'datetime');
