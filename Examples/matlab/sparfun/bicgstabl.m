function [x,flag,relres,iter,resvec] = bicgstabl(A,b,tol,maxit,M1,M2,x0,varargin)
%BICGSTABL   BiConjugate Gradients Stabilized(l) Method.
%   X = BICGSTABL(A,B) attempts to solve the system of linear equations
%   A*X=B for X. The N-by-N coefficient matrix A must be square and the
%   right hand side column vector B must have length N.
%
%   X = BICGSTABL(AFUN,B) accepts a function handle AFUN instead of the
%   matrix A. AFUN(X) accepts a vector input X and returns the
%   matrix-vector product A*X. In all of the following syntaxes, you can
%   replace A by AFUN.
%
%   X = BICGSTABL(A,B,TOL) specifies the tolerance of the method. If TOL is
%   [] then BICGSTABL uses the default, 1e-6.
%
%   X = BICGSTABL(A,B,TOL,MAXIT) specifies the maximum number of iterations.
%   If MAXIT is [] then BICGSTABL uses the default, min(N,20).
%
%   X = BICGSTABL(A,B,TOL,MAXIT,M) and X = BICGSTABL(A,B,TOL,MAXIT,M1,M2)
%   use preconditioner M or M=M1*M2 and effectively solve the system
%   A*inv(M)*X = B for X. If M is [] then a preconditioner is not
%   applied. M may be a function handle returning M\X.
%
%   X = BICGSTABL(A,B,TOL,MAXIT,M1,M2,X0) specifies the initial guess.  If
%   X0 is [] then BICGSTABL uses the default, an all zero vector.
%
%   [X,FLAG] = BICGSTABL(A,B,...) also returns a convergence FLAG:
%    0 BICGSTABL converged to the desired tolerance TOL within MAXIT iterations.
%    1 BICGSTABL iterated MAXIT times but did not converge.
%    2 preconditioner M was ill-conditioned.
%    3 BICGSTABL stagnated (two consecutive iterates were the same).
%    4 one of the scalar quantities calculated during BICGSTABL became
%      too small or too large to continue computing.
%
%   [X,FLAG,RELRES] = BICGSTABL(A,B,...) also returns the relative residual
%   NORM(B-A*X)/NORM(B). If FLAG is 0, then RELRES <= TOL.
%
%   [X,FLAG,RELRES,ITER] = BICGSTABL(A,B,...) also returns the iteration
%   number at which X was computed: 0 <= ITER <= MAXIT. ITER may be k/4 where
%   k is some integer, indicating convergence at a given quarter iteration.
%
%   [X,FLAG,RELRES,ITER,RESVEC] = BICGSTABL(A,B,...) also returns a vector
%   of the residual norms at each quarter iteration, including NORM(B-A*X0).
%
%   Example:
%      n = 21; A = gallery('wilk',n);  b = sum(A,2);
%      tol = 1e-12;  maxit = 15; M = diag([10:-1:1 1 1:10]);
%      x = bicgstabl(A,b,tol,maxit,M);
%   Or, use this matrix-vector product function
%      %-----------------------------------------------------------------%
%      function y = afun(x,n)
%      y = [0; x(1:n-1)] + [((n-1)/2:-1:0)'; (1:(n-1)/2)'].*x+[x(2:n); 0];
%      %-----------------------------------------------------------------%
%   and this preconditioner backsolve function
%      %------------------------------------------%
%      function y = mfun(r,n)
%      y = r ./ [((n-1)/2:-1:1)'; 1; (1:(n-1)/2)'];
%      %------------------------------------------%
%   as inputs to BICGSTABL:
%      x1 = bicgstabl(@(x)afun(x,n),b,tol,maxit,@(x)mfun(x,n));
%
%   Class support for inputs A,B,M1,M2,X0 and the output of AFUN:
%      float: double
%
%   See also BICG, BICGSTAB, CGS, GMRES, LSQR, MINRES, PCG, QMR, SYMMLQ,
%   TFQMR, ILU, FUNCTION_HANDLE.

