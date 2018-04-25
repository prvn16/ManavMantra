function [F,exitflag,output] = funm(A,fun,options,varargin)
%FUNM  Evaluate general matrix function.
%   F = FUNM(A,FUN) evaluates the function_handle FUN at the square 
%   matrix A. FUN(X,K) must return the K'th derivative of the function 
%   represented by FUN evaluated at the vector X.
%   The MATLAB functions EXP, LOG, COS, SIN, COSH, SINH can be passed
%   as FUN, i.e., FUNM(A,@EXP), FUNM(A,@LOG), FUNM(A,@COS), FUNM(A,@SIN),
%   FUNM(A,@COSH), FUNM(A,@SINH) are all allowed.
%   For matrix square roots use SQRTM(A) instead.
%   For matrix exponentials, either of EXPM(A) and FUNM(A,@EXP) may be
%   the more accurate, depending on A.
%
%   The function represented by FUN must have a Taylor series with an
%   infinite radius of convergence, except for FUN = @LOG, 
%   which is treated as a special case.
%
%   Example:
%   To compute the function EXP(X)+COS(X) at A with one call to FUNM, use
%       F = funm(A,@fun_expcos)
%   where
%       function f = fun_expcos(x,k)
%       % Return k'th derivative of EXP+COS at X.
%       g = mod(ceil(k/2),2);
%       if mod(k,2)
%          f = exp(x) + sin(x)*(-1)^g;
%       else
%          f = exp(x) + cos(x)*(-1)^g;
%       end
%
%   F = FUNM(A,FUN,options) sets the algorithm's parameters to the
%   values in the structure options.
%   options.Display:  Level of display
%                     [ {off} | on | verbose ]
%   options.TolBlk:   Tolerance for blocking Schur form
%                     [ positive scalar {0.1} ]
%   options.TolTay:   Termination tolerance for evaluating Taylor
%                     series of diagonal blocks
%                     [ positive scalar {eps} ]
%   options.MaxTerms: Maximum number of Taylor series terms
%                     [ positive integer {100} ]
%   options.MaxSqrt:  When computing logarithm, maximum number of
%                     matrix square roots computed in inverse scaling
%                     and squaring method
%                     [ positive integer {100} ]
%   options.Ord:      A specified ordering of the Schur form, T.
%                     A vector of length LENGTH(A), with options.Ord(i)
%                     the index of the block into which T(i,i)
%                     should be placed,
%                     [ integer vector {[]} ]
%
%   F = FUNM(A,FUN,options,P1,P2,...) passes extra inputs
%   P1,P2,... to the function: FUN(X,K,P1,P2,...).
%   Use options = [] as a place holder if no options are set.
%
%   [F,EXITFLAG] = FUNM(...) returns a scalar EXITFLAG that describes
%   the exit condition of FUNM:
%   EXITFLAG = 0: successful completion of algorithm.
%   EXITFLAG = 1: one or more Taylor series evaluations did not converge
%                 or, for logarithm, too many matrix square roots
%                 needed.  Computed F may still be accurate, however.
%
%   [F,EXITFLAG,output] = FUNM(...) returns a structure output with
%   output.terms(i): the number of Taylor series terms used
%                    when evaluating the i'th block, or the number of
%                    square roots of matrices of dimension > 2
%                    in the case of the logarithm,
%   output.ind(i):   cell array specifying the blocking: the (i,j)
%                    block of the re-ordered Schur factor T is
%                    T(output.ind{i},output.ind{j}),
%   output.ord:      the ordering, as passed to ORDSCHUR,
%   output.T:        the re-ordered Schur form.
%   If the Schur form is diagonal then
%   output = struct('terms',ones(n,1),'ind',{1:n})
%
%   See also EXPM, SQRTM, LOGM, FUNCTION_HANDLE.

%   References:
%   P. I. Davies and N. J. Higham, A Schur-Parlett algorithm for computing
%      matrix functions. SIAM J. Matrix Anal. Appl., 25(2):464-485, 2003.
%   N. J. Higham, Functions of Matrices: Theory and Computation,
%      Society for Industrial and Applied Mathematics, Philadelphia, PA,
%      USA, 2008.
%
%   Nicholas J. Higham
%   Copyright 1984-2017 The MathWorks, Inc. 

