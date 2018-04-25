function p = eps(q)
%EPS    Quantized relative accuracy
%   EPS(Q) returns the value of the least significant bit of the fixed-point 
%   representation for quantizer object Q.
%
%   For both fixed-point and floating-point quantizers,
%   EPS(Q)=2^-FRACTIONLENGTH(Q).
%
%   Example:
%     q = quantizer('fixed',[6 3]);
%     eps(q)
%     % returns 0.125.
%
%   See also QUANTIZER, EMBEDDED.QUANTIZER/QUANTIZE

%   Thomas A. Bryan
%   Copyright 1999-2006 The MathWorks, Inc.

p = q.eps;
