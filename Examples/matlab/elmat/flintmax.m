%FLINTMAX Largest consecutive integer in floating point format.
%   FLINTMAX returns the largest consecutive integer in IEEE double
%   precision, which is 2^53. Above this value, double precision format
%   does not have integer precision, and not all integers can be represented 
%   exactly.
%
%   FLINTMAX('double') is the same as FLINTMAX.
%
%   FLINTMAX('single') returns the largest consecutive integer in
%   IEEE single precision, which is SINGLE(2^24).
%
%   See also EPS, REALMAX, INTMAX.

%   Copyright 1984-2012 The MathWorks, Inc. 
%   Built-in function.
