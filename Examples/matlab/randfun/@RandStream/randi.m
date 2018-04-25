function R = randi(s, imax, m, n, varargin)
%RANDI Pseudorandom integers from a uniform discrete distribution.
%   R = RANDI(S,IMAX,N) returns an N-by-N matrix containing pseudorandom
%   integer values drawn from the discrete uniform distribution on 1:IMAX.
%   RANDI draws those values from the random stream S.  RANDI(S,IMAX,M,N) or
%   RANDI(S,IMAX,[M,N]) returns an M-by-N matrix.  RANDI(S,IMAX,M,N,P,...)
%   or RANDI(S,IMAX,[M,N,P,...]) returns an M-by-N-by-P-by-... array.
%   RANDI(S,IMAX) returns a scalar.  RANDI(S,IMAX,SIZE(A)) returns an array
%   the same size as A.
%
%   R = RANDI(S,[IMIN,IMAX],...) returns an array containing integer
%   values drawn from the discrete uniform distribution on IMIN:IMAX.
%
%   Note: The size inputs M, N, P, ... should be nonnegative integers.
%   Negative integers are treated as 0.
%
%   R = RANDI(..., CLASSNAME) returns an array of integer values of class
%   CLASSNAME.
%
%   The arrays returned by RANDI may contain repeated integer values.  This
%   is sometimes referred to as sampling with replacement.  To get unique
%   integer values, sometimes referred to as sampling without replacement,
%   use RANDPERM.
%
%   The sequence of numbers produced by RANDI is determined by the internal
%   state of the random stream S.  RANDI uses one uniform value from S to
%   generate each integer value.  Control S using its RESET method and its
%   properties.
%
%   See also RANDI, RANDSTREAM, RANDSTREAM/RAND, RANDSTREAM/RANDN, RANDSTREAM/RANDPERM.

%   Copyright 2008-2015 The MathWorks, Inc. 

if nargin < 3
   R = builtin('_RandStream_randi',s,imax);
elseif nargin < 4
   R = builtin('_RandStream_randi',s,imax,m);
elseif nargin < 5
   R = builtin('_RandStream_randi',s,imax,m,n);   
else
   R = builtin('_RandStream_randi',s,imax,m,n,varargin{1:end});
end
