function fcn = vectorize(fcn)
%VECTORIZE Vectorize an INLINE function object.
%   VECTORIZE(FCN) inserts a '.' before any '^', '*' or '/' in the formula
%   for FCN.  The result is the vectorized version of the INLINE function.
%
%   See also INLINE/FORMULA, INLINE.

%   Copyright 1984-2007 The MathWorks, Inc.

fcn.expr = vectorize(fcn.expr);
