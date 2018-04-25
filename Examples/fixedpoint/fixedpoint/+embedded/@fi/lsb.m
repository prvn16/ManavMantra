function B = lsb(A)
%LSB    Scaling of least significant bit of fi object 
%   LSB(A) returns the scaling of the least significant bit of fi object A.
%   The result is equivalent to the result given by the EPS function.
%
%   See also EMBEDDED.FI/EPS, EMBEDDED.FI/INTMAX, EMBEDDED.FI/INTMIN,
%            EMBEDDED.FI/LOWERBOUND, EMBEDDED.FI/RANGE, 
%            EMBEDDED.FI/REALMAX, EMBEDDED.FI/REALMIN, 
%            EMBEDDED.FI/UPPERBOUND     

%   Copyright 2003-2012 The MathWorks, Inc.
    
B = eps(A);
