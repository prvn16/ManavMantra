function [A, detA] = ipjfact(n, k, classname)
%IPJFACT Hankel matrix with factorial elements.
%   [A,D] = GALLERY('IPJFACT',N,K) returns A, an N-by-N
%   Hankel matrix and D, the determinant of A, which is
%   known explicity.
%
%   If K = 0 (the default), then the elements of A are
%      A(i,j) = (i+j)!
%   If K = 1, then the elements of A are
%      A(i,j) = 1/(i+j)!

%   Note: The inverse of A is also known explicitly.
%   Acknowledgement: Suggested by P. R. Graves-Morris.
%
%   Reference:
%   M. J. C. Gover, The explicit inverse of factorial Hankel
%   matrices, Dept. of Mathematics, University of Bradford, 1993.
%
%   Nicholas J. Higham
%   Copyright 1984-2005 The MathWorks, Inc.

if isempty(k), k = 0; end

c = cumprod(2:n+1);
d = cumprod(n+1:2*n) * c(n-1);

A = cast(hankel(c, d),classname);

if k == 1
   A = ones(n,classname)./A;
end

if nargout == 2
   d = 1;
   if k == 0
      for i=1:n-1
          d = d*prod(1:i+1)*prod(1:n-i);
      end
      d = d*prod(1:n+1);
   else
      for i=0:n-1
          d = d*prod(1:i)/prod(1:n+1+i);
      end
      if rem(n*(n-1)/2,2), d = -d; end
   end
   detA = d;
end
