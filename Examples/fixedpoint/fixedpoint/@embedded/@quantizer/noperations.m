function n = noperations(q)
%NOPERATIONS Number of quantization operations by quantizer object
%   NOPERATIONS(Q) is the number of quantization operations during a call to
%   QUANTIZE(Q,...)  for quantizer object Q.  This value accumulates over
%   successive calls to QUANTIZE and is reset with RESET(Q).  
%
%   Example:
%     q = quantizer;
%     warning on
%     y = quantize(q,-20:10);
%     noperations(q)
%   returns 31 and a warning for 29 overflows.
%
%   See also QUANTIZER, EMBEDDED.QUANTIZER/MAX, 
%            EMBEDDED.QUANTIZER/QUANTIZE, EMBEDDED.QUANTIZER/RANGE, 
%            EMBEDDED.QUANTIZER/RESET

%   Thomas A. Bryan
%   Copyright 1999-2006 The MathWorks, Inc.

n = q.noperations;
