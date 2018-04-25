function y = bin2fixed(q,b)
%BIN2FIXED Binary string to signed fixed-point conversion 
%
%   Y = BIN2FIXED(Q,B) converts a signed fixed-point number in
%   binary string B to the numerical equivalent in numeric array Y.  The
%   signed fixed-point is defined by quantizer object Q.  
%
%   It is assumed that B is a string array of equal length rows in binary
%   format in a single "vector" of numbers with no leading or trailing
%   blanks, and that quantizer object Q is in signed fixed-point mode (q.mode =
%   'fixed'). 
%   No error checking is done.
%
%   This is a private function that is used by HEX2NUM and BIN2NUM.
%
%   Example:
%   The following would create a valid input for BIN2FIXED.
%     q = quantizer('fixed',[6 3]);
%     x = (1:-.25:0)';
%     b = num2bin(q,x)
%
%     % siifff
%     % 001000  % 1
%     % 000110  % 0.75
%     % 000100  % 0.50
%     % 000010  % 0.25
%     % 000000  % 0
%
%     y = bin2fixed(q,b)
%
%     % x and y should be the same
%     [x y]
%
%   See also QUANTIZER

%   Thomas A. Bryan
%   Copyright 1999-2006 The MathWorks, Inc.

if isempty(b)
  y = 0;
  return
end
% Convert to positive integers, then to signed fixed-point
y = bin2dec(b);
y = dec2fixed(q,y);
