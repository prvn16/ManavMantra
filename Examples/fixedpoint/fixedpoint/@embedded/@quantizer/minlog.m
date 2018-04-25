function m = minlog(q)
%MINLOG Minimum log of quantizer object
%   MINLOG(Q) is the minimum value after quantization during a call to
%   QUANTIZE(Q,...) for quantizer object Q.  This value is the minimum over
%   successive calls to QUANTIZE.  Reset the minimum using RESET(Q).  
%
%   Example:
%     q = quantizer;
%     warning on
%     y = quantize(q,-20:10);
%     minlog(q)
%     % returns -1 and a warning for 29 overflows.
%
%   See also QUANTIZER, EMBEDDED.QUANTIZER/MAX, 
%            EMBEDDED.QUANTIZER/QUANTIZE, EMBEDDED.QUANTIZER/RESET

%   Thomas A. Bryan
%   Copyright 1999-2007 The MathWorks, Inc.

m = min(q);
