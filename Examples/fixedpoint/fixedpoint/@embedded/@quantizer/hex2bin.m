function b = hex2bin(q,h)
%HEX2BIN Convert hexadecimal strings to binary strings
%
%   B = HEX2BIN(Q,H) converts hexadecimal strings vectorized in a column H to
%   binary strings B.  The wordlength is derived from quantizer Q.  This is a
%   private function that is used by NUM2BIN.
%
%   Example:
%     q = quantizer('fixed',[8 7]);
%     h = ['ff'; 'fe'];
%     b = hex2bin(q,h)
%
%   See also QUANTIZER

%   Thomas A. Bryan
%   Copyright 1999-2006 The MathWorks, Inc.

[m,n]=size(h);
if n>8
  % If there are more than 32 bits, split the words so that the decimal value
  % does not go out of range of the positive integers
  b = [dec2bin(hex2dec(h(:,1:8)),32), dec2bin(hex2dec(h(:,9:end)),(n-8)*4)];
else
  b = dec2bin(hex2dec(h),n*4);
end

% The hex representation may have implied extra bits to fill out a hex
% digit, so strip those off.
w = wordlength(q);
b = b(:,end-w+1:end);
