function tf = istimetable(t)
%ISTIMETABLE True for timetables.
%   ISTIMETABLE(T) returns logical 1 (true) if T is a timetable and logical
%   0 (false) otherwise.
%
%   See also TIMETABLE, ISTABLE, ISCELL, ISSTRUCT, ISNUMERIC, ISOBJECT, ISLOGICAL.

%   Copyright 2016 The MathWorks, Inc.

tf = isa(t,'timetable');
