function a = removevars(a,vars)
%REMOVEVARS Delete variables from table or timetable.
%   T2 = REMOVEVARS(T1, VARS) deletes the table variables specified by
%   VARS. VARS is a positive integer, a vector of positive integers, a
%   variable name, a cell array containing one or more variable names, or a
%   logical vector.
%
%   See also ADDVARS, MOVEVARS, SPLITVARS, MERGEVARS.

%   Copyright 2017 The MathWorks, Inc.

if nargin < 2
    vars = [];
end
% creating = false, removing = true
a = a.subsasgnParens({':',vars},[],false,true);

