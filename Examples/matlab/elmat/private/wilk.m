function [A, b] = wilk(n,classname)
%WILK   Various specific matrices devised/discussed by Wilkinson.
%   [A, b] = GALLERY('WILK',N) is the matrix or system of order N,
%   where N is one of the following:
%
%   N = 3: upper triangular system Ux=b. Inaccurate solution.
%   N = 4: lower triangular system Lx=b. Ill-conditioned.
%   N = 5: HILB{6}(1:5,2:6)*1.8144. Symmetric positive definite.
%   N = 21: W21+, tridiagonal. Eigenvalue problem.

%   References:
%   [1] J. H. Wilkinson, Error analysis of direct methods of matrix
%       inversion, J. Assoc. Comput. Mach., 8 (1961),  pp. 281-330.
%   [2] J. H. Wilkinson, Rounding Errors in Algebraic Processes,
%       Notes on Applied Science No. 32, Her Majesty's Stationery
%       Office, London, 1963. Reprinted by Dover, New York, 1994.
%   [3] J. H. Wilkinson, The Algebraic Eigenvalue Problem,
%       Oxford University Press, 1965.
%
%   Nicholas J. Higham
%   Copyright 1984-2005 The MathWorks, Inc.

if n == 3
   % Wilkinson (1961) p.323.
   A = [ 1e-10   .9  -.4
           0     .9  -.4
           0      0  1e-10];
   b = [   0      0    1]';
   A = cast(A,classname); b = cast(b,classname);

elseif n == 4
   % Wilkinson (1963) p.105.
   A = [0.9143e-4  0          0          0
        0.8762     0.7156e-4  0          0
        0.7943     0.8143     0.9504e-4  0
        0.8017     0.6123     0.7165     0.7123e-4];
   b = [0.6524     0.3127     0.4186     0.7853]';
   A = cast(A,classname); b = cast(b,classname);

elseif n == 5
   % Wilkinson (1965), p.234.
   if nargout > 1
       error(message('MATLAB:wilk:TooManyOutputsForFive'));
   end
   A = hilb(6,classname);
   A = A(1:5, 2:6)*1.8144;

elseif n == 21
   % Wilkinson [3], p. 308.
   if nargout > 1
       error(message('MATLAB:wilk:TooManyOutputsForTwentyOne'));
   end
   E = diag(ones(n-1,1,classname),1);
   m = (n-1)/2;
   A = diag(abs(-m:m)) + E + E';

else
   error(message('MATLAB:wilk:InvalidN'))
end
