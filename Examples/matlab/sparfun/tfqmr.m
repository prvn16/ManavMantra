function [x,flag,relres,iter,resvec] = tfqmr(A,b,tol,maxit,M1,M2,x0,varargin)
%TFQMR   Transpose Free Quasi-Minimal Residual Method.
%   X = TFQMR(A,B) attempts to solve the system of linear equations A*X=B for
%   X. The N-by-N coefficient matrix A must be square and the right hand
%   side column vector B must have length N.
%
%   X = TFQMR(AFUN,B) accepts a function handle AFUN instead of the matrix A.
%   AFUN(X) accepts a vector input X and returns the matrix-vector product
%   A*X. In all of the following syntaxes, you can replace A by AFUN.
%
%   X = TFQMR(A,B,TOL) specifies the tolerance of the method. If TOL is []
%   then TFQMR uses the default, 1e-6.
%
%   X = TFQMR(A,B,TOL,MAXIT) specifies the maximum number of iterations. If
%   MAXIT is [] then TFQMR uses the default, min(N,20).
%
%   X = TFQMR(A,B,TOL,MAXIT,M) and X = TFQMR(A,B,TOL,MAXIT,M1,M2) use
%   preconditioners M or M=M1*M2 and effectively solve the system
%   A*inv(M)*X = B for X. If M is [] then a preconditioner is not
%   applied. M may be a function handle MFUN such that MFUN(X) returns M\X.
%
%   X = TFQMR(A,B,TOL,MAXIT,M1,M2,X0) specifies the initial guess. If X0 is
%   [] then TFQMR uses the default, an all zero vector.
%
%   [X,FLAG] = TFQMR(A,B,...) also returns a convergence FLAG:
%    0 TFQMR converged to the desired tolerance TOL within MAXIT iterations.
%    1 TFQMR iterated MAXIT times but did not converge.
%    2 preconditioner M was ill-conditioned.
%    3 TFQMR stagnated (two consecutive iterates were the same).
%    4 one of the scalar quantities calculated during TFQMR became too
%      small or too large to continue computing.
%
%   [X,FLAG,RELRES] = TFQMR(A,B,...) also returns the relative residual
%   NORM(B-A*X)/NORM(B). If FLAG is 0, then RELRES <= TOL.
%
%   [X,FLAG,RELRES,ITER] = TFQMR(A,B,...) also returns the iteration number
%   at which X was computed: 0 <= ITER <= MAXIT.
%
%   [X,FLAG,RELRES,ITER,RESVEC] = TFQMR(A,B,...) also returns a vector of the
%   residual norms at each iteration, including NORM(B-A*X0).
%
%   Example:
%      n = 100; on = ones(n,1); A = spdiags([-2*on 4*on -on],-1:1,n,n);
%      b = sum(A,2); tol = 1e-8; maxit = 15;
%      M1 = spdiags([on/(-2) on],-1:0,n,n);
%      M2 = spdiags([4*on -on],0:1,n,n);
%      x = tfqmr(A,b,tol,maxit,M1,M2,[]);
%   Or, use this matrix-vector product function
%      %------------------------------------%
%      function y = afun(x,n)
%      y = 4 * x;
%      y(2:n) = y(2:n) - 2 * x(1:n-1);
%      y(1:n-1) = y(1:n-1) - x(2:n);
%      %------------------------------------%
%   as input to TFQMR:
%      x1 = tfqmr(@(x)afun(x,n),b,tol,maxit,M1,M2);
%
%   Supposing that applyOp is a function suitable for use with QMR, it may be
%   used with TFQMR by wrapping it in an anonymous function:
%      x1 = tfqmr(@(x)applyOp(x,'notransp'),b,tol,maxit,M1,M2);
%     
%   Class support for inputs A,B,M1,M2,X0 and the output of AFUN:
%      float: double
%
%   See also BICG, BICGSTAB, BICGSTABL, CGS, GMRES, LSQR, MINRES, PCG, QMR,
%   SYMMLQ, ILU, FUNCTION_HANDLE.

%   References:
%      1. R. Freund, A transpose-free quasi-minimal residual algorithm for
%         non-Hermitian linear systems, SIAM J. Sci. Comp., 14 (1993),
%         pp. 470--482.
%      2. Y. Saad, Iterative Methods for Sparse Linear Systems, 2nd ed.
%         SIAM, 2003, Philadelphia.