if isstring(fun) && isscalar(fun)
    fun = char(fun);
end

if isequal(fun,@cos)  || isequal(fun,'cos'), fun = @fun_cos; end
if isequal(fun,@sin)  || isequal(fun,'sin'), fun = @fun_sin; end
if isequal(fun,@cosh) || isequal(fun,'cosh'), fun = @fun_cosh; end
if isequal(fun,@sinh) || isequal(fun,'sinh'), fun = @fun_sinh; end
if isequal(fun,@exp)  || isequal(fun,'exp'), fun = @fun_exp; end
if isequal(fun,@log)  || isequal(fun,'log'), fun = @fun_log; end

% Default parameters.
prnt = 0;
delta = 0.1;
tol = eps;
maxterms = 250;
maxsqrt = 100;
ord = [];
exitflag = 0;

if nargin > 2 && ~isempty(options)

   if isfield(options,'Display') && ~isempty(options.Display)
      if matlab.internal.math.checkInputName(options.Display,'on',2)
          prnt = 1;
      elseif matlab.internal.math.checkInputName(options.Display,'verbose',1)
          prnt = 2;
      end
   end

   if isfield(options,'TolBlk') && ~isempty(options.TolBlk)
      delta = options.TolBlk;
      if delta <= 0, error(message('MATLAB:funm:NegTolBlk')); end
   end

   if isfield(options,'TolTay') && ~isempty(options.TolTay)
      tol = options.TolTay;
      if tol <= 0, error(message('MATLAB:funm:NegTolTay')); end
   end

   if isfield(options,'MaxTerms') && ~isempty(options.MaxTerms)
      maxterms = options.MaxTerms;
      if maxterms <= 0 
        error(message('MATLAB:funm:NegMaxTerms')); 
      end
   end

   if isfield(options,'MaxSqrt') && ~isempty(options.MaxSqrt)
      maxsqrt = options.MaxSqrt;
      if maxsqrt <= 0
        error(message('MATLAB:funm:NegMaxSqrt')); 
      end
   end

   if isfield(options,'Ord') && ~isempty(options.Ord)
      ord = options.Ord;
      if length(ord) ~= length(A)
        error(message('MATLAB:funm:WrongDimOrd')); 
      end
   end

end

[m,n] = size(A);
if  ~isfloat(A) || ~ismatrix(A) || m ~= n
   error(message('MATLAB:funm:InputDim'));
end

% First form complex Schur form (if A not already upper triangular).
if isequal(A,triu(A))
   T = A; U = eye(n);
   diagT = diag(T);
else
   [U,T] = schur(A,'complex');
   diagT = diag(T);
   if isequal(fun,@fun_log) && ~all(diagT)
       warning(message('MATLAB:funm:zeroEig'))
   end
end

if isequal(fun,@fun_log) && any( imag(diagT) == 0 & real(diagT) <= 0 )
    warning(message('MATLAB:funm:nonPosRealEig'))
end

if isequal(T,diag(diagT)) % Handle special case of diagonal T.
   F = U*diag(feval(fun,diag(T),0,varargin{:}))*U';
   output = struct('terms',ones(n,1),'ind',{1:n});
   return
end

% Determine reordering of Schur form into block form.
if isempty(ord), ord = blocking(T,delta); end

[ord, ind] = swapping(ord);  % Gives the blocking.
ord = max(ord)-ord+1;        % Since ORDSCHUR puts highest index top left.
[U,T] = ordschur(U,T,ord);

m = length(ind);

