function b = exponentbias(q)
%EXPONENTBIAS Exponent bias for QUANTIZER
%   EXPONENTBIAS(Q) returns the exponent bias relative to the arithmetic
%   defined by QUANTIZER object Q.  
%
%   If Q is a floating-point quantizer, then
%   EXPONENTBIAS(Q) = 2^(EXPONENTLENGTH(Q)-1) - 1.  
%
%   If Q is a fixed-point quantizer, then EXPONENTBIAS(Q)=0.
%
%   Example:
%     q = quantizer('double');
%     exponentbias(q)
%   returns 1023.
%
%   See also QUANTIZER, EMBEDDED.QUANTIZER/EPS, EMBEDDED.QUANTIZER/REALMAX

%   Thomas A. Bryan
%   Copyright 1999-2006 The MathWorks, Inc.

%    Reference:  IEEE Standard for Binary Floating-Point Arithmetic

b = exponentmax(q);
