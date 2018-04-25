function C = compar(A,k,classname)
%COMPAR Comparison matrices.
%   GALLERY('COMPAR',A) is DIAG(B) - TRIL(B,-1) - TRIU(B,1),
%   where B = ABS(A). GALLERY('COMPAR',A) is often denoted by M(A)
%   in the literature.
%
%   GALLERY('COMPAR',A,1) is a modified version of A with each
%   diagonal element replaced by its absolute value and each
%   off-diagonal element replaced by minus the absolute value of the
%   largest off-diagonal element in absolute value in its row.
%   However, if A is triangular, GALLERY('COMPAR',A,1) is too.

%   Reference:
%   N. J. Higham, Accuracy and Stability of Numerical Algorithms,
%   Second edition, Society for Industrial and Applied Mathematics,
%   Philadelphia, 2002, Chap. 8.
%
%   Nicholas J. Higham
%   Copyright 1984-2005 The MathWorks, Inc.

%   CLASSNAME is not used, but is passed by GALLERY.
%   GALLERY changes class of A as necessary.

if isempty(k), k = 0; end
[m,n] = size(A);

if k == 0

% This code uses less temporary storage than the `high level' definition above.
   C = -abs(A);
   C(1:m+1:end) = abs(diag(A));

elseif k == 1

   mx = max(abs(A - diag(diag(A))),[],2);
   C = -mx(:,ones(1,n));
   C(1:m+1:end) = abs(diag(A));
   if isequal(A,tril(A)), C = tril(C); end
   if isequal(A,triu(A)), C = triu(C); end

end
