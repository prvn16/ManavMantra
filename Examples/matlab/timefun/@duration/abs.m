function b = abs(a)
%ABS Absolute value for durations.
%   B = ABS(A) returns the absolute values of the elements of the duration
%   array A.
%
%   See also UMINUS, PLUS, MINUS, DURATION.

%   Copyright 2014 The MathWorks, Inc.

b = a;
b.millis = abs(a.millis);
