%SVD    Singular value decomposition.
%   [U,S,V] = SVD(X) produces a diagonal matrix S, of the same 
%   dimension as X and with nonnegative diagonal elements in
%   decreasing order, and unitary matrices U and V so that
%   X = U*S*V'.
%
%   S = SVD(X) returns a vector containing the singular values.
%
%   [U,S,V] = SVD(X,0) produces the "economy size"
%   decomposition. If X is m-by-n with m > n, then only the
%   first n columns of U are computed and S is n-by-n.
%   For m <= n, SVD(X,0) is equivalent to SVD(X).
%
%   [U,S,V] = SVD(X,'econ') also produces the "economy size"
%   decomposition. If X is m-by-n with m >= n, then it is
%   equivalent to SVD(X,0). For m < n, only the first m columns 
%   of V are computed and S is m-by-m.
%
%   See also SVDS, GSVD.

%   Copyright 1984-2005 The MathWorks, Inc.
%   Built-in function.

