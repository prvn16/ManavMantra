function args = argnames(fun)
%ARGNAMES Argument names.
%   ARGNAMES(FUN) returns the names of the input arguments of the
%   INLINE object FUN as a cell array of strings.
%
%   See also INLINE/FORMULA.

%   Copyright 1984-2002 The MathWorks, Inc. 

args = cellstr(fun.args);
