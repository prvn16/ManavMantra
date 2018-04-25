function y = hex2fixed(q,x)
%HEX2FIXED Hex string to fixed-point
%
%   Y = HEX2FIXED(Q,H) converts a fixed-point number in
%   hex string H to the numerical equivalent in numeric array Y.  The
%   fixed-point is defined by quantizer object Q.  
%
%   It is assumed that H is a string array of equal length rows in hex
%   format in a single "vector" of numbers with no leading or trailing
%   blanks, and that quantizer object Q is in fixed-point mode (q.mode = 'fixed').
%   No error checking is done.
%
%   This is a private function that is used by HEX2NUM.
%
%   Example:
%   The following would create a valid input for HEX2FIXED.
%
%     q = quantizer('fixed',[6 3]);
%     x = (1:-.25:0)';
%     h = num2hex(q,x)
%   
%     % 08 % 1
%     % 06 % 0.75
%     % 04 % 0.50
%     % 02 % 0.25
%     % 00 % 0
%
%     y = hex2fixed(q,h);
%
%     % x and y should be the same
%     [x y]
%
%   See also QUANTIZER

%   Thomas A. Bryan
%   Copyright 1999-2006 The MathWorks, Inc.

if isempty(x)
  y = 0;
  return
end
% Convert to positive integers, then to fixed-point
y = hex2dec(x);
y = dec2fixed(q,y);