%   Copyright 2008-2013 The MathWorks, Inc.

% Check for an acceptable number of input arguments
if nargin < 2
    error(message('MATLAB:tfqmr:NotEnoughInputs'));
end

% Determine whether A is a matrix or a function.
[atype,afun,afcnstr] = iterchk(A);
if strcmp(atype,'matrix')
    % Check matrix and right hand side vector inputs have appropriate sizes
    [m,n] = size(A);
    if (m ~= n)
        error(message('MATLAB:tfqmr:NonSquareMatrix'));
    end
    if ~isequal(size(b),[m,1])
        error(message('MATLAB:tfqmr:RSHsizeMatchCoeffMatrix', m));
    end
else
    m = size(b,1);
    n = m;
    if ~iscolumn(b)
        error(message('MATLAB:tfqmr:RSHnotColumn'));
    end
end

% Assign default values to unspecified parameters
if nargin < 3 || isempty(tol)
    tol = 1e-6;
end
warned = 0;
if tol < eps
    warning(message('MATLAB:tfqmr:tooSmallTolerance'));
    warned = 1;
    tol = eps;
elseif tol >= 1
    warning(message('MATLAB:tfqmr:tooBigTolerance'));
    warned = 1;
    tol = 1-eps;
end
if nargin < 4 || isempty(maxit)
    maxit = min(n,20);
end

% Check for all zero right hand side vector => all zero solution
n2b = norm(b);                     % Norm of rhs vector, b
if (n2b == 0)                      % if    rhs vector is all zeros
    x = zeros(n,1);                % then  solution is all zeros
    flag = 0;                      % a valid solution has been obtained
    relres = 0;                    % the relative residual is actually 0/0
    iter = 0;                      % no iterations need be performed
    resvec = 0;                    % resvec(1) = norm(b-A*x) = norm(0)
    if (nargout < 2)
        itermsg('tfqmr',tol,maxit,0,flag,iter,NaN);
    end
    return
end

if ((nargin >= 5) && ~isempty(M1))
    existM1 = 1;
    [m1type,m1fun,m1fcnstr] = iterchk(M1);
    if strcmp(m1type,'matrix')
        if ~isequal(size(M1),[m,m])
            error(message('MATLAB:tfqmr:WrongPrecondSize', m));
        end
    end
else
    existM1 = 0;
    m1type = 'matrix';
end

if ((nargin >= 6) && ~isempty(M2))
    existM2 = 1;
    [m2type,m2fun,m2fcnstr] = iterchk(M2);
    if strcmp(m2type,'matrix')
        if ~isequal(size(M2),[m,m])
            error(message('MATLAB:tfqmr:WrongPrecondSize', m));
        end
    end
else
    existM2 = 0;
    m2type = 'matrix';
end

if ((nargin >= 7) && ~isempty(x0))
    if ~isequal(size(x0),[n,1])
        error(message('MATLAB:tfqmr:WrongInitGuessSize', n));
    else
        x = x0;
    end
else
    x = zeros(n,1);
end

if ((nargin > 7) && strcmp(atype,'matrix') && ...
        strcmp(m1type,'matrix') && strcmp(m2type,'matrix'))
    error(message('MATLAB:tfqmr:TooManyInputs'));
end

% Set up for the method
flag = 1;
xmin = x;                          % Iterate which has minimal residual so far
imin = 0;                          % Iteration at which xmin was computed
tolb = tol * n2b;                  % Relative tolerance
r = b - iterapp('mtimes',afun,atype,afcnstr,x,varargin{:});
normr = norm(r);                   % Norm of residual
normr_act = normr;

if (normr <= tolb)                 % Initial guess is a good enough solution
    flag = 0;
    relres = normr / n2b;
    iter = 0;
    resvec = normr;
    if (nargout < 2)
        itermsg('tfqmr',tol,maxit,0,flag,iter,relres);
    end
    return
end

r0 = r;
u_m = r;
w = r;
%v = A*M1(u_m);
if existM1
    pu_m = iterapp('mldivide',m1fun,m1type,m1fcnstr,u_m,varargin{:});
    if ~all(isfinite(pu_m))
        flag = 2;
        relres = normr/n2b;
        iter = 0;
        resvec = normr;
        if nargout < 2
            itermsg('tfqmr',tol,maxit,0,flag,iter,relres);
        end
        return
    end
else
    pu_m = u_m;
