function f = fractionlength(q)
%FRACTIONLENGTH Fraction length
%   FRACTIONLENGTH(Q) returns the fraction length of quantizer object Q.  
%
%   If Q is a fixed-point quantizer, then FRACTIONLENGTH(Q) is the second
%   element of FORMAT(Q).
%
%   If Q is a floating-pint quantizer, then
%   FRACTIONLENGTH(Q) = WORDLENGTH(Q) - EXPONENTLENGTH(Q) - 1. 
%
%   Example:
%     q = quantizer('double')
%     fractionlength(q)
%   returns 52.
%
%   See also QUANTIZER, EMBEDDED.QUANTIZER/WORDLENGTH,
%            EMBEDDED.QUANTIZER/EXPONENTLENGTH, EMBEDDED.QUANTIZER/FORMAT

%   Thomas A. Bryan
%   Copyright 1999-2006 The MathWorks, Inc.

f = q.fractionlength;
