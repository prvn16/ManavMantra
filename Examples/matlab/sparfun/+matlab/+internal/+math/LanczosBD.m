function [U,S,V,isNotConverged] = LanczosBD(Afun,m,n,f1,f2,k,v,InnerOpts,randStr)
% Computes the Lanczos Bidiagonalization using Afun

%%% Initialize Lanczos Process %%%
if InnerOpts.disp
    fprintf('\n');
    disp(['--- ' getString(message('MATLAB:svds:StartLanczosBD')) ' ---']);
end

v = full(v);

% Initial step to build u, the current left vector
u = full(Afun(v,f1));

% Error if user-provided function handle does not return an m-by-1 column vector
if ~iscolumn(u) || ~isFloatDouble(u) || length(u) ~= m 
    error(message('MATLAB:svds:InvalidFhandleOutput', f1, m));
end

% After the first application of Afun, turn off possible additional 
% warnings for near singularity
W = warning;
cleanup2 = onCleanup(@()warning(W));
warning('off', 'MATLAB:nearlySingularMatrix');
warning('off', 'MATLAB:illConditionedMatrix');
warning('off', 'MATLAB:singularMatrix');

% Normalize and store u
normu = norm(u);
if normu == 0
    % This only happens if v is in the nullspace of A, in which case we
    % randomly restart the algorithm.
    u = cast(randn(randStr,m,1),'like',u);
    u = u/norm(u);
else
    u = u/normu;
end

% Count how many iterations we have done (that is, how many times we have
% built U and V up to k columns). nrIter is increased on every call to
% LanczosBDInner.
nrIter = 0;

% Keep track of singular values computed in the last run.
svOld = zeros(0,0,'like',u);

% Build initial matrices U, V and B
U = zeros(m, InnerOpts.p,'like',u);
U(:,1) = u;
V = zeros(n, InnerOpts.p,'like',u);
V(:,1) = v;
B = normu;

% Call the bidiagonal Lanczos with these starting values
[U,S,V,nconv,nrIter,isNotConverged] = LanczosBDInner(Afun, U, B, V, k, ...
    m, n, f1, f2, InnerOpts, nrIter, randStr);

% Check if all k residuals have converged
if nconv < k
    U = U(:,1:k);
    S = S(1:k,1:k);
    V = V(:,1:k);
    isNotConverged = isNotConverged(1:k);
    return;
end

if InnerOpts.disp
    fprintf(['---\n' getString(message('MATLAB:svds:CheckMult')) '\n---\n']);
end

% Restart the bidiagonal Lanczos method for k+1 singular values, until the
% first k singular values have also converged. This is particularly useful
% for cases of multiple singular values, where LanczosBDInner may skip a
% multiple of a larger singular value in favor of a smaller singular value.
for nrRestartAfterConverge=1:InnerOpts.maxit
    % Note on stopping condition: have not observed needing more than
    % k+1, set to k+2 for safety.
    
    svNew = diag(S);
    
    % Approximation of the  2-norm of A
    Anorm = svNew(1);
    
    % Break loop if singular values have converged
    if ~isempty(svOld)
        % Vector of difference between iterations in each singular value
        changeSV = max(abs(svOld(1:k) - svNew(1:k)));

        if changeSV <= InnerOpts.tol*Anorm
            % We are satisfied and break the loop
            if InnerOpts.disp
                fprintf(['---\n' getString(message('MATLAB:svds:MultCheckSuccess')) '\n---\n']);
            end
            U = U(:,1:k);
            S = S(1:k,1:k);
            V = V(:,1:k);
            isNotConverged = isNotConverged(1:k);
            return;
        else
            if InnerOpts.disp
                fprintf(['---\n' getString(message('MATLAB:svds:MultCheckRepeat')) '\n---\n']);
            end
        end
    end
    svOld = svNew;
    
    % Break loop if maximum number of iterations is reached
    if nrIter >= InnerOpts.maxit
        U = U(:,1:k);
        S = S(1:k,1:k);
        V = V(:,1:k);
        isNotConverged = isNotConverged(1:k);
        if nconv == k
            if strcmpi(InnerOpts.sigma,'largest')
                warning(message('MATLAB:svds:MultNotCorrectLargest'));
            else
                warning(message('MATLAB:svds:MultNotCorrectSmallest'));
            end
        end
        return;
    end
    
    %%% Initialize a random restart for next Lanczos iteration %%%
    
    % New vector v, orthogonal to converged singular vectors in V
    v = cast(randn(randStr, size(V, 1), 1), 'like', v);
    v = orthAgainstRobust(V, v, m, n, Anorm, randStr, k);
    
    % Find next u
    Av = full(Afun(v,f1));
    u = Av - matlab.internal.math.projectInto(U, Av, k);
    
    % Reorthogonalize (random restart may occur here if A has numeric rank k)
    [u,normu] = orthAgainstRobust(U, u, m, n, Anorm, randStr, k);
    
    % Initialize B,U, and V for Lanczos restart
    B = blkdiag(S, normu);
    U(:, k+1) = u;
    V(:, k+1) = v;

    % Start Lanczos process to find largest k+1 singular values, building
    % Krylov subspaces orthogonal to the columns of U, V respectively.
    [Unew,Snew,Vnew,nconv,nrIter,isNotConverged] = LanczosBDInner(Afun, U, B, V, k+1, ...
        m, n, f1, f2, InnerOpts, nrIter, randStr);

    % Check if all k+1 residuals have converged
    if nconv < k+1
        U = U(:, 1:k);
        S = S(1:k, 1:k);
        V = V(:, 1:k);
        isNotConverged = isNotConverged(1:k);
        if nconv == k
            if strcmpi(InnerOpts.sigma,'largest')
                warning(message('MATLAB:svds:MultNotCorrectLargest'));
            else
                warning(message('MATLAB:svds:MultNotCorrectSmallest'));
            end
        end
        return;
    else
        U = Unew;
        S = Snew(1:k, 1:k);
        V = Vnew;
        isNotConverged = isNotConverged(1:k);
    end
        
