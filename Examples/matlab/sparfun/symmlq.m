function [x,flag,relres,iter,resvec,resveccg] = symmlq(A,b,tol,maxit,M1,M2,x0,varargin)
%SYMMLQ   Symmetric LQ Method.
%   X = SYMMLQ(A,B) attempts to solve the system of linear equations A*X=B
%   for X. The N-by-N coefficient matrix A must be symmetric but need not
%   be positive definite. The right hand side column vector B must have
%   length N.
%
%   X = SYMMLQ(AFUN,B) accepts a function handle AFUN instead of the matrix
%   A. AFUN(X) accepts a vector input X and returns the matrix-vector
%   product A*X. In all of the following syntaxes, you can replace A by
%   AFUN.
%
%   X = SYMMLQ(A,B,TOL) specifies the tolerance of the method. If TOL is []
%   then SYMMLQ uses the default, 1e-6.
%
%   X = SYMMLQ(A,B,TOL,MAXIT) specifies the maximum number of iterations.
%   If MAXIT is [] then SYMMLQ uses the default, min(N,20).
%
%   X = SYMMLQ(A,B,TOL,MAXIT,M) and X = SYMMLQ(A,B,TOL,MAXIT,M1,M2) use the
%   symmetric positive definite preconditioner M or M=M1*M2 and effectively
%   solve the system inv(sqrt(M))*A*inv(sqrt(M))*Y = inv(sqrt(M))*B for Y
%   and then return X = inv(sqrt(M))*Y. If M is [] then a preconditioner is
%   not applied. M may be a function handle returning M\X.
%
%   X = SYMMLQ(A,B,TOL,MAXIT,M1,M2,X0) specifies the initial guess. If X0
%   is [] then SYMMLQ uses the default, an all zero vector.
%
%   [X,FLAG] = SYMMLQ(A,B,...) also returns a convergence FLAG:
%    0 SYMMLQ converged to the desired tolerance TOL within MAXIT iterations.
%    1 SYMMLQ iterated MAXIT times but did not converge.
%    2 preconditioner M was ill-conditioned.
%    3 SYMMLQ stagnated (two consecutive iterates were the same).
%    4 one of the scalar quantities calculated during SYMMLQ became
%      too small or too large to continue computing.
%    5 preconditioner M was not symmetric positive definite.
%
%   [X,FLAG,RELRES] = SYMMLQ(A,B,...) also returns the relative residual
%   NORM(B-A*X)/NORM(B). If FLAG is 0, then RELRES <= TOL.
%
%   [X,FLAG,RELRES,ITER] = SYMMLQ(A,B,...) also returns the iteration
%   number at which X was computed: 0 <= ITER <= MAXIT.
%
%   [X,FLAG,RELRES,ITER,RESVEC] = SYMMLQ(A,B,...) also returns a vector of
%   of estimates of the SYMMLQ residual norms at each iteration, including
%   NORM(B-A*X0).
%
%   [X,FLAG,RELRES,ITER,RESVEC,RESVECCG] = SYMMLQ(A,B,...) also returns a
%   vector of estimates of the Conjugate Gradients residual norms at each
%   iteration.
%
%   Example:
%      n = 100; on = ones(n,1); A = spdiags([-2*on 4*on -2*on],-1:1,n,n);
%      b = sum(A,2); tol = 1e-10; maxit = 50; M = spdiags(4*on,0,n,n);
%      x = symmlq(A,b,tol,maxit,M);
%   Or, use this matrix-vector product function
%      %-------------------------------%
%      function y = afun(x,n)
%      y = 4 * x;
%      y(2:n) = y(2:n) - 2 * x(1:n-1);
%      y(1:n-1) = y(1:n-1) - 2 * x(2:n);
%      %-------------------------------%
%   as input to SYMMLQ:
%      x1 = symmlq(@(x)afun(x,n),b,tol,maxit,M);
%
%   Class support for inputs A,B,M1,M2,X0 and the output of AFUN:
%      float: double
%
%   See also BICG, BICGSTAB, BICGSTABL, CGS, GMRES, LSQR, MINRES, PCG,
%   QMR, TFQMR, ICHOL, ILU, FUNCTION_HANDLE.

%   Copyright 1984-2017 The MathWorks, Inc.

if (nargin < 2)
    error(message('MATLAB:symmlq:NotEnoughInputs'));
end