end
if existM2
    pu_m = iterapp('mldivide',m2fun,m2type,m2fcnstr,pu_m,varargin{:});
    if ~all(isfinite(pu_m))
        flag = 2;
        relres = normr/n2b;
        iter = 0;
        resvec = normr;
        if nargout < 2
            itermsg('tfqmr',tol,maxit,0,flag,iter,relres);
        end
        return
    end
end
v = iterapp('mtimes',afun,atype,afcnstr,pu_m,varargin{:});

Au = v;
d = zeros(n,1);
Ad = d;
tau = normr;
theta = 0;
eta = 0;
rho = r'*r;
rho_old = rho;

stag = 0;
moresteps = 0;
maxmsteps = min([floor(n/50),10,n-maxit]);
maxstagsteps = 3;

resvec = zeros(maxit+1,1);
resvec(1) = norm(r);
normrmin = resvec(1);

even = true;

for mm = 1 : maxit*2
    if even
        alpha = rho/(r0'*v);
        u_mp1 = u_m - alpha*v;
    end
    w = w - alpha*Au;
    sigma = (theta^2/alpha)*eta;
    d = pu_m + sigma*d;
    Ad = Au + sigma*Ad;
    theta = norm(w)/tau;
    c_mp1 = 1/sqrt(1+theta^2);
    tau = tau*theta*c_mp1;
    eta = c_mp1^2*alpha;
    
    if abs(eta)*norm(d) < eps*norm(x)
        stag = stag + 1;
    else
        stag = 0;
    end
    x = x + eta*d;
    r = r - eta*Ad;
    normr = norm(r);
    normr_act = normr;
    resvec(mm+1) = normr;
    
    % check for convergence
    if (normr <= tolb || stag >= maxstagsteps || moresteps)
        % double check residual norm is less than tolerance
        r = b - iterapp('mtimes',afun,atype,afcnstr,x,varargin{:});
        normr_act = norm(r);
        resvec(mm+1) = normr_act;
        if (normr_act <= tolb)
            flag = 0;
            iter = mm;
            resvec = resvec(1:mm+1);
            break
        else
            if stag >= maxstagsteps && moresteps == 0
                stag = 0;
            end
            moresteps = moresteps + 1;
            if moresteps >= maxmsteps
                if ~warned
                    warning(message('MATLAB:tfqmr:tooSmallTolerance'));
                end
                flag = 3;
                iter = mm;
                resvec = resvec(1:mm+1);
                break;
            end
        end
    end
    
    if (normr_act < normrmin)      % update minimal norm quantities
        normrmin = normr_act;
        xmin = x;
        imin = mm;
    end
    if (stag >= maxstagsteps)      % 3 iterates are the same
        flag = 3;
        break
    end
    
    if ~even
        rho = r0'*w;
        beta = rho/rho_old;
        rho_old = rho;
        u_mp1 = w + beta*u_m;
    end
    
    if existM1
        pu_m = iterapp('mldivide',m1fun,m1type,m1fcnstr,u_mp1,varargin{:});
        if ~all(isfinite(pu_m))
            flag = 2;
            resvec = resvec(1:mm+1);
            break
        end
    else
        pu_m = u_mp1;
    end
    if existM2
        pu_m = iterapp('mldivide',m2fun,m2type,m2fcnstr,pu_m,varargin{:});
        if ~all(isfinite(pu_m))
            flag = 2;
            resvec = resvec(1:mm+1);
            break
        end
    end
    Au_new = iterapp('mtimes',afun,atype,afcnstr,pu_m,varargin{:});
    
    if ~even
        v = Au_new + beta*(Au+beta*v);
    end
    Au = Au_new;
    u_m = u_mp1;
    even = ~even;
end

if flag == 0
    relres = normr_act/n2b;
else   
    r_comp = b - iterapp('mtimes',afun,atype,afcnstr,xmin,varargin{:});
    if flag == 1 || flag == 3
        r_comp2 = b - iterapp('mtimes',afun,atype,afcnstr,x,varargin{:});
        normr_act = norm(r_comp2);
    end
    if norm(r_comp) <= normr_act
        x = xmin;
        iter = imin;
        relres = norm(r_comp) / n2b;
    else
        iter = mm;
        relres = normr_act / n2b;
    end
    resvec = resvec(1:mm+1);
end
iter = floor(iter/2);

if nargout < 2
    itermsg('tfqmr',tol,maxit,mm,flag,iter,relres);
end