% Calculate F(T)
F = zeros(n);
terms = zeros(1,m);
for col=1:m
   j = ind{col};
   if prnt == 2 && length(j) > 1
      fprintf(getString(message('MATLAB:funm:EvaluatingFunctionOfBlock',...
          sprintf('%g',min(j)), sprintf('%g',max(j)))));
   end
   if isequal(fun,@fun_log)
      [F(j,j), terms(col)] = logm_triang(T(j,j),maxsqrt);
   elseif isequal(fun,@fun_exp)
      F(j,j) = expm_triang(T(j,j));
   else
      [F(j,j), terms(col)] = funm_atom(T(j,j),fun,tol,maxterms,prnt>1,...
                                       varargin{:});
   end

   for row=col-1:-1:1
      i = ind{row};
      if length(i) == 1 && length(j) == 1
         % Scalar case.
         k = i+1:j-1;
         temp = T(i,j)*(F(i,i) - F(j,j)) + F(i,k)*T(k,j) - T(i,k)*F(k,j);
         F(i,j) = temp/(T(i,i)-T(j,j));
      else
         k = cat(2,ind{row+1:col-1});
         rhs = F(i,i)*T(i,j) - T(i,j)*F(j,j) + F(i,k)*T(k,j) - T(i,k)*F(k,j);
         F(i,j) = sylv_tri(T(i,i),-T(j,j),rhs);
      end
   end
end

F = U*F*U';

if isreal(A) && norm(imag(F),1) <= 10*n*eps*norm(F,1)
   F = real(F);
end

if prnt
  fprintf('  Block   Number of Taylor series terms\n')
  fprintf('          (or matrix square roots in case of log):\n')
  fprintf('  ----------------------------------------\n')
  for i = 1:length(ind)
      fprintf(' (%g:%g)      %g\n', min(ind{i}), max(ind{i}), terms(i))
  end
end

if any(terms == -1)
   exitflag = 1;
   warning(message('MATLAB:funm:TaylorSeriesNotConverged'))
end

if isequal(fun,@fun_log) && any(terms == maxsqrt)
   exitflag = 1;
   warning(message('MATLAB:funm:TooManyMatrixSquareRoots'))
end

if nargout >= 3
   output = struct('terms',terms,'ind',{ind},'ord',ord,'T',T);
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function f = fun_cos(x,k)
%FUN_COS Cosine function and its derivatives.
%        FUN_COS(X,K) is the k'th derivative of the cosine function at X.

g = mod(ceil(k/2),2);
if mod(k,2)
   f = sin(x)*(-1)^g;
else
   f = cos(x)*(-1)^g;
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function f = fun_sin(x,k)
%FUN_SIN Sine function and its derivatives.
%        FUN_SIN(X,K) is the k'th derivative of the sine function at X.

g = mod(ceil((k-1)/2),2);
if mod(k,2)
   f = cos(x)*(-1)^g;
else
   f = sin(x)*(-1)^g;
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function f = fun_cosh(x,k)
%FUN_COSH Hyperbolic cosine function and its derivatives.
%   FUN_COSH(X,K) is the k'th derivative of the hyperbolic cosine function
%   at X.

if mod(k,2)
   f = sinh(x);
else
   f = cosh(x);
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function f = fun_exp(x,~)
%FUN_EXP Exponential function and its derivatives.
%   FUN_EXP(X,K) is the k'th derivative of the exponential function at X.

f = exp(x);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function f = fun_log(x,~)
%FUN_LOG  Logarithm function.
%   FUN_LOG(X,K) is the logarithm at X.
%   Only to be called for plain log evaluation, with k == 0.
f = log(x);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function f = fun_sinh(x,k)
%FUN_SINH Hyperbolic sine function and its derivatives.
%   FUN_SINH(X,K) is the k'th derivative of the hyperbolic sine function at X.

if mod(k,2)
   f = cosh(x);
else
   f = sinh(x);
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function m = blocking(A,delta)
%BLOCKING  Produce blocking pattern for block Parlett recurrence in FUNM.
%   M = BLOCKING(A, DELTA, SHOWPLOT) accepts an upper triangular matrix
%   A and produces a blocking pattern, specified by the vector M,
%   for the block Parlett recurrence.
%   M(i) is the index of the block into which A(i,i) should be placed,
%   for i=1:LENGTH(A).
%   DELTA is a gap parameter (default 0.1) used to determine the blocking.

%   For A coming from a real matrix it should be posible to take
%   advantage of the symmetry about the real axis.  This code does not.

a = diag(A); n = length(a);
m = zeros(1,n); maxM = 0;

if nargin < 2 || isempty(delta), delta = 0.1; end

