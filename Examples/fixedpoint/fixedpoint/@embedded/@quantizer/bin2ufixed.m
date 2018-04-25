function y = bin2ufixed(q,b)
%BIN2UFIXED Binary string to unsigned fixed-point
%
%   Y = BIN2UFIXED(Q,B) converts an unsigned fixed-point number in
%   binary string BIN to the numerical equivalent in numeric array Y.  The
%   unsigned fixed-point is defined by quantizer object Q.  
%
%   It is assumed that B is a string array of equal length rows in binary
%   format in a single "vector" of numbers with no leading or trailing
%   blanks, and that quantizer object Q is in unsigned fixed-point mode (q.mode =
%   'ufixed'). 
%   No error checking is done.
%
%   This is a private function that is used by HEX2NUM and BIN2NUM.
%
%   Example:
%   The following would create a valid input for BIN2UFIXED.
%     q = quantizer('ufixed',[6 3]);
%     x = (1:-.25:0)';
%     b = num2bin(q,x)
%
%     % iiifff
%     % 001000  % 1
%     % 000110  % 0.75
%     % 000100  % 0.50
%     % 000010  % 0.25
%     % 000000  % 0
%
%     y = bin2ufixed(q,b)
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
% Convert to positive integers, then to unsigned fixed-point
y = bin2dec(b);
y = dec2ufixed(q,y);
