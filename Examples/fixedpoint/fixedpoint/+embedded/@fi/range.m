%RANGE  Numerical range of a FI object
%   RANGE(A) returns a fi object with the minimum and maximum possible values
%   of fi object A. All possible quantized real-world values of A are in the
%   range returned. If A is a complex fi object, then all possible values of
%   real(A) and imag(A) are in the range returned. 
%
%   [U, V] = range(A) returns the minimum and maximum values of A in
%   separate output variables.
%
%   Examples:
%     a = fi(0,true,4,2);  
%     [u,v] = range(a)
%     % returns u = -2,  v = 1.75 = 2 - eps(a).
%     
%   See also EMBEDDED.FI/EPS, EMBEDDED.FI/INTMAX, EMBEDDED.FI/INTMIN,
%            EMBEDDED.FI/LOWERBOUND, EMBEDDED.FI/LSB, EMBEDDED.FI/REALMAX,
%            EMBEDDED.FI/REALMIN, EMBEDDED.FI/UPPERBOUND

%   Thomas A. Bryan, 7 May 1999.
%   Copyright 1999-2012 The MathWorks, Inc.
