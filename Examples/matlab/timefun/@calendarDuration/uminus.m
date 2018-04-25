function b = uminus(a)
%UMINUS NEGATION for calendar durations.
%   B = -A negates the calendar duration array A.
%  
%   UMINUS(A) is called for the syntax '-A'.
%
%   See also PLUS, MINUS, CALENDARDURATION.

%   Copyright 2014 The MathWorks, Inc.

try

    b = a;
    b_components = b.components;
    b_components.months = -b_components.months;
    b_components.days   = -b_components.days;
    b_components.millis = -b_components.millis;
    b.components = b_components;

catch ME
    throwAsCaller(ME);
end
