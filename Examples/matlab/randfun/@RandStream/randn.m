function R = randn(s, m, n, varargin)
%RANDN Pseudorandom numbers from a standard normal distribution.
%   R = RANDN(S,N) returns an N-by-N matrix containing pseudorandom values drawn
%   from the standard normal distribution.  RANDN draws those values from the
%   random stream S.  RANDN(S,M,N) or RANDN(S,[M,N]) returns an M-by-N matrix.
%   RANDN(S,M,N,P,...) or RANDN(S,[M,N,P,...]) returns an M-by-N-by-P-by-...
%   array.  RANDN(S) returns a scalar.  RANDN(S,SIZE(A)) returns an array the
%   same size as A.
%
%   Note: The size inputs M, N, P, ... should be nonnegative integers.
%   Negative integers are treated as 0.
%
%   R = RANDN(..., 'double') or R = RANDN(..., 'single') returns an array of
%   normal values of the specified class.
%
%   The sequence of numbers produced by RANDN is determined by the internal
%   state of the random stream S.  RANDN uses one or more uniform values from S
%   to generate each normal value.  Control S using its RESET method and its
%   properties.
%
%   See also RANDN, RANDSTREAM, RANDSTREAM/RAND, RANDSTREAM/RANDI.

%   Copyright 2008-2015 The MathWorks, Inc. 

if nargin < 2
   R = builtin('_RandStream_randn',s);
elseif nargin < 3
   R = builtin('_RandStream_randn',s,m);
elseif nargin < 4
   R = builtin('_RandStream_randn',s,m,n);   
else
   R = builtin('_RandStream_randn',s,m,n,varargin{1:end});
end