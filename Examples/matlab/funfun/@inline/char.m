function str = char(obj)
%CHAR Convert INLINE object to character array.
%   CHAR(FUN) returns the formula for the INLINE object FUN.
%   This is the same as FORMULA(FUN).
%
%   See also INLINE, INLINE/FORMULA.

%   Steven L. Eddins, August 1995
%   Copyright 1984-2002 The MathWorks, Inc. 

str = obj.expr;
