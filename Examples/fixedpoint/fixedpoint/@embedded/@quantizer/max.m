function m = max(q)
%MAX    Max of quantizer object
%   MAX(Q) is the maximum value before quantization during a call to
%   QUANTIZE(Q,...) for quantizer object Q.  This value is the max over
%   successive calls to QUANTIZE and is reset with RESET(Q).  
%
%   Example:
%     q = quantizer;
%     warning on
%     y = quantize(q,-20:10);
%     max(q)
%   returns 10 and a warning for 29 overflows.
%
%   See also QUANTIZER, EMBEDDED.QUANTIZER/GET, 
%            EMBEDDED.QUANTIZER/MIN, EMBEDDED.QUANTIZER/QUANTIZE,
%            EMBEDDED.QUANTIZER/RESET 

%   Thomas A. Bryan
%   Copyright 1999-2006 The MathWorks, Inc.


if q.max>=q.min
  m = q.max;
else
  m = 'reset';
end