% Determine whether A is a matrix or a function.
[atype,afun,afcnstr] = iterchk(A);
if strcmp(atype,'matrix')
    % Check matrix and right hand side vector inputs have appropriate sizes
    [m,n] = size(A);
    if (m ~= n)
        error(message('MATLAB:symmlq:NonSquareMatrix'));
    end
    if ~isequal(size(b),[m,1])
        error(message('MATLAB:symmlq:RSHsizeMatchCoeffMatrix', m));
    end
else
    m = size(b,1);
    n = m;
    if ~iscolumn(b)
        error(message('MATLAB:symmlq:RSHnotColumn'));
    end
end

% Assign default values to unspecified parameters
if (nargin < 3) || isempty(tol)
    tol = 1e-6;
end
warned = 0;
if tol <= eps
    warning(message('MATLAB:symmlq:tooSmallTolerance'));
    warned = 1;
    tol = eps;
elseif tol >= 1
    warning(message('MATLAB:symmlq:tooBigTolerance'));
    warned = 1;
    tol = 1-eps;
end
if (nargin < 4) || isempty(maxit)
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
    if nargout >= 6
        resveccg = 0;              % resveccg(1) = norm(b-A*xcg) = norm(0)
    end
    if (nargout < 2)
        itermsg('symmlq',tol,maxit,0,flag,iter,NaN);
    end
    return
end

if ((nargin >= 5) && ~isempty(M1))
    existM1 = true;
    [m1type,m1fun,m1fcnstr] = iterchk(M1);
    if strcmp(m1type,'matrix')
        if ~isequal(size(M1),[m,m])
            error(message('MATLAB:symmlq:WrongPrecondSize', m));
        end
    end
else
    existM1 = false;
    m1type = 'matrix';
end

if ((nargin >= 6) && ~isempty(M2))
    existM2 = true;
    [m2type,m2fun,m2fcnstr] = iterchk(M2);
    if strcmp(m2type,'matrix')
        if ~isequal(size(M2),[m,m])
            error(message('MATLAB:symmlq:WrongPrecondSize', m));
        end
    end
else
    existM2 = false;
    m2type = 'matrix';
end

existM = existM1 || existM2;

if ((nargin >= 7) && ~isempty(x0))
    if ~isequal(size(x0),[n,1])
        error(message('MATLAB:symmlq:WrongInitGuessSize', n));
    else
        x = x0;
    end
else
    x = zeros(n,1);
end

if ((nargin > 7) && strcmp(atype,'matrix') && ...
        strcmp(m1type,'matrix') && strcmp(m2type,'matrix'))
    error(message('MATLAB:symmlq:TooManyInputs'));
end

% Set up for the method
flag = 1;
xmin = x;                          % Iterate which has minimal residual so far
imin = 0;                          % Iteration at which xmin was computed
tolb = tol * n2b;                  % Relative tolerance
r = b - iterapp('mtimes',afun,atype,afcnstr,x,varargin{:});
normr = norm(r);                   % Norm of residual

if (normr <= tolb)                 % Initial guess is a good enough solution
    flag = 0;
    relres = normr / n2b;
    iter = 0;
    resvec = normr;
    if nargout >= 6
        resveccg = normr;
    end
    if (nargout < 2)
        itermsg('symmlq',tol,maxit,0,flag,iter,relres);
    end
    return
end

resvec = zeros(maxit+1,1);         % Preallocate vector for SYMMLQ residuals
resvec(1) = normr;                 % resvec(1) = norm(b-A*x0)
if nargout >= 6
    resveccg = zeros(maxit+2,1);	 % Preallocate vector for CG residuals
    resveccg(1) = normr;           % resveccg(1) = norm(b-A*x0)
end
normrmin = normr;                  % Norm of minimum residual

vold = r;
if existM1
    u = iterapp('mldivide',m1fun,m1type,m1fcnstr,vold,varargin{:});
    if ~all(isfinite(u))
        flag = 2;
        relres = normr / n2b;
        iter = 0;
        resvec = resvec(1);
        if nargout >= 6
            resveccg = resveccg(1);
        end
        if nargout < 2
            itermsg('symmlq',tol,maxit,0,flag,iter,relres);
        end
        return
    end
else % no preconditioner
    u = vold;
end
if existM2
    v = iterapp('mldivide',m2fun,m2type,m2fcnstr,u,varargin{:});
    if ~all(isfinite(v))
        flag = 2;
        relres = normr / n2b;
        iter = 0;
        resvec = resvec(1);
        if nargout >= 6
            resveccg = resveccg(1);
        end
        if nargout < 2
            itermsg('symmlq',tol,maxit,0,flag,iter,relres);
        end
        return
    end
