function L = leslie(a,b,classname)
%LESLIE  Leslie matrix.
%   GALLERY('LESLIE',A,B) is the N-by-N matrix from the Leslie
%   population model with average birth numbers A(1:N) and
%   survival rates B(1:N-1).  It is zero, apart from on the first row
%   (which contains the A(I)) and the first subdiagonal (which contains
%   the B(I)).  For a valid model, the A(I) are nonnegative and the
%   B(I) are positive and bounded by 1.
%
%   GALLERY('LESLIE',N) generates the Leslie matrix with A = ONES(N,1),
%   B = ONES(N-1,1).

%   References:
%   [1] M. R. Cullen, Linear Models in Biology, Ellis Horwood,
%       Chichester, UK, 1985.
%   [2] H. Anton and C. Rorres, Elementary Linear Algebra: Applications
%       Version, eighth edition, Wiley, New York, 2000, Sec. 11.18.
%
%   Nicholas J. Higham
%   Copyright 1984-2005 The MathWorks, Inc.

if isempty(b)
   n = a;
   a = ones(n,1,classname);
   b = ones(n-1,1,classname);
end

if length(a) ~= length(b) + 1
  error(message('MATLAB:leslie:ArgSize'))
end

L = diag(b,-1);
L(1,:) = a(:)';
