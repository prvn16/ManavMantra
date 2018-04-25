function f = isnone(q)
%ISNONE True for quantizers whose quantization mode is 'none'
%   ISNONE(Q) returns 1 if Q is a quantizer whose mode is 'none' and 0
%   otherwise.  
%
%   Examples:
%     q = quantizer('none');
%     isnone(q)
%
%     q = quantizer('double');
%     isnone(q)
%
%   See also QUANTIZER, EMBEDDED.QUANTIZER/ISFIXED, 
%            EMBEDDED.QUANTIZER/ISFLOAT

%   Thomas A. Bryan
%   Copyright 1999-2006 The MathWorks, Inc.

switch q.mode
 case 'none'
  f = logical(1);
 otherwise
  f = logical(0);
end