%   Reference:
%      G. Sleijpen, H. van der Vorst, and D. Fokkema,
%      BiCGstab(ell) and other Hybrid Bi-CG Methods, Numerical Algorithms,
%      7 (1994), pp. 75-109.

%   Copyright 2008-2013 The MathWorks, Inc.

% ell is fixed to be 2. The user is free to modify this parameter.
ell = 2;
% Check for an acceptable number of input arguments
if nargin < 2
    error(message('MATLAB:bicgstabl:NotEnoughInputs'));
end

% Determine whether A is a matrix or a function.
[atype,afun,afcnstr] = iterchk(A);
if strcmp(atype,'matrix')
    % Check matrix and right hand side vector inputs have appropriate sizes.
    [m,n] = size(A);
    if (m ~= n)
        error(message('MATLAB:bicgstabl:NonSquareMatrix'));
    end
    if ~isequal(size(b),[m,1])
        error(message('MATLAB:bicgstabl:RSHsizeMatchCoeffMatrix', m));
    end
else
    m = size(b,1);
    n = m;
    if ~iscolumn(b)
        error(message('MATLAB:bicgstabl:RSHnotColumn'));
    end
end

% Assign default values to unspecified parameters
if nargin < 3 || isempty(tol)
    tol = 1e-6;
end
warned = 0;
if tol < eps
    warning(message('MATLAB:bicgstabl:tooSmallTolerance'));
    warned = 1;
    tol = eps;
elseif tol >= 1
    warning(message('MATLAB:bicgstabl:tooBigTolerance'));
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
        itermsg('bicgstabl',tol,maxit,0,flag,iter,NaN);
    end
    return
end

if ((nargin >= 5) && ~isempty(M1))
    existM1 = 1;
    [m1type,m1fun,m1fcnstr] = iterchk(M1);
    if strcmp(m1type,'matrix')
        if ~isequal(size(M1),[m,m])
            error(message('MATLAB:bicgstabl:WrongPrecondSize', m));
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
            error(message('MATLAB:bicgstabl:WrongPrecondSize', m));
        end
    end
else
    existM2 = 0;
    m2type = 'matrix';
end

if ((nargin >= 7) && ~isempty(x0))
    if ~isequal(size(x0),[n,1])
        error(message('MATLAB:bicgstabl:WrongInitGuessSize', n));
    else
        x = x0;
    end
else
    x = zeros(n,1);
    x0 = x;
end

if ((nargin > 7) && strcmp(atype,'matrix') && ...
        strcmp(m1type,'matrix') && strcmp(m2type,'matrix'))
    error(message('MATLAB:bicgstabl:TooManyInputs'));
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
        itermsg('bicgstabl',tol,maxit,0,flag,iter,relres);
    end
    return
end

ukm1 = zeros(n,1);
rk = b - iterapp('mtimes',afun,atype,afcnstr,x0,varargin{:});
xk = zeros(n,1);
r0 = rk;
rho0 = 1;
omega = 1;
ut = zeros(n,ell+1);
rt = zeros(n,ell+1);
alpha = 0;
Tau = zeros(ell+1,ell+1);
sigma = zeros(ell+1,1);
gamma = zeros(ell+1,1);
gammap = zeros(ell+1,1);
gammapp = zeros(ell+1,1);
stag = 0;                          % stagnation of the method

moresteps = 0;
maxmsteps = min([floor(n/50),4*ell,n-maxit]);
maxstagsteps = 3;
resvec = zeros(2*ell*maxit+1,1);
resvec(1) = norm(rk);
normrmin = resvec(1);

