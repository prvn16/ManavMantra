function y = numeric2hex(q,x);
%NUMERIC2HEX Number to hexadecimal string conversion
%   H = NUMERIC2HEX(Q,X) converts numeric matrix X to hexadecimal string H.
%   The attributes of the number are specified by Quantizer object Q.
%   The fixed-point hexadecimal representation is two's complement.  The
%   floating-point hexadecimal representation is IEEE style.
%
%   NUMERIC2HEX and HEX2NUM are inverses of each other.
%
%   For example, all of the 4-bit fixed-point two's complement numbers in
%   fractional form are given by:
%     q = quantizer([4 3]);
%     x = [0.875    0.375   -0.125   -0.625
%          0.750    0.250   -0.250   -0.750
%          0.625    0.125   -0.375   -0.875
%          0.500        0   -0.500   -1.000];
%     h = numeric2hex(q,x)
%
%   See also QUANTIZER, EMBEDDED.QUANTIZER/HEX2NUM, 
%            EMBEDDED.QUANTIZER/BIN2NUM, EMBEDDED.QUANTIZER/NUM2BIN,
%            EMBEDDED.QUANTIZER/NUMERIC2BIN

%   Thomas A. Bryan
%   Copyright 1999-2006 The MathWorks, Inc.
if isreal(x)
  y = num2base(q,x,16);
else
  % In the complex case, we have to interleave the real and complex parts.
  yr = num2base(q,real(x),16);
  yi = num2base(q,imag(x),16);
  p = ' + ';
  i = 'i';
  tony = ones(numel(x),1);
  y = [yr,p(tony,1:end),yi,i(tony,1:end)];
end
y=stringreshape(q,y,size(x));
% Remove trailing blanks
y = deblank(y);
