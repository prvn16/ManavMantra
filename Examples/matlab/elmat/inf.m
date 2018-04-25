%INF Infinity.       
%   INF returns the IEEE arithmetic representation for positive
%   infinity.  Infinity is also produced by operations like dividing by
%   zero, eg. 1.0/0.0, or from overflow, eg. exp(1000).
%
%   INF('double') is the same as INF with no inputs.
%
%   INF('single') is the single precision representation of INF.
%
%   INF(N) is an N-by-N matrix of INFs.
%
%   INF(M,N) or INF([M,N]) is an M-by-N matrix of INFs.
%
%   INF(M,N,P,...) or INF([M,N,P,...]) is an M-by-N-by-P-by-... array of INFs.
%
%   INF(..., CLASSNAME) is an array of INFs of class specified by the 
%   string CLASSNAME. CLASSNAME can be either 'single' or 'double'.
%
%   INF(..., 'like', Y) is an array of INFs with the same data type, sparsity,
%   and complexity (real or complex) as the single or double precision numeric 
%   variable Y.
%
%   Note: The size inputs M, N, and P... should be nonnegative integers. 
%   Negative integers are treated as 0.
%
%   See also NAN, ISINF, ISFINITE, ISFLOAT.

%   Copyright 1984-2013 The MathWorks, Inc.
%   Built-in function.

