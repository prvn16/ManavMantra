function varargout = gallery(matname,varargin)
%GALLERY Higham test matrices.
%   [out1,out2,...] = GALLERY(matname, param1, param2, ...)
%   takes matname, a string that is the name of a matrix family, and
%   the family's input parameters. See the listing below for available
%   matrix families. Most of the functions take an input argument
%   that specifies the order of the matrix, and unless otherwise
%   stated, return a single output.
%
%   GALLERY(matname,param1, param2, ..., CLASSNAME) produces a matrix
%   of class CLASSNAME, which must be either 'single' or 'double' (unless
%   matname is 'integerdata', in which case 'int8', 'int16', 'int32',
%   'uint8', 'uint16', and 'uint32' are also allowed.)
%   If CLASSNAME is not specified then the class of the matrix is
%   determined from those arguments among param 1, param2, ..., that do
%   not specify dimensions or select an option:
%   if any of these arguments is of class single then the matrix is
%   single; otherwise the matrix is double.
%
%   For additional information, type "help private/matname", where matname
%   is the name of the matrix family.
%
%   binomial    Binomial matrix -- multiple of involutory matrix.
%   cauchy      Cauchy matrix.
%   chebspec    Chebyshev spectral differentiation matrix.
%   chebvand    Vandermonde-like matrix for the Chebyshev polynomials.
%   chow        Chow matrix -- a singular Toeplitz lower Hessenberg matrix.
%   circul      Circulant matrix.
%   clement     Clement matrix -- tridiagonal with zero diagonal entries.
%   compar      Comparison matrices.
%   condex      Counter-examples to matrix condition number estimators.
%   cycol       Matrix whose columns repeat cyclically.
%   dorr        Dorr matrix -- diagonally dominant, ill-conditioned, tridiagonal.
%               (One or three output arguments, sparse)
%   dramadah    Matrix of ones and zeroes whose inverse has large integer entries.
%   fiedler     Fiedler matrix -- symmetric.
%   forsythe    Forsythe matrix -- a perturbed Jordan block.
%   frank       Frank matrix -- ill-conditioned eigenvalues.
%   gcdmat      GCD matrix.
%   gearmat     Gear matrix.
%   grcar       Grcar matrix -- a Toeplitz matrix with sensitive eigenvalues.
%   hanowa      Matrix whose eigenvalues lie on a vertical line in the complex
%               plane.
%   house       Householder matrix. (Three output arguments)
%   integerdata Array of arbitrary data from uniform distribution on
%               specified range of integers
%   invhess     Inverse of an upper Hessenberg matrix.
%   invol       Involutory matrix.
%   ipjfact     Hankel matrix with factorial elements. (Two output arguments)
%   jordbloc    Jordan block matrix.
%   kahan       Kahan matrix -- upper trapezoidal.
%   kms         Kac-Murdock-Szego Toeplitz matrix.
%   krylov      Krylov matrix.
%   lauchli     Lauchli matrix -- rectangular.
%   lehmer      Lehmer matrix -- symmetric positive definite.
%   leslie      Leslie matrix.
%   lesp        Tridiagonal matrix with real, sensitive eigenvalues.
%   lotkin      Lotkin matrix.
%   minij       Symmetric positive definite matrix MIN(i,j).
%   moler       Moler matrix -- symmetric positive definite.
%   neumann     Singular matrix from the discrete Neumann problem (sparse).
%   normaldata  Array of arbitrary data from standard normal distribution
%   orthog      Orthogonal and nearly orthogonal matrices.
%   parter      Parter matrix -- a Toeplitz matrix with singular values near PI.
%   pei         Pei matrix.
%   poisson     Block tridiagonal matrix from Poisson's equation (sparse).
%   prolate     Prolate matrix -- symmetric, ill-conditioned Toeplitz matrix.
%   qmult       Pre-multiply matrix by random orthogonal matrix.
%   randcolu    Random matrix with normalized cols and specified singular values.
%   randcorr    Random correlation matrix with specified eigenvalues.
%   randhess    Random, orthogonal upper Hessenberg matrix.
%   randjorth   Random J-orthogonal (hyperbolic, pseudo-orthogonal) matrix.
%   rando       Random matrix with elements -1, 0 or 1.
%   randsvd     Random matrix with pre-assigned singular values and specified
%               bandwidth.
%   redheff     Matrix of 0s and 1s of Redheffer.
%   riemann     Matrix associated with the Riemann hypothesis.
%   ris         Ris matrix -- a symmetric Hankel matrix.
%   sampling    Nonsymmetric matrix with integer, ill conditioned eigenvalues.
%   smoke       Smoke matrix -- complex, with a "smoke ring" pseudospectrum.
%   toeppd      Symmetric positive definite Toeplitz matrix.
%   toeppen     Pentadiagonal Toeplitz matrix (sparse).
%   tridiag     Tridiagonal matrix (sparse).
%   triw        Upper triangular matrix discussed by Wilkinson and others.
%   uniformdata Array of arbitrary data from standard uniform distribution
%   wathen      Wathen matrix -- a finite element matrix (sparse, random entries).
%   wilk        Various specific matrices devised/discussed by Wilkinson.
%               (Two output arguments)
%
%   GALLERY(3) is a badly conditioned 3-by-3 matrix.
%   GALLERY(5) is an interesting eigenvalue problem.  Try to find
%   its EXACT eigenvalues and eigenvectors.
%
%   See also MAGIC, HILB, INVHILB, HADAMARD, PASCAL, ROSSER, VANDER, WILKINSON.