end

end

function [U,S,V,nconv,nrIter,isNotConverged] = LanczosBDInner(Afun, U, B, V, k, ...
                                    m, n, f1, f2, InnerOpts, nrIter, randStr)
% Computes the Lanczos Bidiagonalization with thick restart of the matrix
% represented by Afun

% If k is less than 5, retain kplus = 5 largest Ritz values and vectors on
% the thick restart, instead of just k.
kplus = min(max(k, 5), InnerOpts.p-1);

% If this is not the first call, retrieve largest singular value from
% previous run from B.
if ~isscalar(B)
   Bnorm = B(1, 1); 
end

% Initialize u, v and normu:
u = U(:, size(B, 1));
v = V(:, size(B, 1));
normu = B(end, end);

%%% Here we start the iterations %%%
% Note in initialization we have done the first half-step of the first
% iteration
while nrIter < InnerOpts.maxit
    
    % Increase counter for the next iteration
    nrIter = nrIter + 1;
    
    % Lanczos Steps 
    for j = size(B, 1):InnerOpts.p
        
        % We need an initial approximation of the norm of the matrix Afun
        % represents. This is approximated by the norm of B. We will
        % calculate norm(B) here only in the first iteration, and only in
        % the first few (6) Lanczos steps.
        if nrIter == 1 && j <= 6
            Bnorm = norm(B);
        end
        
        % Find next v
        if nrIter == 1 && j == 1
            % The first time we use Afun with f2, we want to check that the
            % output is the correct size.
            vtemp = Afun(u,f2);
            if ~iscolumn(vtemp) || ~isFloatDouble(vtemp) || length(vtemp) ~= n 
                error(message('MATLAB:svds:InvalidFhandleOutput', f2, n));
            end
            
            v = vtemp - v*normu;
        else
            % Every other time, we simply do this calculation from the
            % basic Lanczos bidiagonalization algorithm
            v = Afun(u,f2) - v*normu;
        end
        
        % Reorthogonalize (Note there may be a random restart here)
        [v,normv] = orthAgainstRobust(V, v, m, n, Bnorm, randStr, j);
        
        if j < InnerOpts.p
            % Stop half-way through the last Lanczos step since we did the 
            % first half step of the iteration before this for-loop
            
            % Store v in V
            V(:,j + 1) = v;
            
            % Find next u 
            u = Afun(v,f1) - u*normv;
            
            % Reorthogonalize (Note there may be a random restart here)
            [u,normu] = orthAgainstRobust(U, u, m, n, Bnorm,randStr,j);
            
            % Store u
            U(:, j + 1) = u;
            
            % Store the norms in B
            B(end,end + 1) = normv; %#ok<AGROW>
            B(end + 1, end) = normu; %#ok<AGROW>
            
        end
    end
    
    % Check B, U, and V for NaNs and Infs. Note this rarely occurs because
    % of the random restarts
    if ~all(isfinite(B(:))) || ~all(isfinite(U(:))) || ~all(isfinite(V(:)))
        error(message('MATLAB:svds:BadCondition'))
    end
    
    % Find svd of B 
    [Uin,Sin,Vin] = svd(B);
    
    % Calculate k Ritz values/vectors
    U(:, 1:kplus) = U*Uin(:,1:kplus);
    V(:, 1:kplus) = V*Vin(:,1:kplus);
    S = Sin(1:kplus,1:kplus);
    
    % Save approximate 2-norm of A
    Bnorm = S(1,1);
    
    % Find convergence bounds (and augmentation for restart)
    % Note that 'bounds' approximates U'*A - S*V'
    % For an explanation, see the Baglama paper from the References section
    bounds = (normv*Uin(end,1:kplus))';
    
    % Find the number of converged singular values   
    isNotConverged = ~(abs(bounds(1:k)) <= InnerOpts.tol*diag(S(1:k, 1:k)));
    firstNonConv = find(isNotConverged, 1, 'first');
    if isempty(firstNonConv)
        nconv = k;
    else
        nconv = firstNonConv - 1;
    end
    
    if InnerOpts.disp
        disp_s = diag(S);
        minrelres = min(abs(bounds(isNotConverged)) ./ abs(disp_s(isNotConverged)));

        nrIterstr = sprintf('%*d', ceil(log10(InnerOpts.maxit+1)), nrIter);
        nconvstr = sprintf('%*d', ceil(log10(k+2)), nconv);
        k0str = sprintf('%*d', ceil(log10(k+2)), k);
        
        if ~isempty(minrelres)
            disp(getString(message('MATLAB:svds:LanczosBDIter', nrIterstr, nconvstr, k0str, sprintf('%.1e', minrelres), sprintf('%.1e', InnerOpts.tol))));
        else
            disp(getString(message('MATLAB:svds:LanczosBDLastIter', nrIterstr, nconvstr, k0str)));
        end
    end
    
    if nconv >= k
        % Break loop if singular values have converged
        break;
    elseif nrIter == InnerOpts.maxit
        % Break loop if maximum number of iterations is reached
        break
    end
    
    %%% Initialize Lanczos for restart %%%
    % This is the first half-step for the next iteration
    
    % Find next u
    Av = Afun(v,f1);
    u = Av - matlab.internal.math.projectInto(U, Av, kplus);
    
    % Reorthogonalize (random restart may occur here)
    [u,normu] = orthAgainstRobust(U,u,m,n,Bnorm,randStr, kplus);
    
    % Initialize B,U, and V for Lanczos restart
    B = [S, bounds; zeros(1,kplus), normu];
    U(:, kplus + 1) = u;
    V(:, kplus + 1) = v;
    
end

% Restrict U, V and S to largest k Ritz values
if kplus > k
    S = S(1:k,1:k);
end

end


function [y,normy] = orthAgainstRobust(X,y,m,n,Bnorm,randStr, i)
% Orthogonalize y against first i columns of X and do a random restart if 
% new y is small (invariant subspace found)

% Reorthogonalize
y = y - matlab.internal.math.projectInto(X, y, i);

% Find norm(y)
normy = norm(y);

if normy <= max(m,n)*Bnorm*eps
    % Attempt to find another Krylov subspace
    normy = zeros(1,'like',normy);
    y = cast(randn(randStr,size(y,1),1),'like',y);
    % The following line is identical to 
    % y = y - X(:, 1:i) * X(:, 1:i)' * y,
    % but is much faster because it doesn't require copies of X to be made.
    y = y - matlab.internal.math.projectInto(X, y, i);
    y = y/norm(y);
else
    y = y/normy;
end
end


function flag = isFloatDouble(A)
% Checks if input is double if hidden inside a distributed/gpuArray
flag = false;
if isfloat(A)
    if strcmp(superiorfloat(A), 'double')
        flag = true;
    end
end
end