for i = 1:n

    if m(i) == 0
        m(i) = maxM + 1; % If a(i) hasn`t been assigned to a set
        maxM = maxM + 1; % then make a new set and assign a(i) to it.
    end

    for j = i+1:n
        if m(i) ~= m(j)    % If a(i) and a(j) are not in same set.
            if abs(a(i)-a(j)) <= delta

                if m(j) == 0
                    m(j) = m(i); % If a(j) hasn`t been assigned to a
                                 % set, assign it to the same set as a(i).
                else
                    p = max(m(i),m(j)); q = min(m(i),m(j));
                    m(m==p) = q; % If a(j) has been assigned to a set
                                 % place all the elements in the set
                                 % containing a(j) into the set
                                 % containing a(i) (or vice versa).
                    m(m>p) = m(m>p) -1;
                    maxM = maxM - 1;
                                 % Tidying up. As we have deleted set
                                 % p we reduce the index of the sets
                                 % > p by 1.
                end
            end
        end
    end
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [mm,ind] = swapping(m)
%SWAPPING  Choose confluent permutation ordered by average index.
%   [MM,IND] = SWAPPING(M) takes a vector M containing the integers
%   1:K (some repeated if K < LENGTH(M)), where M(J) is the index of
%   the block into which the element T(J,J) of a Schur form T
%   should be placed.
%   It constructs a vector MM (a permutation of M) such that T(J,J)
%   will be located in the MM(J)'th block counting from the (1,1) position.
%   The algorithm used is to order the blocks by ascending
%   average index in M, which is a heuristic for minimizing the number
%   of swaps required to achieve this confluent permutation.
%   The cell array vector IND defines the resulting block form:
%   IND{i} contains the indices of the i'th block in the permuted form.

mmax = max(m); mm = zeros(size(m));
g = zeros(1,mmax); h = zeros(1,mmax);

for i = 1:mmax
    p = find(m==i);
    h(i) = length(p);
    g(i) = sum(p)/h(i);
end

[~,y] = sort(g);
h = [0 cumsum(h(y))];

ind = cell(mmax,1);
for i = 1:mmax
    mm(m==y(i)) = i;
    ind{i} = h(i)+1:h(i+1);
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [F,n_terms] = funm_atom(T,fun,tol,maxterms,prnt,varargin)
%FUNM_ATOM  Function of triangular matrix with nearly constant diagonal.
%   [F, N_TERMS] = FUNM_ATOM(T, FUN, TOL, MAXTERMS, PRNT)
%   evaluates function FUN at the upper triangular matrix T,
%   where T has nearly constant diagonal.
%   A Taylor series is used, taking at most MAXTERMS terms.
%   The function represented by FUN must have a Taylor series with an
%   infinite radius of convergence.
%   FUN(X,K) must return the K'th derivative of
%   the function represented by FUN evaluated at the vector X.
%   TOL is a convergence tolerance for the Taylor series, defaulting to EPS.
%   If PRNT ~= 0 information is printed on the convergence of the
%   Taylor series evaluation.
%   N_TERMS is the number of terms taken in the Taylor series.
%   N_TERMS  = -1 signals lack of convergence.

if nargin < 3 || isempty(tol), tol = eps; end
if nargin < 5, prnt = 0; end

n = length(T);
if n == 1, F = feval(fun,T,0,varargin{:}); n_terms = 1; return, end

lambda = sum(diag(T))/n;
f = feval(fun,lambda,0,varargin{:}); F = f*eye(n);
if prnt, fprintf('%3.0f: |f^(k)| = %5.0e\n', 1, abs(f)); end
f_deriv_max = zeros(maxterms+n-1,1);
N = T - lambda*eye(n);
mu = norm( (eye(n)-abs(triu(T,1)))\ones(n,1),inf );

P = N;
max_d = 1;

