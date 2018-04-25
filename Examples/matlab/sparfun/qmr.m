function [x,flag,relres,iter,resvec] = qmr(A,b,tol,maxit,M1,M2,x0,varargin)
%QMR   Quasi-Minimal Residual Method.
%   X = QMR(A,B) attempts to solve the system of linear equations A*X=B for
%   X. The N-by-N coefficient matrix A must be square and the right hand
%   side column vector B must have length N.
%
%   X = QMR(AFUN,B) accepts a function handle AFUN instead of the matrix A.
%   AFUN(X,'notransp') accepts a vector input X and returns the
%   matrix-vector product A*X while AFUN(X,'transp') returns A'*X. In all
%   of the following syntaxes, you can replace A by AFUN.
%
%   X = QMR(A,B,TOL) specifies the tolerance of the method. If TOL is []
%   then QMR uses the default, 1e-6.
%
%   X = QMR(A,B,TOL,MAXIT) specifies the maximum number of iterations. If
%   MAXIT is [] then QMR uses the default, min(N,20).
%
%   X = QMR(A,B,TOL,MAXIT,M) and X = QMR(A,B,TOL,MAXIT,M1,M2) use
%   preconditioners M or M=M1*M2 and effectively solve the system
%   inv(M)*A*X = inv(M)*B for X. If M is [] then a preconditioner is not
%   applied. M may be a function handle MFUN such that MFUN(X,'notransp')
%   returns M\X and MFUN(X,'transp') returns M'\X.
%
%   X = QMR(A,B,TOL,MAXIT,M1,M2,X0) specifies the initial guess. If X0 is
%   [] then QMR uses the default, an all zero vector.
%
%   [X,FLAG] = QMR(A,B,...) also returns a convergence FLAG:
%    0 QMR converged to the desired tolerance TOL within MAXIT iterations.
%    1 QMR iterated MAXIT times but did not converge.
%    2 preconditioner M was ill-conditioned.
%    3 QMR stagnated (two consecutive iterates were the same).
%    4 one of the scalar quantities calculated during QMR became too
%      small or too large to continue computing.
%
%   [X,FLAG,RELRES] = QMR(A,B,...) also returns the relative residual
%   NORM(B-A*X)/NORM(B). If FLAG is 0, then RELRES <= TOL.
%
%   [X,FLAG,RELRES,ITER] = QMR(A,B,...) also returns the iteration number
%   at which X was computed: 0 <= ITER <= MAXIT.
%
%   [X,FLAG,RELRES,ITER,RESVEC] = QMR(A,B,...) also returns a vector of the
%   residual norms at each iteration, including NORM(B-A*X0).
%
%   Example:
%      n = 100; on = ones(n,1); A = spdiags([-2*on 4*on -on],-1:1,n,n);
%      b = sum(A,2); tol = 1e-8; maxit = 15;
%      M1 = spdiags([on/(-2) on],-1:0,n,n);
%      M2 = spdiags([4*on -on],0:1,n,n);
%      x = qmr(A,b,tol,maxit,M1,M2,[]);
%   Or, use this matrix-vector product function
%      %------------------------------------%
%      function y = afun(x,n,transp_flag)
%      if strcmp(transp_flag,'transp')
%         y = 4 * x;
%         y(1:n-1) = y(1:n-1) - 2 * x(2:n);
%         y(2:n) = y(2:n) - x(1:n-1);
%      elseif strcmp(transp_flag,'notransp')
%         y = 4 * x;
%         y(2:n) = y(2:n) - 2 * x(1:n-1);
%         y(1:n-1) = y(1:n-1) - x(2:n);
%      end
%      %------------------------------------%
%   as input to QMR:
%      x1 = qmr(@(x,tflag)afun(x,n,tflag),b,tol,maxit,M1,M2);
%
%   Class support for inputs A,B,M1,M2,X0 and the output of AFUN:
%      float: double
%
%   See also BICG, BICGSTAB, BICGSTABL, CGS, GMRES, LSQR, MINRES, PCG,
%   SYMMLQ, TFQMR, ILU, FUNCTION_HANDLE.

%   Copyright 1984-2013 The MathWorks, Inc.

% Check for an acceptable number of input arguments
if nargin < 2
    error(message('MATLAB:qmr:NotEnoughInputs'));
end

