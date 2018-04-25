function tf = istable(t)
%ISTABLE True for tables.
%   ISTABLE(T) returns logical 1 (true) if T is a table and logical 0 (false)
%   otherwise.
%
%   See also TABLE, ISTIMETABLE, ISCELL, ISSTRUCT, ISNUMERIC, ISOBJECT, ISLOGICAL.

%   Copyright 2012 The MathWorks, Inc.

tf = isa(t,'table');