for k = 1:maxterms

    f = feval(fun,lambda,k,varargin{:});
    if isinf(f), error(message('MATLAB:funm:InfDeriv')), end
    F_old = F;
    F = F + P*f;
    rel_diff = norm(F - F_old,inf)/(tol+norm(F_old,inf));
    if prnt
        fprintf('%3.0f: |f^(k)| = %5.0e', k+1, abs(f));
        fprintf('  ||N^k/k!|| = %7.1e', norm(P,inf));
        fprintf('  rel_diff = %5.0e',rel_diff);
        fprintf('  abs_diff = %5.0e',norm(F - F_old,inf));
    end
    P = P*N/(k+1);

    if rel_diff <= tol

      % Approximate the maximum of derivatives in convex set containing
      % eigenvalues by maximum of derivatives at eigenvalues.
      for j = max_d:k+n-1
          f_deriv_max(j) = norm(feval(fun,diag(T),j,varargin{:}),inf);
      end
      max_d = k+n;
      omega = 0;
      for j = 0:n-1
          omega = max(omega,f_deriv_max(k+j)/factorial(j));
      end

      trunc = norm(P,inf)*mu*omega;  % norm(F) moved to RHS to avoid / 0.
      if prnt
          fprintf('  [trunc,test] = [%5.0e %5.0e]', trunc, tol*norm(F,inf))
      end
      if prnt == -1, trunc = 0; end % Force simple stopping test.
      if trunc <= tol*norm(F,inf)
         n_terms = k+1;
         if prnt, fprintf('\n'), end
         return
      end
    end

    if prnt, fprintf('\n'), end

end
n_terms = -1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function X = sylv_tri(T,U,B)
%SYLV_TRI    Solve triangular Sylvester equation.
%   X = SYLV_TRI(T,U,B) solves the Sylvester equation
%   T*X + X*U = B, where T and U are square upper triangular matrices.

m = length(T);
n = length(U);
X = zeros(m,n);
opts.UT = true;

% Forward substitution.
for i = 1:n
    X(:,i) = linsolve(T + U(i,i)*eye(m), B(:,i) - X(:,1:i-1)*U(1:i-1,i), opts);
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function F = expm_triang(A)
%EXPM_TRIANG   Exponential of upper triangular matrix.
%   EXPM_TRIANG(A,MAXSQRT) is the exponential of the
%   upper triangular matrix A.  Explicit formulae are used for
%   dimensions 1 and 2 and EXPM is used for larger dimensions.

switch length(A)

   case 1
   F = exp(A);

   case 2
   F = expm2by2(A);

   otherwise
   F = expm(A);

end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function X = expm2by2(A)
%EXPM2BY2    Exponential of 2-by-2 upper triangular matrix.
%   EXPM2BY2(A) is the exponential of the 2-by-2 upper triangular matrix A.

a1 = A(1,1);
a2 = A(2,2);
X = [exp(a1)  A(1,2)*exp( (a1+a2)/2 ) * sinch( (a2-a1)/2 );
       0      exp(a2)];

    function y = sinch(x)
    if x == 0
       y = 1;
    else
      y = sinh(x)/x;
    end
    end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [F, k] = logm_triang(A,maxsqrt)
%LOGM_TRIANG   Logarithm of upper triangular matrix.
%   [F, K] = LOGM_TRIANG(A,MAXSQRT) computes the logarithm of the
%   upper triangular matrix A.   Explicit formulae are used for
%   dimensions 1 and 2. For dimension greater than 2 the inverse
%   scaling and squaring method is used with at most MAXSQRT matrix
%   square roots and K is the number of square roots required.

k = 0;
switch length(A)

   case 1
   F = log(A);

   case 2
   F = logm2by2(A);

   otherwise
   [F, k] = logm_iss_triang(A,maxsqrt);

end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function X = logm2by2(A)
%LOGM2BY2    Logarithm of 2-by-2 upper triangular matrix.
%   LOGM2BY2(A) is the logarithm of the 2-by-2 upper triangular matrix A.

a1 = A(1,1);
a2 = A(2,2);

loga1 = log(a1);
loga2 = log(a2);
X = diag([loga1 loga2]);

if a1 == a2
   X(1,2) = A(1,2)/a1;

elseif abs(a1) < 0.5*abs(a2) || abs(a2) < 0.5*abs(a1)
   X(1,2) =  A(1,2) * (loga2 - loga1) / (a2 - a1);

