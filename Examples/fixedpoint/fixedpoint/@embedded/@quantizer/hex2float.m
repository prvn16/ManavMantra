function y = hex2float(q,x)
%HEX2FLOAT Hex string to floating-point
%
%   Y = HEX2FLOAT(Q,H) converts a floating-point number in
%   hex string H to the numerical equivalent in numeric array Y.  The
%   floating-point is defined by quantizer object Q.  
%
%   It is assumed that H is a string array of equal length rows in hex
%   format in a single "vector" of numbers with no leading or trailing
%   blanks, and that quantizer object Q is in floating-point mode (q.mode = 'float'
%   or 'single' or 'double').
%   No error checking is done.
%
%   If there are fewer digits than necessary to represent the number, then
%   the string is zero-padded on the left.
%
%   This is a private function that is used by HEX2NUM.
%
%   Example:
%   The following would create a valid input for HEX2FLOAT.
%
%     q = quantizer('float',[6 3]);
%     x = (1:-.25:0)';
%     h = num2hex(q,x)
%   
%     % 0c % 1
%     % 0a % 0.75
%     % 08 % 0.50
%     % 04 % 0.25
%     % 00 % 0
%
%     y = hex2float(q,h);
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

[m,n]=size(x);
w = wordlength(q);
w4 = ceil(w/4);
if n<w4
  % Zero-pad to the right.
  o = '0';
  x = [x,o(ones(m,1),ones(w4-n,1))];
end
y = base2num(q,x,16);