% Determine whether A is a matrix or a function.
[atype,afun,afcnstr] = iterchk(A);
if strcmp(atype,'matrix')
    % Check matrix and right hand side vector inputs have appropriate sizes
    [m,n] = size(A);
    if (m ~= n)
        error(message('MATLAB:qmr:NonSquareMatrix'));
    end
    if ~isequal(size(b),[m,1])
        error(message('MATLAB:qmr:RSHsizeMatchCoeffMatrix', m));
    end
else
    m = size(b,1);
    n = m;
    if ~iscolumn(b)
        error(message('MATLAB:qmr:RSHnotColumn'));
    end
end

% Assign default values to unspecified parameters
if nargin < 3 || isempty(tol)
    tol = 1e-6;
end
warned = 0;
if tol < eps
    warning(message('MATLAB:qmr:tooSmallTolerance'));
    warned = 1;
    tol = eps;
elseif tol >= 1
    warning(message('MATLAB:qmr:tooBigTolerance'));
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
        itermsg('qmr',tol,maxit,0,flag,iter,NaN);
    end
    return
end

if ((nargin >= 5) && ~isempty(M1))
    existM1 = 1;
    [m1type,m1fun,m1fcnstr] = iterchk(M1);
    if strcmp(m1type,'matrix')
        if ~isequal(size(M1),[m,m])
            error(message('MATLAB:qmr:WrongPrecondSize', m));
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
            error(message('MATLAB:qmr:WrongPrecondSize', m));
        end
    end
else
    existM2 = 0;
    m2type = 'matrix';
end

if ((nargin >= 7) && ~isempty(x0))
    if ~isequal(size(x0),[n,1])
        error(message('MATLAB:qmr:WrongInitGuessSize', n));
    else
        x = x0;
    end
else
    x = zeros(n,1);
end

if ((nargin > 7) && strcmp(atype,'matrix') && ...
        strcmp(m1type,'matrix') && strcmp(m2type,'matrix'))
    error(message('MATLAB:qmr:TooManyInputs'));
end

% Set up for the method
flag = 1;
xmin = x;                          % Iterate which has minimal residual so far
imin = 0;                          % Iteration at which xmin was computed
tolb = tol * n2b;                  % Relative tolerance
r = b - iterapp('mtimes',afun,atype,afcnstr,x,varargin{:},'notransp');
normr = norm(r);                   % Norm of residual
normr_act = normr;

if (normr <= tolb)                 % Initial guess is a good enough solution
    flag = 0;
    relres = normr / n2b;
    iter = 0;
    resvec = normr;
    if (nargout < 2)
        itermsg('qmr',tol,maxit,0,flag,iter,relres);
    end
    return
end

vt = r;
resvec = zeros(maxit+1,1);         % Preallocate vector for norm of residuals
resvec(1) = normr;                 % resvec(1) = norm(b-A*x0)
normrmin = normr;                  % Norm of residual from xmin

if existM1
    y = iterapp('mldivide',m1fun,m1type,m1fcnstr,vt,varargin{:},'notransp');
    if ~all(isfinite(y))
        flag = 2;
        relres = normr/n2b;
        iter = 0;
        resvec = normr;
        if nargout < 2
            itermsg('qmr',tol,maxit,0,flag,iter,relres);
        end
        return
    end
else
    y = vt;
end
rho = norm(y);
wt = r;
if existM2
    z = iterapp('mldivide',m2fun,m2type,m2fcnstr,wt,varargin{:},'transp');
    if ~all(isfinite(z))
        flag = 2;
        relres = normr/n2b;
        iter = 0;
        resvec = normr;
        if nargout < 2
            itermsg('qmr',tol,maxit,0,flag,iter,relres);
        end
        return
    end
else
    z = wt;
end
psi = norm(z);
gamm = 1;
eta = -1;
stag = 0;                          % stagnation of the method
moresteps = 0;
maxmsteps = min([floor(n/50),5,n-maxit]);
maxstagsteps = 3;

% loop over maxit iterations (unless convergence or failure)

