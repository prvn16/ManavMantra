function m = min(q)
%MIN    Min of quantizer object
%   MIN(Q) is the minimum value before quantization during a call to
%   QUANTIZE(Q,...) for quantizer object Q.  This value is the min over
%   successive calls to QUANTIZE and is reset with RESET(Q).  
%
%   Example:
%     q = quantizer;
%     warning on
%     y = quantize(q,-20:10);
%     min(q)
%   returns -20 and a warning for 29 overflows.
%
%   See also QUANTIZER, EMBEDDED.QUANTIZER/GET, 
%            EMBEDDED.QUANTIZER/MAX, EMBEDDED.QUANTIZER/QUANTIZE,
%            EMBEDDED.QUANTIZER/RESET 

%   Thomas A. Bryan
%   Copyright 1999-2006 The MathWorks, Inc.

if q.max>=q.min
  m = q.min;
else
  m = 'reset';
end