%   References:
%   [1] N. J. Higham, Accuracy and Stability of Numerical Algorithms,
%       Second edition, Society for Industrial and Applied Mathematics,
%       Philadelphia, 2002; Chapter 28.
%   [2] J. R. Westlake, A Handbook of Numerical Matrix Inversion and
%       Solution of Linear Equations, John Wiley, New York, 1968.
%   [3] J. H. Wilkinson, The Algebraic Eigenvalue Problem,
%       Oxford University Press, 1965.
%
%   Nicholas J. Higham
%   Copyright 1984-2017 The MathWorks, Inc.

if isnumeric(matname)
   if matname == 3 || matname == 5
      matname = ['gallery' num2str(matname)];
      % Next line since need nonempty varargin below.
      if nargin == 1, varargin = {'double'}; end
   else
      error(message('MATLAB:gallery:invalidN'))
   end
end

if isstring(matname) && isscalar(matname)
   matname = char(matname);
end

if isempty(varargin)
    error(message('MATLAB:gallery:parametersRequired'));
else
   len1 = length(varargin{1});
end

if isstring(varargin{end}) && isscalar(varargin{end})
    varargin{end} = char(varargin{end});
end

% arg_inds is indices of arguments that should determine the class.
% It excludes arguments that specify a dimension or select an option.
arg_inds = [];  % Default: none of the arguments determine the class.

switch matname

   case {'binomial','chebspec','clement','cycol','dramadah','gearmat',...
         'frank','gallery3','gallery5','gcdmat','grcar','invol','ipjfact',...
         'lehmer','lesp','lotkin','minij','neumann', 'orthog', ...
         'parter','poisson','redheff','riemann','rando','ris','smoke', ...
         'wathen','wilk'}
         % These all take the default arg_inds.

   case {'cauchy','invhess','leslie'}
        if len1 ~= 1, arg_inds = [1 2]; end

   case 'chebvand'
        if len1 > 1
           arg_inds = 1;
        elseif length(varargin) >= 2 && length(varargin{2}) > 1
           arg_inds = 2;
        end

   case {'chow','forsythe','kahan'}
        arg_inds = [2 3];

   case {'compar','house','qmult','randhess'}
        arg_inds = 1;

   case {'condex','randjorth'}
        arg_inds = 3;

   case {'circul','fiedler','randcorr','randcolu','sampling'}
        if len1 ~= 1, arg_inds = 1; end

   case {'dorr','hanowa','jordbloc','kms','lauchli','moler','pei',...
         'prolate','randsvd','triw'}
        arg_inds = 2;

   case 'krylov'
        arg_inds = [1 2];

   case 'toeppd'
        arg_inds = [3 4];

   case 'toeppen'
        arg_inds = [2 3 4 5 6];

   case 'tridiag'
        if len1 > 1
           arg_inds = [1 2 3];
        elseif length(varargin) > 2
           arg_inds = [2 3 4];
        end

    case {'normaldata', 'uniformdata', 'integerdata'}
        % These functions perform their own class and input argument
        % checking, so just call them directly.
        F = str2func(matname);
        [varargout{1:max(nargout,1)}] = F(varargin{:});
        return;
        
   otherwise
       error(message('MATLAB:gallery:invalidMatName'))

end

nargs = nargin(matname);

if ischar(varargin{end})
   if strcmp(varargin{end},'single') || strcmp(varargin{end},'double')

      % CLASSNAME was passed to GALLERY.
      % ARGCLASS will make all relevant arguments of class CLASSNAME.

      [classname,varargin{1:end-1}] = ...
      argclass(arg_inds,varargin{end},varargin{1:end-1});
      % Next lines allow classname to be specified as trailing
      % input argument without giving full argument list.
      if length(varargin) < nargs
         varargin{end} = [];
         varargin{nargs} = classname;
      end

   else

   error(message('MATLAB:gallery:invalidClassName'))

   end

else

   % CLASSNAME was not passed to GALLERY.
   % ARGCLASS will determine appropriate CLASSNAME and
   % make all relevant arguments of class CLASSNAME.
   [classname,varargin{:}] = argclass(arg_inds,[],varargin{:});
   varargin{nargs} = classname;

end

if strcmp(classname,'single') && ...
   ( strcmp(matname,'dorr') || strcmp(matname,'neumann') ...
   || strcmp(matname,'toeppen') || strcmp(matname,'tridiag') ...
   || strcmp(matname,'wathen') )
   error(message('MATLAB:gallery:SparseSingle'))
end

F = str2func(matname);
[varargout{1:max(nargout,1)}] = F(varargin{:});

function A = gallery3(classname) %#ok<DEFNU>
A = [ -149   -50  -154
       537   180   546
       -27    -9   -25 ];
A = cast(A,classname);

function A = gallery5(classname) %#ok<DEFNU>
A = [ -9     11    -21     63    -252
      70    -69    141   -421    1684
    -575    575  -1149   3451  -13801
    3891  -3891   7782 -23345   93365
    1024  -1024   2048  -6144   24572 ];
A = cast(A,classname);
