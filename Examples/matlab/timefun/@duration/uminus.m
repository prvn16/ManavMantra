function b = uminus(a)
%UMINUS Negation for durations.
%   B = -A negates the duration array A.
%  
%   UMINUS(A) is called for the syntax '-A'.
%
%   See also ABS, PLUS, MINUS, DURATION.

%   Copyright 2014 The MathWorks, Inc.

try

    b = a;
    b.millis = -a.millis;

catch ME
    throwAsCaller(ME);
end
