function A = dramadah(n, k, classname)
%DRAMADAH Matrix of zeros and ones with large determinant or inverse.
%   A = GALLERY('DRAMADAH',N,K) is an N-by-N nonsingular (0,1) matrix for
%   which MU(A) = NORM(INV(A),'FRO') or DET(A) is relatively large.
%
%   K = 1: (default)
%      A is Toeplitz, with ABS(DET(A)) = 1, and MU(A) > c(1.75)^N,
%      where c is a constant. INV(A) has integer entries.
%   K = 2:
%      A is upper triangular and Toeplitz. INV(A) has integer entries.
%   K = 3:
%      A has maximal determinant among (0,1) lower Hessenberg matrices.
%      DET(A) = the n'th Fibonacci number. A is Toeplitz. The eigenvalues
%      have an interesting distribution in the complex plane.
%
%   An anti-Hadamard matrix A is a nonsingular matrix with elements 0 or 1
%   for which MU(A) = NORM(INV(A),'FRO') is maximal.  For K = 1,2 this
%   function returns matrices with MU(A) relatively large, though not
%   necessarily maximal.

%   References:
%   [1] R. L. Graham and N. J. A. Sloane, Anti-Hadamard matrices,
%       Linear Algebra and Appl., 62 (1984), pp. 113-137.
%   [2] L. Ching, The maximum determinant of an nxn lower Hessenberg
%       (0,1) matrix, Linear Algebra and Appl., 183 (1993), pp. 147-153.
%
%   Nicholas J. Higham
%   Copyright 1984-2016 The MathWorks, Inc.

if isempty(k)
    k = 1;
end

if k == 1  % Toeplitz
    
    c = ones(n,1,classname);
    for i=2:4:n
        m = min(1,n-i);
        c(i:i+m) = 0;
    end
    r = zeros(n,1,classname);
    r(1:4) = [1 1 0 1];
    if n < 4
        r = r(1:n);
    end
    A = toeplitz(c,r);
    
elseif k == 2  % Upper triangular and Toeplitz
    
    c = zeros(n,1,classname);
    c(1) = 1;
    r = ones(n,1,classname);
    r(3:2:n) = 0;
    A = toeplitz(c,r);
    
elseif k == 3  % Lower Hessenberg.
    
    c = ones(n,1,classname);
    c(2:2:n) = 0;
    A = toeplitz(c, [1 1 zeros(1,n-2)]);
    
end