else % no preconditioner
    v = u;
end
beta1 = vold' * v;
if (beta1 <= 0)
    flag = 5;
    relres = normr / n2b;
    iter = 0;
    resvec = resvec(1);
    if nargout >= 6
        resveccg = resveccg(1);
    end
    if nargout < 2
        itermsg('symmlq',tol,maxit,0,flag,iter,relres);
    end
    return
end
beta1 = sqrt(beta1);
vv = v / beta1;
wbar = vv;
v = iterapp('mtimes',afun,atype,afcnstr,vv,varargin{:});
alpha = vv' * v;
v = v - (alpha/beta1) * vold;

% Local reorthogonalization
numer = vv' * v;
denom = vv' * vv;
v = v - (numer/denom) * vv;
volder = vold;
vold = v;

if existM1
    u = iterapp('mldivide',m1fun,m1type,m1fcnstr,vold,varargin{:});
    if ~all(isfinite(u))
        flag = 2;
        relres = normr / n2b;
        iter = 0;
        resvec = resvec(1);
        if nargout >= 6
            resveccg = resveccg(1);
        end
        if nargout < 2
            itermsg('symmlq',tol,maxit,0,flag,iter,relres);
        end
        return
    end
else % no preconditioner
    u = vold;
end
if existM2
    v = iterapp('mldivide',m2fun,m2type,m2fcnstr,u,varargin{:});
    if ~all(isfinite(v))
        flag = 2;
        relres = normr / n2b;
        iter = 0;
        resvec = resvec(1);
        if nargout >= 6
            resveccg = resveccg(1);
        end
        if nargout < 2
            itermsg('symmlq',tol,maxit,0,flag,iter,relres);
        end
        return
    end
else % no preconditioner
    v = u;
end
betaold = beta1;
beta = vold' * v;
if (beta < 0)
    flag = 5;
    relres = normr / n2b;
    iter = 0;
    resvec = resvec(1);
    if nargout >= 6
        resveccg = resveccg(1);
    end
    if nargout < 2
        itermsg('symmlq',tol,maxit,0,flag,iter,relres);
    end
    return
end
beta = sqrt(beta);
gammabar = alpha;
deltabar = beta;
gamma = sqrt(gammabar^2 + beta^2);
cs = gammabar / gamma;
sn = beta / gamma;
zeta = beta1 / gamma;
epsilonzeta = 0;
% estimate norm of 1st CG iterate.
if existM
    resveccg(2,1) = norm((beta1/gammabar)*vold);
else
    normrcgcs = abs(beta1 * sn);
    % It's possible that this cs value is zero (CG iterate does not exist)
    if (cs == 0)
        normrcg = Inf;
    else
        normrcg = normrcgcs / abs(cs);
    end
    resveccg(2,1) = normrcg;
end
% Check normrcg for convergence.
if resveccg(2,1) <= tolb
    nits = 0;
    x = x + (zeta/cs)*wbar;
    flag = 0;
    iter = 0;   % we have taken a half step at this point
else
    nits = maxit;
end

stag = 0;                          % stagnation of the method
moresteps = 0;
maxmsteps = min([floor(n/50),5,n-maxit]);
maxstagsteps = 3;

% loop over maxit iterations (unless convergence or failure)

