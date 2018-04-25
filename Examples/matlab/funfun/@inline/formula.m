function args = formula(fun)
%FORMULA Function formula.
%   FORMULA(FUN) returns the formula for the INLINE object FUN.
%
%   See also INLINE/ARGNAMES, INLINE/CHAR.

%   Copyright 1984-2002 The MathWorks, Inc. 

args = fun.expr;
