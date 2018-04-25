function [q,r]=deconv(b,a)
%DECONV Deconvolution and polynomial division.
%   [Q,R] = DECONV(B,A) deconvolves vector A out of vector B.  The result
%   is returned in vector Q and the remainder in vector R such that
%   B = conv(A,Q) + R.
%
%   If A and B are vectors of polynomial coefficients, deconvolution
%   is equivalent to polynomial division.  The result of dividing B by
%   A is quotient Q and remainder R.
%
%   Class support for inputs B,A:
%      float: double, single
%
%   See also CONV, RESIDUE.

%   Copyright 1984-2012 The MathWorks, Inc.

if a(1)==0
    error(message('MATLAB:deconv:ZeroCoef1'))
end
[mb,nb] = size(b);
nb = max(mb,nb);
na = length(a);
if na > nb
   q = zeros(superiorfloat(b,a));
   r = cast(b,class(q));
else
   % Deconvolution and polynomial division are the same operations
   % as a digital filter's impulse response B(z)/A(z):
   [q,zf] = filter(b, a, [1 zeros(1,nb-na)]);
   if mb ~= 1
      q = q(:);
   end
   if nargout > 1
      r = zeros(size(b),class(q));
      lq = length(q);
      r(lq+1:end) = a(1)*zf(1:nb-lq);
   end
end