for ii = 1 : nits
    
    vv = v / beta;
    w = cs * wbar + sn * vv;
    % Check for stagnation of the method
    if abs(zeta)*norm(w) < eps*norm(x)
        % increment the number of consecutive iterates which are the same
        stag = stag + 1;
    else
        % this iterate is not the same as the previous one
        stag = 0;
    end
    x = x + zeta * w;
    wbar = sn * wbar - cs * vv;
    v = iterapp('mtimes',afun,atype,afcnstr,vv,varargin{:});
    v = v - (beta / betaold) * volder;
    alpha = vv' * v;
    v = v - (alpha / beta) * vold;
    volder = vold;
    vold = v;
    if existM1
        u = iterapp('mldivide',m1fun,m1type,m1fcnstr,vold,varargin{:});
        if ~all(isfinite(u))
            flag = 2;
            break
        end
    else % no preconditioner
        u = vold;
    end
    if existM2
        v = iterapp('mldivide',m2fun,m2type,m2fcnstr,u,varargin{:});
        if ~all(isfinite(v))
            flag = 2;
            break
        end
    else % no preconditioner
        v = u;
    end
    betaold = beta;
    beta = vold' * v;
    if (beta < 0)
        flag = 5;
        break
    end
    beta = sqrt(beta);
    delta = cs * deltabar + sn * alpha;
    deltazeta = - delta * zeta;
    gammabar = sn * deltabar - cs * alpha;
    epsilon = sn * beta;
    deltabar = - cs * beta;
    gamma = sqrt(gammabar^2 + beta^2);
    csold = cs;
    snzeta = sn * zeta;
    cs = gammabar / gamma;
    sn = beta / gamma;
    epszdelz = epsilonzeta + deltazeta;
    epsilonzeta = - epsilon * zeta;
    zeta = epszdelz / gamma;
    % estimate norm of ii-th SYMMLQ iterate and (ii+1)-st CG iterate.
    if existM
        normr = norm((zeta*gamma/betaold)*volder - snzeta*vold);
        normrcg = norm((csold*epszdelz/gammabar - snzeta)*vold);
    else
        normr = sqrt(epszdelz^2 + epsilonzeta^2);
        normrcgcs = normrcgcs * abs(sn);
        if (cs == 0)
            normrcg = Inf;
        else
            normrcg = normrcgcs / abs(cs);
        end
    end
    normr_act = normr;
    normrcg_act = normrcg;
    resvec(ii+1,1) = normr;
    resveccg(ii+2,1) = normrcg;
    % check for convergence
    if (normr <= tolb || stag >= maxstagsteps || moresteps)
        % double check residual norm is less than tolerance
        r = b - iterapp('mtimes',afun,atype,afcnstr,x,varargin{:});
        normr_act = norm(r);
        resvec(ii+1) = normr_act;
        if (normr_act <= tolb)
            flag = 0;
            iter = ii;
            break
        else
            if stag >= maxstagsteps && moresteps == 0
                stag = 0;
            end
            moresteps = moresteps + 1;
            if moresteps >= maxmsteps
                if ~warned
                    warning(message('MATLAB:symmlq:tooSmallTolerance'));
                end
                flag = 3;
                iter = ii;
                break;
            end
        end
    end
    if (normrcg <= tolb || stag >= maxstagsteps || moresteps)
        % Conjugate Gradients solution
        xcg = x + (epszdelz/gammabar) * wbar;
        % double check CG residual norm is less than tolerance
        r = b - iterapp('mtimes',afun,atype,afcnstr,xcg,varargin{:});
        normrcg_act = norm(r);
        if (normrcg_act <= tolb)
            x = xcg;
            flag = 0;
            iter = ii;
            break
        else
            if stag >= maxstagsteps && moresteps == 0
                stag = 0;
            end
            moresteps = moresteps + 1;
            if moresteps >= maxmsteps
                if ~warned
                    warning(message('MATLAB:symmlq:tooSmallTolerance'));
                end
                flag = 3;
                iter = ii;
                break;
            end
        end
    end
    if (normr_act < normrmin)     % update minimal norm quantities
        normrmin = normr_act;
        xmin = x;
        imin = ii;
    end
    if (normrcg_act < normrmin)
        normrmin = normrcg_act;
        xmin = x + (epszdelz/gammabar) * wbar;
        imin = ii;
    end
    if (stag >= maxstagsteps)     % 3 consecutive iterates are the same
        flag = 3;
        break
    end    
end                               % for ii = 1 : maxit

% returned solution is first with minimal residual
r = b - iterapp('mtimes',afun,atype,afcnstr,x,varargin{:});
normr = norm(r);                  % Norm of residual
if (flag == 0)
    relres = normr / n2b;
else
    r_comp = b - iterapp('mtimes',afun,atype,afcnstr,xmin,varargin{:});
    if norm(r_comp) <= normr
        x = xmin;
        iter = imin;
        relres = norm(r_comp) / n2b;
    else
        iter = ii;
        relres = normr/n2b;
    end
end

% truncate the zeros from resvec
if nits == 0    % set ii for the case where we never enter the loop
    ii = 0;
end
if ((flag <= 1) || (flag == 3))
    resvec = resvec(1:ii+1);
    resveccg = resveccg(1:ii+2);
else
    resvec = resvec(1:ii);
    resveccg = resveccg(1:ii+1);
end

% only display a message if the output flag is not used
if (nargout < 2)
    itermsg('symmlq',tol,maxit,ii,flag,iter,relres);
end
