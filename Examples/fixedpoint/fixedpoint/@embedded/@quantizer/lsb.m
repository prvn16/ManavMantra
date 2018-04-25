function p = lsb(q)
%LSB    Value of the least-significant bit
%   LSB(Q) returns the quantization level of QUANTIZER object Q,
%   or the distance from 1.0 to the next largest floating-point
%   number if Q is a floating-point QUANTIZER object.
%
%   For both fixed-point and floating-point quantizers Q,
%   LSB(Q)=2^-FRACTIONLENGTH(Q).
%
%   Example:
%     q = quantizer('fixed',[8 7]);
%     lsb(q)
%   returns 2^-7 = 0.0078125.
%
%   See also QUANTIZER, EMBEDDED.QUANTIZER/EPS, 
%            EMBEDDED.QUANTIZER/QUANTIZE

%   Thomas A. Bryan
%   Copyright 1999-2006 The MathWorks, Inc.

p = q.eps;
