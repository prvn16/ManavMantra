function p = randperm(s, n, k)
%RANDPERM Random permutation.
%   P = RANDPERM(S,N) returns a vector containing a random permutation of the
%   integers 1:N.  RANDPERM generates the permutation by drawing values from
%   the random stream S.  For example, RANDPERM(S,6) might be [2 4 5 6 1 3].
%
%   P = RANDPERM(S,N,K) returns a row vector containing K unique integers
%   selected randomly from 1:N.  For example, RANDPERM(S,6,3) might be
%   [4 2 5].
%   
%   RANDPERM(S,N,K) returns a vector of K unique values.  This is sometimes
%   referred to as a K-permutation of 1:N or as sampling without replacement.
%   To allow repeated values in the selection, sometimes referred to as
%   sampling with replacement, use RANDI(S,N,1,K).
%
%   See also RANDPERM, NCHOOSEK, PERMS, RAND, RANDI.

%   Copyright 2008-2015 The MathWorks, Inc.

if nargin < 3
   p = builtin('_RandStream_randperm',s,n);
else
   p = builtin('_RandStream_randperm',s,n,k);   
end