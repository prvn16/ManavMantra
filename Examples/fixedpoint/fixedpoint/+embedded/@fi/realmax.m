%REALMAX Largest positive fixed-point value 
%   REALMAX(A) is the largest real-world value that can be represented in 
%   the data type of fi object A. Anything larger overflows. 
%
%   Examples:
%     a = fi(0,DataTypeMode','single');
%     realmax(a)
%     % returns 3.4028e+038.
%
%     b = fi(0,true,8,7);
%     realmax(b)
%     % returns 0.9921875.
%
%     c = fi(0,false,8,7);
%     realmax(c)
%     % returns 1.9921875.
%
%   See also EMBEDDED.FI/EPS, EMBEDDED.FI/INTMAX, EMBEDDED.FI/INTMIN,
%            EMBEDDED.FI/LOWERBOUND, EMBEDDED.FI/LSB, EMBEDDED.FI/RANGE,
%            EMBEDDED.FI/REALMIN, EMBEDDED.FI/UPPERBOUND
 

%   Thomas A. Bryan
%   Copyright 1999-2012 The MathWorks, Inc.