for ii = 1 : maxit
    if (rho == 0 || isinf(rho)) || (psi == 0 || isinf(psi))
        flag = 4;
        break
    end
    v = vt / rho;
    y = y / rho;
    w = wt / psi;
    z = z / psi;
    delta = z' * y;
    if (delta == 0) || isinf(delta)
        flag = 4;
        break
    end
    if existM2
        yt = iterapp('mldivide',m2fun,m2type,m2fcnstr,y,varargin{:},'notransp');
        if ~all(isfinite(yt))
            flag = 2;
            break
        end
    else
        yt = y;
    end
    if existM1
        zt = iterapp('mldivide',m1fun,m1type,m1fcnstr,z,varargin{:},'transp');
        if ~all(isfinite(zt))
            flag = 2;
            break
        end
    else
        zt = z;
    end
    if ii == 1
        p = yt;
        q = zt;
    else
        pde = psi * delta / epsilon;
        if (pde == 0) || ~isfinite(pde)
            flag = 4;
            break
        end
        rde = rho * conj(delta/epsilon);
        if (rde == 0) || ~isfinite(rde)
            flag = 4;
            break
        end
        p = yt - pde * p;
        q = zt - rde * q;
    end
    pt = iterapp('mtimes',afun,atype,afcnstr,p,varargin{:},'notransp');
    epsilon = q' * pt;
    if (epsilon == 0) || isinf(epsilon)
        flag = 4;
        break
    end
    beta = epsilon / delta;
    if (beta == 0) || isinf(beta)
        flag = 4;
        break
    end
    vt = pt - beta * v;
    if existM1
        y = iterapp('mldivide',m1fun,m1type,m1fcnstr,vt,varargin{:},'notransp');
        if ~all(isfinite(y))
            flag = 2;
            break
        end
    else
        y = vt;
    end
    rho1 = rho;
    rho = norm(y);
    %  wt = A' * q - beta * w;
    if strcmp(atype,'matrix')
        wt = A' * q;
    else
        wt = iterapp('mtimes',afun,atype,afcnstr,q,varargin{:},'transp');
    end
    wt = wt - conj(beta) * w;
    if existM2
        z = iterapp('mldivide',m2fun,m2type,m2fcnstr,wt,varargin{:},'transp');
        if ~all(isfinite(z))
            flag = 2;
            break
        end
    else
        z = wt;
    end
    psi = norm(z);
    if ii > 1
        thet1 = thet;
    end
    thet = rho / (gamm * abs(beta));
    gamm1 = gamm;
    gamm = 1 / sqrt(1 + thet^2);
    if gamm == 0
        flag = 4;
        break
    end
    eta = - eta * rho1 * gamm^2 / (beta * gamm1^2);
    if isinf(eta)
        flag = 4;
        break
    end
    if ii == 1
        d = eta * p;
        s = eta * pt;
    else
        d = eta * p + (thet1 * gamm)^2 * d;
        s = eta * pt + (thet1 * gamm)^2 * s;
    end
    
    % Check for stagnation of the method
    if norm(d) < eps*norm(x)
        stag = stag + 1;
    else
        stag = 0;
    end
    
    x = x + d;                     % form the new iterate
    r = r - s;
    normr = norm(r);
    normr_act = normr;
    resvec(ii+1) = normr;
    
    % check for convergence
    if (normr <= tolb || stag >= maxstagsteps || moresteps)
        r = b - iterapp('mtimes',afun,atype,afcnstr,x,varargin{:},'notransp');
        normr_act = norm(r);
        resvec(ii+1,1) = normr_act;
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
                    warning(message('MATLAB:qmr:tooSmallTolerance'));
                end
                flag = 3;
                iter = ii;
                break;
            end
        end
    end   
    
    if normr_act < normrmin        % update minimal norm quantities
        normrmin = normr_act;
        xmin = x;
        imin = ii;
    end
    
    if stag >= maxstagsteps
        flag = 3;
        break
    end
end                                % for ii = 1 : maxit

% returned solution is first with minimal residual
if flag == 0
    relres = normr_act / n2b;
else
    r = b - iterapp('mtimes',afun,atype,afcnstr,xmin,varargin{:},'notransp');
    if norm(r) <= normr_act
        x = xmin;
        iter = imin;
        relres = norm(r) / n2b;
    else
        iter = ii;
        relres = normr_act / n2b;
    end
end

% truncate the zeros from resvec
if flag <= 1 || flag == 3
    resvec = resvec(1:ii+1);
else
    resvec = resvec(1:ii);
end

% only display a message if the output flag is not used
if nargout < 2
    itermsg('qmr',tol,maxit,ii,flag,iter,relres);
end
