function m = maxlog(q)
%MAXLOG Maximum log of quantizer object 
%   MAXLOG(Q) is the maximum value after quantization during a call to
%   QUANTIZE(Q,...) for quantizer object Q.  This value is the maximum over
%   successive calls to QUANTIZE.  Reset the maximum using RESET(Q).  
%
%   Example:
%     q = quantizer;
%     format long g
%	warning on
%     y = quantize(q,-20:10);
%     maxlog(q)
%     % returns 1-2^-15 = 0.999969482421875 and a warning for 29 overflows.
%
%   See also QUANTIZER, EMBEDDED.QUANTIZER/MAX, 
%            EMBEDDED.QUANTIZER/QUANTIZE, EMBEDDED.QUANTIZER/RESET

%   Thomas A. Bryan
%   Copyright 1999-2007 The MathWorks, Inc.

m = max(q);
