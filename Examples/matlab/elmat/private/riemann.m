function A = riemann(n,classname)
%RIEMANN Matrix associated with the Riemann hypothesis.
%   A = GALLERY('RIEMANN',N) is an N-by-N matrix for which the
%   Riemann hypothesis is true if and only if
%      DET(A) = O( N! N^(-1/2+epsilon) ), for every epsilon > 0.
%
%   A = B(2:N+1, 2:N+1), where
%      B(i,j) = i-1 if i divides j, and -1 otherwise.
%
%   Properties include, with M = N+1:
%      Each eigenvalue E(i) satisfies ABS(E(i)) <= M - 1/M.
%      i <= E(i) <= i+1 with at most M-SQRT(M) exceptions.
%      All integers in the interval (M/3, M/2] are eigenvalues.
%
%   See also PRIVATE/REDHEFF

%   Reference:
%   F. Roesler, Riemann's hypothesis as an eigenvalue problem,
%   Linear Algebra and Appl., 81 (1986), pp. 153-198.
%
%   Nicholas J. Higham
%   Copyright 1984-2015 The MathWorks, Inc.

n = n+1;
i = (2:cast(n,classname))'; 
A = i .* ~rem(i', i) - 1;
