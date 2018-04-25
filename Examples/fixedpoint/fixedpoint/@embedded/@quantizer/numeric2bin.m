function y = numeric2bin(q,x);
%NUMERIC2BIN Numeric matrix to binary strings
%   B = NUMERIC2BIN(Q,X) converts numeric matrix X to binary string B.
%   The attributes of the number are specified by quantizer object Q.
%   The fixed-point binary representation is two's complement.  The
%   floating-point binary representation is IEEE style.
%
%   NUMERIC2BIN and BIN2NUM are inverses of each other.
%
%   For example, all of the 3-bit fixed-point two's complement numbers in
%   fractional form are given by:
%     q = quantizer([3 2]);
%     x = [0.75   -0.25
%          0.50   -0.50
%          0.25   -0.75
%          0      -1   ];
%     b = numeric2bin(q,x)
%
%   See also QUANTIZER, EMBEDDED.QUANTIZER/BIN2NUM, 
%            EMBEDDED.QUANTIZER/HEX2NUM, QUANTIZER/NUM2HEX,
%            QUANTIZER/NUMERIC2HEX

%   Thomas A. Bryan
%   Copyright 1999-2006 The MathWorks, Inc.
if isreal(x)
  y = num2base(q,x,2);
else
  yr = num2base(q,real(x),2);
  yi = num2base(q,imag(x),2);
  p = ' + ';
  i = 'i';
  tony = ones(numel(x),1);
  y = [yr,p(tony,1:end),yi,i(tony,1:end)];
end
y=stringreshape(q,y,size(x));
% Remove trailing blanks
y = deblank(y);
