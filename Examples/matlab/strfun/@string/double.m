%DOUBLE Convert string array to double array
%   X = DOUBLE(STR) converts a string array to a double array. STR contains 
%   strings that represent real or complex numbers. X is a double array that 
%   is the same size as STR. Each element of STR can contain digits, a comma 
%   (thousands separator), a decimal point, a leading + or - sign, or an 'e' 
%   preceding a power of 10 scale factor.
%
%   STR can contain text which represents a complex number. Complex numbers 
%   have an optional real part followed by an imaginary part denoted with 
%   a trailing i or j.
%
%   If an element in STR cannot be converted to a number, then the 
%   corresponding element in X is NaN.
%
%   Examples
%       STR = "3.141"
%       double(STR)                         returns 3.1410
%
%       STR = "2+3i"
%       double(STR)                         returns 2.0000 + 3.0000i
%
%       STR = ["2.71828","MATLAB"]
%       double(STR)                         returns [2.7183 NaN]
%
%   See also STRING, ISSTRING, ISFLOAT, ISNUMERIC.

%   Copyright 2016 The MathWorks, Inc.