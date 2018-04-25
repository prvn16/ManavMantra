function f = isfixed(q)
%ISFIXED True for fixed-point quantizers
%   ISFIXED(Q) returns 1 if Q is a fixed-point quantizer, and 0 otherwise.
%
%   Examples:
%     q = quantizer('double');
%     isfixed(q)
%
%     q = quantizer('ufixed');
%     isfixed(q)
%
%   See also QUANTIZER, EMBEDDED.QUANTIZER/ISFLOAT

%   Thomas A. Bryan
%   Copyright 1999-2007 The MathWorks, Inc.

switch q.mode
 case {'fixed','ufixed'}
  f = logical(1);
 otherwise
  f = logical(0);
end
