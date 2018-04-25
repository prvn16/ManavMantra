function W = wilkinson(n,classname)
%WILKINSON Wilkinson's eigenvalue test matrix.
%   W = WILKINSON(n) is J. H. Wilkinson's eigenvalue test matrix, Wn+. It
%   is a symmetric, tridiagonal matrix with pairs of nearly, but not
%   exactly, equal eigenvalues. The most frequently used case is
%   WILKINSON(21).
%
%   W = WILKINSON(n,CLASSNAME) returns a matrix of class CLASSNAME, which
%   can be either 'single' or 'double' (the default).
%
%   Example:
%
%   WILKINSON(7) is
%
%          3  1  0  0  0  0  0
%          1  2  1  0  0  0  0
%          0  1  1  1  0  0  0
%          0  0  1  0  1  0  0
%          0  0  0  1  1  1  0
%          0  0  0  0  1  2  1
%          0  0  0  0  0  1  3

%   Copyright 1984-2017 The MathWorks, Inc.

if nargin < 2
   classname = 'double';
end
if isstring(classname) && isscalar(classname)
   classname = char(classname);
end

m = cast((n-1)/2,classname);
e = ones(n-1,1,classname);
W = diag(abs(-m:m)) + diag(e,1) + diag(e,-1);