for kk = 1 : maxit
    ut(:,1) = ukm1;  rt(:,1) = rk;    xt = xk;
    rho0 = -omega*rho0;
    for jj = 1 : ell
        rho1 = r0'*rt(:,jj);
        if rho0 == 0 || isinf(rho0)
            flag = 4;
            resvec = resvec(1:2*ell*(kk-1)+jj);
            break;
        end
        beta = alpha*rho1/rho0;
        rho0 = rho1;
        ut(:,1:jj) = rt(:,1:jj) - beta*ut(:,1:jj);
        if existM1
            put = iterapp('mldivide',m1fun,m1type,m1fcnstr,ut(:,jj),varargin{:});
            if ~all(isfinite(put))
                flag = 2;
                resvec = resvec(1:2*ell*(kk-1)+jj);
                break
            end
        else
            put = ut(:,jj);
        end
        if existM2
            put = iterapp('mldivide',m2fun,m2type,m2fcnstr,put,varargin{:});
            if ~all(isfinite(put))
                flag = 2;
                resvec = resvec(1:2*ell*(kk-1)+jj);
                break
            end
        end
        ut(:,jj+1) = iterapp('mtimes',afun,atype,afcnstr,put,varargin{:});
        
        gamma_s = r0'*ut(:,jj+1);
        if gamma_s == 0 || isinf(gamma_s)
            flag = 4;
            resvec = resvec(1:2*ell*(kk-1)+jj);
            break;
        end
        alpha = rho0/gamma_s;
        rt(:,1:jj) = rt(:,1:jj)-alpha*ut(:,2:jj+1);
        %rt(:,jj+1) = A*Mfun(rt(:,jj));
        if existM1
            prt = iterapp('mldivide',m1fun,m1type,m1fcnstr,rt(:,jj),varargin{:});
            if ~all(isfinite(prt))
                flag = 2;
                resvec = resvec(1:2*ell*(kk-1)+jj);
                break
            end
        else
            prt = rt(:,jj);
        end
        if existM2
            prt = iterapp('mldivide',m2fun,m2type,m2fcnstr,prt,varargin{:});
            if ~all(isfinite(prt))
                flag = 2;
                resvec = resvec(1:2*ell*(kk-1)+jj);
                break
            end
        end
        rt(:,jj+1) = iterapp('mtimes',afun,atype,afcnstr,prt,varargin{:});
        
        normr = norm(rt(:,1));
        normr_act = normr;
        resvec((kk-1)*ell*2+jj+1) = normr_act;
        
        if abs(alpha)*norm(ut(:,1)) < eps*norm(xt)
            stag = stag + 1;
        else
            stag = 0;
        end
        xt = xt + alpha*ut(:,1);   % half-iterates
        
        % check for convergence
        if (normr <= tolb || stag >= maxstagsteps || moresteps)
            % double check residual norm is less than tolerance
            if existM1
                pxt = iterapp('mldivide',m1fun,m1type,m1fcnstr,xt,varargin{:});
                if ~all(isfinite(pxt))
                    flag = 2;
                    resvec = resvec(1:2*ell*(kk-1)+jj+1);
                    break
                end
            else
                pxt = xt;
            end
            if existM2
                pxt = iterapp('mldivide',m2fun,m2type,m2fcnstr,pxt,varargin{:});
                if ~all(isfinite(pxt))
                    flag = 2;
                    resvec = resvec(1:2*ell*(kk-1)+jj+1);
                    break
                end
            end
            
            rt(:,1) = b - iterapp('mtimes',afun,atype,afcnstr,x0+pxt,varargin{:});
            normr_act = norm(rt(:,1));
            resvec((kk-1)*ell*2+1+jj) = normr_act;
            if (normr_act <= tolb)
                flag = 0;
                iter = ((kk-1)*ell*2+jj)/(ell*2);
                resvec = resvec(1:(kk-1)*ell*2+jj+1);
                break
            else
                if stag >= maxstagsteps && moresteps == 0
                    stag = 0;
                end
                moresteps = moresteps + 1;
                if moresteps >= maxmsteps
                    if ~warned
                        warning(message('MATLAB:bicgstabl:tooSmallTolerance'));
                    end
                    flag = 3;
                    iter = ((kk-1)*ell*2+jj)/(ell*2);
                    resvec = resvec(1:(kk-1)*ell*2+jj+1);
                    break;
                end
            end
        end
        
        if normr_act < normrmin    % update minimal norm quantities
            normrmin = normr_act;
            xmin = xt;
            imin = ((kk-1)*ell*2+jj)/(ell*2);
        end
        if stag >= maxstagsteps    % 3 iterates are the same
            flag = 3;
            break
        end
    end
    if flag ~= 1,   break;  end;
    for jj = 2 : ell+1
        for ii = 2 : jj-1
            Tau(ii,jj) = rt(:,jj)'*rt(:,ii)/sigma(ii);
            rt(:,jj) = rt(:,jj) - Tau(ii,jj)*rt(:,ii);
        end
        sigma(jj) = rt(:,jj)'*rt(:,jj);
        if sigma(jj) == 0 || isinf(sigma(jj))
            flag = 4;
            resvec = resvec(1:2*ell*(kk-1)+ell+1);
            break;
        end
        gammap(jj) = (rt(:,1)'*rt(:,jj))/sigma(jj);
    end
    if flag == 4,   break;  end;
    gamma(ell+1) = gammap(ell+1);
    omega = gamma(ell+1);
    for jj = ell : -1 : 2
        gamma(jj) = gammap(jj) - Tau(jj,jj+1:ell+1)*gamma(jj+1:ell+1);
    end
    for jj = 2 : ell
        gammapp(jj) = gamma(jj+1) + Tau(jj,jj+1:ell)*gamma(jj+2:ell+1);
    end
    
    if abs(gamma(2))*norm(rt(:,1)) < eps*norm(xt)
        stag = stag + 1;
    else
        stag = 0;
    end
    xt = xt + gamma(2)*rt(:,1);
    rt(:,1) = rt(:,1) - gammap(ell+1)*rt(:,ell+1);
    ut(:,1) = ut(:,1) - gamma(ell+1)*ut(:,ell+1);
    normr = norm(rt(:,1));
    normr_act = normr;
    resvec((kk-1)*ell*2+ell+2)  = normr_act;
    
    % check for convergence
    if normr <= tolb || stag >= maxstagsteps || moresteps
        % double check residual norm is less than tolerance
        if existM1
            pxt = iterapp('mldivide',m1fun,m1type,m1fcnstr,xt,varargin{:});
            if ~all(isfinite(pxt))
                flag = 2;
                resvec = resvec(1:(kk-1)*ell*2+ell+2);
                break
            end
        else
            pxt = xt;
        end
        if existM2
            pxt = iterapp('mldivide',m2fun,m2type,m2fcnstr,pxt,varargin{:});
            if ~all(isfinite(pxt))
                flag = 2;
                resvec = resvec(1:(kk-1)*ell*2+ell+2);
                break
            end
        end
        
        rt(:,1) = b - iterapp('mtimes',afun,atype,afcnstr,x0+pxt,varargin{:});
        normr_act = norm(rt(:,1));
        resvec((kk-1)*ell*2+ell+2) = normr_act;
        if (normr_act <= tolb)
            flag = 0;
            iter = ((kk-1)*ell*2+ell+1)/(ell*2);
            resvec = resvec(1:(kk-1)*ell*2+ell+2);
            break
        else
            if stag >= maxstagsteps && moresteps == 0
                stag = 0;
            end
            moresteps = moresteps + 1;
            if moresteps >= maxmsteps
                if ~warned
                    warning(message('MATLAB:bicgstabl:tooSmallTolerance'));
                end
                flag = 3;
                iter = ((kk-1)*ell*2+ell+1)/(ell*2);
                resvec = resvec(1:(kk-1)*ell*2+ell+2);
                break;
            end
        end
    end
    
    if (normr_act < normrmin)      % update minimal norm quantities
        normrmin = normr_act;
        xmin = xt;
        imin = ((kk-1)*ell*2+ell+1)/(ell*2);
    end
    if (stag >= maxstagsteps)      % 3 iterates are the same
        flag = 3;
        break
    end   
    
    for jj = 2 : ell
        ut(:,1) = ut(:,1) - gamma(jj)*ut(:,jj);
        if abs(gammapp(jj))*norm(rt(:,jj)) < eps*norm(xt)
            stag = stag + 1;
        else
            stag = 0;
        end
        xt = xt + gammapp(jj)*rt(:,jj);
        rt(:,1) = rt(:,1) - gammap(jj)*rt(:,jj);
        normr = norm(rt(:,1));
        normr_act = normr;
        resvec((kk-1)*ell*2+ell+1+jj) = normr_act;
        % check for convergence
        if (normr <= tolb || stag >= maxstagsteps || moresteps)
            % double check residual norm is less than tolerance
            if existM1
                pxt = iterapp('mldivide',m1fun,m1type,m1fcnstr,xt,varargin{:});
                if ~all(isfinite(pxt))
                    flag = 2;
                    resvec = resvec(1:(kk-1)*ell*2+ell+1+jj);
                    break
                end
            else
                pxt = xt;
            end
            if existM2
                pxt = iterapp('mldivide',m2fun,m2type,m2fcnstr,pxt,varargin{:});
                if ~all(isfinite(pxt))
                    flag = 2;
                    resvec = resvec(1:(kk-1)*ell*2+ell+1+jj);
                    break
                end
            end
            
            rt(:,1) = b - iterapp('mtimes',afun,atype,afcnstr,x0+pxt,varargin{:});
            normr_act = norm(rt(:,1));
            resvec((kk-1)*ell*2+ell+1+jj) = normr_act;
            if (normr_act <= tolb)
                flag = 0;
                iter = ((kk-1)*ell*2+ell+jj)/(ell*2);
                resvec = resvec(1:(kk-1)*ell*2+ell+jj+1);
                break
            else
                if stag >= maxstagsteps && moresteps == 0
                    stag = 0;
                end
                moresteps = moresteps + 1;
                if moresteps >= maxmsteps
                    if ~warned
                        warning(message('MATLAB:bicgstabl:tooSmallTolerance'));
                    end
                    flag = 3;
                    iter = ((kk-1)*ell*2+ell+jj)/(ell*2);
                    resvec = resvec(1:(kk-1)*ell*2+ell+jj+1);
                    break;
                end
            end
        end
        
        if normr_act < normrmin    % update minimal norm quantities
            normrmin = normr_act;
            xmin = xt;
            imin = ((kk-1)*ell*2+ell+jj)/(ell*2);
        end
        if stag >= maxstagsteps    % 3 iterates are the same
            flag = 3;
            break
        end
    end
    if flag == 0 || flag == 2 || flag == 3
        break;
    end
    ukm1 = ut(:,1);   rk = rt(:,1);   xk = xt;
end

if flag == 0
    x = x0 + pxt;
    relres = normr_act/n2b;
else
    if existM1
        pxt = iterapp('mldivide',m1fun,m1type,m1fcnstr,xmin,varargin{:});
        pxt2 = iterapp('mldivide',m1fun,m1type,m1fcnstr,xt,varargin{:});
        if ~all(isfinite(pxt)) || ~all(isfinite(pxt2))
            flag = 2;
            x = xmin;
            iter = imin;
            relres = normr_act/n2b;
            return
        end
    else
        pxt = xmin;
        pxt2 = xt;
    end
    if existM2
        pxt = iterapp('mldivide',m2fun,m2type,m2fcnstr,pxt,varargin{:});
        pxt2 = iterapp('mldivide',m2fun,m2type,m2fcnstr,pxt2,varargin{:});
        if ~all(isfinite(pxt)) || ~all(isfinite(pxt2))
            flag = 2;
            x = xmin;
            iter = imin;
            relres = normr_act/n2b;
            return
        end
    end
    r_comp = b - iterapp('mtimes',afun,atype,afcnstr,x0+pxt,varargin{:});
    r_comp2 = b - iterapp('mtimes',afun,atype,afcnstr,x0+pxt2,varargin{:});
    if norm(r_comp) <= norm(r_comp2)
        x = x0+pxt;
        iter = imin;
        relres = norm(r_comp) / n2b;
    else
        x = x0+pxt2;
        iter = kk;
        relres = norm(r_comp2) / n2b;
    end
end

if nargout < 2
    itermsg('bicgstabl',tol,maxit,kk,flag,iter,relres);
end

