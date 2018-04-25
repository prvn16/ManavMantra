function m = mode(q)
%MODE   Mode of a quantizer object
%   MODE(Q) returns the mode of quantizer object Q.  The mode of a quantizer
%   object can be one of the strings:
%
%     double -  Double precision IEEE floating point.
%     fixed  -  Signed fixed-point in two's complement format.
%     float  -  Custom-precision floating-point.
%     none   -  No quantization is done.  Pass through input to output.
%     single -  Single precision IEEE floating point.
%     ufixed -  Unsigned fixed-point.
%
%   Example:
%     q = quantizer;
%     mode(q)
%   returns the default 'fixed'.
%
%   See also QUANTIZER, EMBEDDED.QUANTIZER/GET, EMBEDDED.QUANTIZER/SET

%   Thomas A. Bryan
%   Copyright 1999-2006 The MathWorks, Inc.

m = get(q,'mode');



