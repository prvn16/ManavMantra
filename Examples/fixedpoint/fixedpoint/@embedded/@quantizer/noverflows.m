function n = noverflows(q)
%NOVERFLOWS Number of overflows of quantizer object
%   NOVERFLOWS(Q) is the number of overflows during a call to QUANTIZE(Q,...)
%   for quantizer object Q.  This value accumulates over successive calls to
%   QUANTIZE and is reset with RESET(Q).  An overflow is defined as a value,
%   that when quantized, is outside the range of Q.
%
%   Example:
%     q = quantizer;
%     warning on
%     y = quantize(q,-20:10);
%     noverflows(q)
%   returns 29 and a warning for 29 overflows.
%
%   See also QUANTIZER, EMBEDDED.QUANTIZER/MAX,
%            EMBEDDED.QUANTIZER/QUANTIZE, EMBEDDED.QUANTIZER/RANGE,
%            EMBEDDED.QUANTIZER/RESET 

%   Thomas A. Bryan
%   Copyright 1999-2006 The MathWorks, Inc.

n = q.noverflows;
