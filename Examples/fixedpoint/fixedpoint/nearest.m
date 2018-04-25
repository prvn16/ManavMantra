function y = nearest(x)
%NEAREST Round to nearest integer - ties round up
%   NEAREST(X) rounds the elements of X to the nearest integer, and
%   ties are rounded up (towards +inf).
%
%   CONVERGENT, NEAREST, and ROUND only differ in the way they treat
%   values whose fractional part is 0.5.
%
%   In CONVERGENT, the ties are rounded to the nearest even integer. 
%   In NEAREST, the ties are rounded up.
%   In ROUND, the ties are rounded up if positive, and down if negative.
%
%   Example:
%
%       x=(-3.5:3.5)';
%       [x convergent(x) nearest(x) round(x)]
%
%   See also FLOOR, CEIL, CONVERGENT, FIX, ROUND

%   Thomas A. Bryan
%   Copyright 1999-2007 The MathWorks, Inc.

if isinteger(x)
    y = x;
elseif isreal(x)
    y = floor(x+0.5);
else
    y = floor(x+(0.5+0.5i));
end


