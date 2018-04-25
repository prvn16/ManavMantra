function y = bin2float(q,bin);
%BIN2FLOAT Binary string to floating-point conversion
%
%   Y = BIN2FLOAT(Q,B) converts a custom-precision floating-point number in
%   binary string B to the numerical equivalent in numeric array Y.  The
%   custom-precision floating-point is defined by quantizer object Q.  
%
%   It is assumed that B is a string array of equal length rows in binary
%   format in a single "vector" of numbers with no leading or trailing
%   blanks, and that quantizer object Q is in one of the floating-point modes
%   ('float', 'single', or 'double').  No error checking is done.
%
%   If there are fewer digits than necessary to represent the number, then
%   the string is zero-padded on the left.
%
%   This is a private function that is used by HEX2NUM and BIN2NUM.
%
%   Example:
%   The following would create a valid input for BIN2FLOAT.
%     q = quantizer('float',[6 3]);
%     x = (5:-1:0)';
%     b = num2bin(q,x)
%
%     % seeeff
%     % 010101  % 5 
%     % 010100  % 4
%     % 010010  % 3
%     % 010000  % 2
%     % 001100  % 1
%     % 000000  % 0
%
%     y = bin2float(q,b)
%
%     % x and y should be the same
%     [x y]

%   Thomas A. Bryan
%   Copyright 1999-2006 The MathWorks, Inc.

if isempty(bin)
  y = 0;
  return
end

% Zero pad to the right.
w = wordlength(q);
[mbin,nbin] = size(bin);
if nbin<w
  % Zero-pad to the right.
  o = '0';
  bin = [bin,o(ones(mbin,1),ones(w-nbin,1))];
end

% Peel off [sign, exponent, fraction]
% Then, each piece is small enough to be a positive integer

% Sign
s = (-1).^bin2dec(bin(:,1));

% Unbiased exponent
e = bin2dec(bin(:,2:exponentlength(q)+1));

% Biased exponent
b = e - exponentbias(q);

% Fraction
f = pow2(bin2dec(bin(:,exponentlength(q)+2:end)),-fractionlength(q));

% Initialize the output.  Zero is the default, so 
y = zeros(size(s));

% Denormal
n = e==0 & f~=0;
y(n) = s(n).*pow2(f(n),exponentmin(q));

% Normal
n = e~=0 & b<=exponentmax(q);
y(n) = s(n).*pow2(1+f(n),b(n));

% NaN
n = b==exponentmax(q)+1 & f~=0;
y(n) = nan;

% +-inf
n = b==exponentmax(q)+1 & f==0;
y(n) = s(n).*inf;