else % Close eigenvalues.
   dd = (2*atanh((a2-a1)/(a2+a1)) + 2*pi*1i*unwinding(loga2-loga1)) / (a2-a1);
   X(1,2) = A(1,2)*dd;

end

   function u = unwinding(z,k)
   %UNWINDING    Unwinding number.
   %   UNWINDING(Z,K) is the K'th derivative of the
   %   unwinding number of the complex number Z.
   %   Default: k = 0.

   if nargin == 1 || k == 0
      u = ceil( (imag(z) - pi)/(2*pi) );
   else
      u = 0;
   end
   end

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [X,k,m] = logm_iss_triang(T,maxsqrt)
%LOGM_ISS_TRIANG   Log of triangular matrix by inverse scaling and squaring.
%   X = LOGM_ISS_TRIANG(A,MAXSQRT) computes the principal logarithm of
%   the upper triangular matrix A, for a matrix with no nonpositive
%   real eigenvalues, using the inverse scaling and squaring method
%   with Pade approximation.  At most MAXSQRT matrix square roots are
%   computed.  [X, K, M] = LOGM_ISS_TRIANG(A) returns the number K of
%   square roots computed and the degree M of the Pade approximant.

%   References:
%   S. H. Cheng, N. J. Higham, C. S. Kenney, and A. J. Laub, Approximating the
%      logarithm of a matrix to specified accuracy, SIAM J. Matrix Anal. Appl.,
%      22(4):1112-1125, 2001.
%   N. J. Higham, Evaluating Pade approximants of the matrix logarithm,
%      SIAM J. Matrix Anal. Appl., 22(4):1126-1135, 2001.

n = length(T);

xvals = [ % Max norm(X) for degree m Pade approximant to LOG(I+X).
  1.6206284795015669e-002   % m = 3
  5.3873532631381268e-002   % m = 4
  1.1352802267628663e-001   % m = 5
  1.8662860613541296e-001   % m = 6
  2.6429608311114350e-001   % m = 7
  ];

k = 0; p = 0;

while 1

    normdiff = norm(T-eye(n),1);

    if normdiff <= xvals(end)

       p = p+1;
       j1 = find(normdiff <= xvals);
       j1 = j1(1) + 2;
       j2 = find(normdiff/2 <= xvals);
       j2 = j2(1) + 2;
       if j1-j2 < 2 || p == 2, m = j1; break, end

    end

    if k == maxsqrt, m = 16; break, end
    T = sqrtm_tri(T); k = k+1;

end

X = 2^k*logm_pf(T-eye(n),m);

   function R = sqrtm_tri(T)
   %SQRTM_TRI   Upper triangular square root of upper triangular matrix.

   R = zeros(n);
   for j=1:n
       R(j,j) = sqrt(T(j,j));
       for i=j-1:-1:1
           R(i,j) = (T(i,j) - R(i,i+1:j-1)*R(i+1:j-1,j))/(R(i,i) + R(j,j));
       end
   end
   end

   function S = logm_pf(A,m)
   %LOGM_PF   Pade approximation to matrix log by partial fraction expansion.
   %   LOGM_PF(A,m) is an [m/m] Pade approximant to LOG(EYE(SIZE(A))+A).

   [nodes,wts] = gauss_legendre(m);
   % Convert from [-1,1] to [0,1].
   nodes = (nodes + 1)/2;
   wts = wts/2;

   S = zeros(n);
   for j=1:m
       S = S + wts(j)*(A/(eye(n) + nodes(j)*A));
   end
   end

   function [x,w] = gauss_legendre(n)
   %GAUSS_LEGENDRE  Nodes and weights for Gauss-Legendre quadrature.
   %   [X,W] = GAUSS_LEGENDRE(N) computes the nodes X and weights W
   %   for N-point Gauss-Legendre quadrature.

   % Reference:
   % G. H. Golub and J. H. Welsch, Calculation of Gauss quadrature
   % rules, Math. Comp., 23(106):221-230, 1969.

   i = 1:n-1;
   v = i./sqrt((2*i).^2-1);
   [V,x] = eig( diag(v,-1)+diag(v,1) , 'vector');
   w = 2*(V(1,:)'.^2);
   end

end
