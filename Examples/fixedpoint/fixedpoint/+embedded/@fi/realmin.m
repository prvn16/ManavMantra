%REALMIN Smallest positive fixed-point value 
%   REALMIN(A) is the smallest real-world value that can be represented in 
%   the data type of fi object A. Anything smaller underflows. 
%
%   Examples:
%     a = fi(0,true,6,3);
%     realmin(a)
%     % returns 0.125.
%
%   See also EMBEDDED.FI/EPS, EMBEDDED.FI/INTMAX, EMBEDDED.FI/INTMIN,
%            EMBEDDED.FI/LOWERBOUND, EMBEDDED.FI/LSB, EMBEDDED.FI/RANGE,
%            EMBEDDED.FI/REALMAX, EMBEDDED.FI/UPPERBOUND
 
%   Thomas A. Bryan
%   Copyright 1999-2012 The MathWorks, Inc.
