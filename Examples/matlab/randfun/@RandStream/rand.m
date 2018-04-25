function R = rand(s, m, n, varargin)
%RAND Pseudorandom numbers from a uniform distribution.
%   R = RAND(S,N) returns an N-by-N matrix containing pseudorandom values drawn
%   from the standard uniform distribution on the open interval(0,1).  RAND
%   draws those values from the random stream S.  RAND(S,M,N) or RAND(S,[M,N])
%   returns an M-by-N matrix. RAND(S,M,N,P,...) or RAND(S,[M,N,P,...]) returns
%   an M-by-N-by-P-by-... array.  RAND(S) returns a scalar.  RAND(S,SIZE(A))
%   returns an array the same size as A.
%
%   Note: The size inputs M, N, P, ... should be nonnegative integers.
%   Negative integers are treated as 0.
%
%   R = RAND(..., 'double') or R = RAND(..., 'single') returns an array of
%   uniform values of the specified class.
%
%   The sequence of numbers produced by RAND is determined by the internal state
%   of the random number stream S.  Control S using its RESET method and its
%   properties.
%
%   See also RAND, RANDSTREAM, RANDSTREAM/RANDI, RANDSTREAM/RANDN, RANDSTREAM/RANDPERM.

%   Copyright 2008-2015 The MathWorks, Inc. 

if nargin < 2
   R = builtin('_RandStream_rand',s);
elseif nargin < 3
   R = builtin('_RandStream_rand',s,m);
elseif nargin < 4
   R = builtin('_RandStream_rand',s,m,n);   
else
   R = builtin('_RandStream_rand',s,m,n,varargin{1:end});
end