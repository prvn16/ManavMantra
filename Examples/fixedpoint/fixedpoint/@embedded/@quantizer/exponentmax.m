function e=exponentmax(q)
%EXPONENTMAX Maximum biased exponent
%   EXPONENTMAX(Q) returns the maximum biased exponent for quantizer object Q.
%
%   If Q is a floating-point quantizer, then
%   EXPONENTMAX(Q) = 2^(EXPONENTLENGTH(Q)-1)-1. 
%
%   If Q is a fixed-point quantizer, then EXPONENTMAX(Q)=0.
%
%   Example:
%     q = quantizer('double');
%     exponentmax(q)
%   returns 1023.
%
%   See also QUANTIZER

%   Thomas A. Bryan
%   Copyright 1999-2006 The MathWorks, Inc.

e=q.exponentmax;
