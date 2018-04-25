%RANDPERM Random permutation.
%   P = RANDPERM(N) returns a vector containing a random permutation of the
%   integers 1:N.  For example, RANDPERM(6) might be [2 4 5 6 1 3].
%
%   P = RANDPERM(N,K) returns a row vector containing K unique integers
%   selected randomly from 1:N.  For example, RANDPERM(6,3) might be [4 2 5].
%   
%   RANDPERM(N,K) returns a vector of K unique values.  This is sometimes
%   referred to as a K-permutation of 1:N or as sampling without replacement.
%   To allow repeated values in the selection, sometimes referred to as
%   sampling with replacement, use RANDI(N,1,K).
%
%   RANDPERM calls RAND and therefore changes the state of the random number
%   generator that underlies RAND, RANDI, and RANDN.  Control that shared
%   generator using RNG.
%
%   See also NCHOOSEK, PERMS, RAND, RANDI, RNG.

%   Copyright 1984-2011 The MathWorks, Inc.
