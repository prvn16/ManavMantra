function [U, S, V, flag] = svds(A,varargin)
% SVDS   Find a few singular values and vectors.
%
%  S = SVDS(A) returns the 6 largest singular values of A.
%
%  S = SVDS(A,K) computes the K largest singular values of A.
%
%  S = SVDS(A,K,SIGMA) computes K singular values based on SIGMA:
%
%        'largest' - compute K largest singular values. This is the default.
%       'smallest' - compute K smallest singular values.
%     'smallestnz' - compute K smallest non-zero singular values.
%         numeric  - compute K singular values nearest to SIGMA.
%
%  Note: if more singular values are requested than are available, K is set
%  to the maximum possible number.
%
%  S = SVDS(A,K,SIGMA,NAME,VALUE) configures additional options specified
%  by one or more name-value pair arguments:
%
%               'Tolerance' - Convergence tolerance
%           'MaxIterations' - Maximum number of iterations
%       'SubspaceDimension' - Size of subspace
%         'LeftStartVector' - Left starting vector
%        'RightStartVector' - Right starting vector
%        'FailureTreatment' - Treatment of non-converged eigenvalues
%                 'Display' - Display diagnostic messages
%
%  S = SVDS(A,K,SIGMA,OPTIONS) alternatively configures the additional
%  options using a structure. See the documentation for more information.
%
%  [U,S,V] = SVDS(A,...) computes the singular vectors as well.
%  If A is M-by-N and K singular values are computed, then U is M-by-K
%  with orthonormal columns, S is K-by-K diagonal, and V is N-by-K with
%  orthonormal columns.
%
%  [U,S,V,FLAG] = SVDS(A,...) also returns a convergence flag.
%  If the method has converged, then FLAG is 0. If it did not converge,
%  then FLAG is 1.
%
% [...] = SVDS(AFUN, MN, ...) accepts a function handle AFUN instead of
%  the matrix A. AFUN(X,'notransp') must accept a vector input X and return
%  the matrix-vector product A*X, while AFUN(X,'transp') must return A'*X.
%  MN is a 1-by-2 vector [m n] where m is the number of rows of A and
%  n is the number of columns of A. Function handles can only be used
%  in the case where SIGMA = 'largest'.
%
%  Note: SVDS is best suited for finding a few singular values of a large,
%  sparse matrix. To find all the singular values of such a matrix,
%  SVD(FULL(A), 'econ') usually performs better than SVDS(A,MIN(SIZE(A))).
%
%  Example:
%    C = gallery('neumann',100);
%    sf = svd(full(C))
%    sl = svds(C,10)
%    ss = svds(C,10,'smallest')
%    snz = svds(C,10,'smallestnz')
%    s2 = svds(C,10,2)
%
%    sl will be a vector of the 10 largest singular values, ss will be a
%    vector of the 10 smallest singular values, snz will be a vector of the
%    10 smallest singular values which are nonzero and s2 will be a
%    vector of the 10 singular values of C which are closest to 2.
%
%  See also SVD, EIGS.

%   Copyright 1984-2017 The MathWorks, Inc.

% This code uses thickly restarted Lanczos bidiagonalization for
%   sigma = 'largest', 'smallest', or 'smallestnz' and uses EIGS(B,...),
%   where B = [SPARSE(M,M) A; A' SPARSE(N,N)], when sigma is numeric.
%
% REFERENCES:
% James Baglama and L. Reichel, Augmented Implicitly Restarted Lanczos
%    Bidiagonalization Methods, SIAM J. Sci. Comput., 27 (2005), pp. 19-42.
% R. M. Larsen, Lanczos bidiagonalization with partial reorthogonalization,
%    Department of Computer Science, Aarhus University, Technical report,
%    DAIMI PB-357, September 1998.

% Initialize a dedicated randstream, to make output reproducible.
randStr = RandStream('dsfmt19937','Seed',0);

VarIn = varargin;
%%% Get Inputs and do Error Checking %%%
[A,m,n,k,sigma,u0,v0,InnerOpts,Options] = checkInputs(A,VarIn,randStr);

if InnerOpts.disp
    displayInitialInformation(InnerOpts, m, n, k, sigma);
end

% Reset the stream
reset(randStr, 1);

%%% Quick return for empty matrix or k = 0 %%%
if k == 0
    if nargout <= 1
        U = zeros(0,1);
    else
        U = eye(m,0);
        S = zeros(0,0);
        V = eye(n,0);
        if strcmp(InnerOpts.fail,'keep')
            flag = false(k,1);
        else
            flag = 0;
        end
    end
    return
    
    %%% Case Sigma is numeric --- Call old algorithm %%%
    
elseif isnumeric(sigma)
    
    oldRandStr = RandStream.setGlobalStream(randStr);
    
    cleanupObj = onCleanup(@() RandStream.setGlobalStream(oldRandStr));
    
    Options.warn = (nargout < 4);
    Options.disp = InnerOpts.disp;
    
    % Note that we pass in 'Options' exactly as given, or as an empty struct
    [U,S,V] = matlab.internal.math.svdsUsingEigs(A,k,sigma,Options);
    
    isNotConverged = false(size(S, 1), 1);
    
    if nargout <= 1
        U = diag(S);
    end
    
    %%% Case Sigma is 'largest' %%%
elseif isequal(sigma,'largest')
    
    if InnerOpts.p >= min(m, n)
        % Since we are going to build the whole subspace anyway, just do a
        % full SVD now. Ignore starting vector and InnerOpts.
        if InnerOpts.disp
            disp(getString(message('MATLAB:svds:SVDFallbackLargest')));
        end
        
        if isa(A, 'function_handle')
            Amat = getMatrix(A, m, n);
        else
            Amat = A;
        end
        [U, S, V] = fullSVD(Amat, k, m, n, sigma);
        
        if nargout <= 1
            U = diag(S);
        end
        if nargout == 4
            if strcmp(InnerOpts.fail,'keep')
                flag = false(size(S,1),1);
            else
                flag = 0;
            end
        end
        return;
    end
    
    if InnerOpts.disp
        disp(getString(message('MATLAB:svds:EquationLargest')));
    end
    
    % Use the function handle if given, otherwise build it
    if isa(A, 'function_handle')
        Afun = A;
    else
        Afun = @(x,transflag)AfunL(A,x,transflag);
    end
    
    % Exactly one of u0 and v0 is empty, determine which it is
    if ~isempty(v0)
        v = v0;
        f1 = 'notransp';
        f2 = 'transp';
    else
        v = u0;
        % If we start with u0, we essentially pass A' into Lanczos
        f1 = 'transp';
        f2 = 'notransp';
        mtemp = m;
        m = n;
        n = mtemp;
    end
    
    % Normalize starting vector
    v = v/norm(v);
    
    % Check that normalized vector has norm 1
    if ~(abs(norm(v) - 1) < 1e-14)
        error(message('MATLAB:svds:InvalidStartingVector'))
    end
    
    % Call Lanczos bidiagonalization
    [U,S,V,isNotConverged] = matlab.internal.math.LanczosBD(Afun,m,n,f1,f2,k,v,InnerOpts,randStr);
    
    if nargout < 2
        % Just return a vector of singular values
        U = diag(S);
    elseif ~isempty(u0)
        % If we used u0, U and V are sing. vectors of A', so we swap them
        Utemp = U;
        U = V;
        V = Utemp;
    end
    
    %%% Case Sigma is 'smallest' or 'smallestnz' %%%
elseif isequal(sigma, 'smallest') || isequal(sigma, 'smallestnz')
    %%% First do a QR factorization of A, and apply solver to inverse of R %%%
    
    % Need to compute non-zero singular values and vectors
    ComputeNonZeroSV = true;
    % Work on the transposed the problem
    transp = n > m;
    % Keep original size of A, use these variables internally
    mIn = m;
    nIn = n;
    
    if InnerOpts.disp
        if transp
            disp(getString(message('MATLAB:svds:EquationSmallestTransp')));
        else
            disp(getString(message('MATLAB:svds:EquationSmallest')));
        end
    end
    
    if transp        
        % Transpose before QR so R is square
        A = A';
        % Switch starting vectors u0 and v0
        tmp = u0;
        u0 = v0;
        v0 = tmp;
        % Save new size of A in the internal m and n
        nIn = m;
        mIn = n;
    end
    
    % Do the QR factorization.
    % Q1func: function handle that applies Q1*x or Q1'*x
    % sizeR: number of columns of R that contain nonzeros
    % Q1end: columns of Q1 lying in the null-space of A (only for dense A)
    [Q1func, R1, perm1, sizeR, Q1end] = implicitQR(A);
    
    % Number of Singular values that are exactly zero
    zeroSing = nIn - sizeR;
    
    % Do we need to do a second QR factorization
    DoaSecondQR = zeroSing ~= 0;
    
    % Remove all zero rows (also ensures R1 is 'economy' sized when sparse)
    R1 = R1(1:sizeR,:);
    
    if DoaSecondQR
        % R1 is now broad instead of square, so we do a second QR
        % decomposition to make sure that we have a square, nonsingular
        % matrix to pass into the Lanczos process
        
        % Do the second qr
        [Q2func, R2, perm2, ~, Q2end] = implicitQR(R1', sizeR);
        
        if isequal(sigma, 'smallest')
            
            if zeroSing >= k
                % If all the requested singular values are zero, we skip
                % the Lanczos process
                if InnerOpts.disp
                    disp(getString(message('MATLAB:svds:RankSmallestAllZero', sizeR, k)));
                end
                
                ComputeNonZeroSV = false;
                zeroSing = k;
            else
                % Reduce k since we do not need to find all the singular
                % values with the Lanczos process, just the nonzeros
                if InnerOpts.disp
                    disp(getString(message('MATLAB:svds:RankSmallestSomeZero', sizeR, zeroSing, k)));
                end                
                
                k = k - zeroSing;
            end
            
        else % Case smallestnz
            if k > sizeR
                % We can only find at most sizeR singular values through
                % the Lanczos process, so we must cap k there
                if InnerOpts.disp
                    disp(getString(message('MATLAB:svds:RankSmallestNzTooFew', sizeR, sizeR, k)));
                 end   
                
                k = sizeR;
                if k == 0
                    % Occurs only when sizeR is zero
                    ComputeNonZeroSV = false;
                end
            end
            % No singular vectors for singular value 0 need to be computed
            zeroSing = 0;
        end
    end
    
    % Compute non-zero singular values and vectors
    if ComputeNonZeroSV
        
        if InnerOpts.p < sizeR
            % Use the Lanczos process
            
            % Create variable v for starting vector
            if ~isempty(u0)
                v = u0;
            else
                v = v0;
            end
            
            % Normalize starting vector.
            v = v/norm(v);
            
            % Check that the normalized vector indeed has norm 1
            if ~(abs(norm(v) - 1) < 1e-14)
                error(message('MATLAB:svds:InvalidStartingVector'))
            end
            
            % Preprocess the vector v to get it into the correct space
            % (e.g. span of R2 instead of span of A)
            if ~isempty(v0)
                v = v(perm1,:);
                if DoaSecondQR
                    v = Q2func(v, 'transp');
                end
            else
                v = Q1func(v, 'transp');
                if DoaSecondQR
                    v = v(perm2,:);
                end
            end
            
            % Renormalize (in case of numerical error in Q1func and Q2func)
            v = v / norm(v);
            
            % Build Function Handle to pass into Lanczos.
            % Problem flips if we do a second QR (since R1' = Q2*R2 )
            if DoaSecondQR
                Afun = @(X,transflag)AfunS(R2,X,transflag);
                f1 = 'notransp';
                f2 = 'transp';
            else
                Afun = @(X,transflag)AfunS(R1,X,transflag);
                f1 = 'transp';
                f2 = 'notransp';
            end
            
            % Do Lanczos Bidiagonalization Process
            [U,S,V,isNotConverged] = matlab.internal.math.LanczosBD(Afun,sizeR,sizeR,f1,f2,k,v,InnerOpts,randStr);
            
            % Invert and flip Ritz values
            S = diag(flip(1./diag(S)));
            U = flip(U,2);
            V = flip(V,2);
            
            % If ratio between largest and smallest singular value is
            % large, check that the residuals are acceptable
            checkResiduals = S(1, 1) / S(end, end) > 1e8;
            
        else % InnerOpts.p >= sizeR
            
            if InnerOpts.disp
                disp(getString(message('MATLAB:svds:SVDFallbackSmallest')));
            end
            
            % Compute a full SVD, since we are going to build the whole
            % subspace anyway. Ignore starting vector v in this case.
            if DoaSecondQR
                [V, S, U] = fullSVD(R2, k, sizeR, sizeR, 'smallest');
            else
                [U, S, V] = fullSVD(R1, k, sizeR, sizeR, 'smallest');
            end
            checkResiduals = false;
            isNotConverged = false(size(S,1),1);
        end
        
        % Build Ritz vectors for A from the Ritz vectors for R
        if nargout > 1 || checkResiduals
            if DoaSecondQR
                U(perm2,:) = U;
                V = Q2func(V, 'notransp');
            end
            U = full(Q1func(U, 'notransp'));
            V(perm1,:) = V;
        end
        
        if checkResiduals
            % If matrix is badly conditioned, the numerical error in the
            % QR decomposition and inversion may mean that the residuals
            % with A are much larger than the residuals with R^(-1)
            res1 = A*V - U*S;
            res2 = A'*U - V*S;
            maxres = max(sum(conj(res1).*res1, 1), sum(conj(res2).*res2, 1))';
            
            if InnerOpts.disp
               disp(getString(message('MATLAB:svds:ResidualCheck', ...
                                      sprintf('%.1e', max(maxres ./ diag(S))))));
            end
            
            % Only warn in cases where the residual is much worse than tol
            if ~all(maxres < 1e3*InnerOpts.tol*diag(S))
                estCondition = S(1, 1) / S(end, end);
                warning(message('MATLAB:svds:BadResidual', num2str(estCondition, '%g')));
            end
        end
        
    else % No non-zero singular values to be computed
        % Make correctly sized empty U,S,V
        U = zeros(mIn,0);
        V = zeros(nIn,0);
        S = [];
        isNotConverged = false(0,1);
    end
    
    if nargout <= 1
        % Just return a vector of singular values; append zeros to account
        % for exactly zero singular values
        U = [diag(S); zeros(zeroSing,1)];
        
    else  % Finish preparing vectors
        
        if zeroSing > 0
            % Append zero singular values to S (which may be empty)
            S = diag([diag(S); zeros(zeroSing,1)]);
            isNotConverged = false(length(diag(S)),1);
            
            if issparse(A)
                % Find vectors in the nullspace of A. These are left singular
                % vectors corresponding to the zero singular values
                Uzero = full(spdiags(ones(zeroSing, 1), -sizeR, mIn, zeroSing));
                Uzero = Q1func(Uzero, 'notransp');
                
                % Find vectors in the nullspace of A'. These are right singular
                % vectors corresponding to the zero singular values
                Vzero = full(spdiags(ones(zeroSing, 1), -sizeR, nIn, zeroSing));
                Vzero = Q2func(Vzero, 'notransp');
                Vzero(perm1, :) = Vzero;
                
            else
                Uzero = Q1end(:,end-zeroSing+1:end);
                Vzero = Q2end(:,end-zeroSing+1:end);
                Vzero(perm1, :) = Vzero;
            end
            
            % Append these to known left singular vectors
            U = [U, Uzero];
            
            % Append these to known right singular values
            V = [V, Vzero];
        end
        
        % If we did the problem on A', switch U and V back
        if transp
            Utemp = U;
            U = V;
            V = Utemp;
        end
        
    end
end

% Give correct output based on Failure Treatment option (replacenan is default)
if strcmpi(InnerOpts.fail,'keep')
    flag = isNotConverged;
elseif strcmpi(InnerOpts.fail,'drop')
    if nargout <= 1
        U(isNotConverged) = [];
    else
        U = U(:,~isNotConverged);
        V = V(:,~isNotConverged);
        S = S(~isNotConverged,~isNotConverged);
    end
    flag = double(any(isNotConverged) || length(isNotConverged) < k);
else
    if nargout <= 1
        U(isNotConverged) = NaN;
    else
        s = diag(S);
        s(isNotConverged) = NaN;
        S = diag(s);
    end
    flag = double(any(isNotConverged));
end

% If flag is not returned, give a warning about convergence failure
if nargout < 4 && any(isNotConverged)
    if strcmpi(InnerOpts.fail,'keep')
        warning(message('MATLAB:svds:PartialConvKeep',sum(~isNotConverged),k));
    elseif strcmpi(InnerOpts.fail,'drop')
        warning(message('MATLAB:svds:PartialConvDrop',sum(~isNotConverged),k));
    else
        warning(message('MATLAB:svds:PartialConvergence',sum(~isNotConverged),k));
    end
end

end

function [A,m,n,k,sigma,u0,v0,InnerOpts,Options] = checkInputs(A,VarIn,randStr)
% Get and error check inputs

% Get A and MN
[m,n,VarIn] = getSizeA(A,VarIn);

% Get k
if length(VarIn) < 1
    k = 6;
else
    k = VarIn{1};
    if ~isPosInt(k) || ~isscalar(k)
        error(message('MATLAB:svds:InvalidK'))
    end
    k = double(full(k));
end

% Duplicating old behavior, allow k larger than size of matrix
k = min([m,n,k]);

% Get sigma
sigma = getSigma(A,VarIn);

% Set defaults for options or get options
[InnerOpts,Options,u0,v0] = getOptions(VarIn,m,n,k,sigma);

if isnumeric(sigma) && sigma == 0
    warning(message('MATLAB:svds:SigmaZero'))
end

% If the user does not provide a starting vector, we start with a random
% starting vector on the smaller side.
if isempty(u0) && isempty(v0)
    if n > m
        u0 = randn(randStr,m,1);
    else
        v0 = randn(randStr,n,1);
    end
end

end

function [m,n,VarIn] = getSizeA(A,VarIn)
% Error check and get the size of A in checkInputs

if isa(A, 'function_handle')
    
    if numel(VarIn) < 1
        error(message('MATLAB:svds:InvalidMN'))
    end
    % Variable MN is equal to size(A)
    MN = VarIn{1};
    
    % Error Check m and n
    if ~isPosInt(MN) || ~isrow(MN) || length(MN) ~= 2 || ~all(isfinite(MN))
        error(message('MATLAB:svds:InvalidMN'));
    else
        m = double(full(MN(1)));
        n = double(full(MN(2)));
    end
    
    % Remove MN from VarIn. The remaining entries are k, sigma, and Options
    % which matches VarIn when A is not given as a function handle
    VarIn(1) = [];
    
elseif ismatrix(A) && isFloatDouble(A)
    
    % Save size of A in m and n
    [m, n] = size(A);
    
else
    error(message('MATLAB:svds:InvalidA'))
end

end

function sigma = getSigma(A,VarIn)
% Error check and get sigma in checkInputs

if length(VarIn) < 2
    sigma = 'largest';
else
    sigma = VarIn{2};
    
    % Error Check sigma
    
    if (ischar(sigma) && isrow(sigma)) || (isstring(sigma) && isscalar(sigma))
        ValidSigmas = {'largest','smallest','smallestnz'};
        match = startsWith(ValidSigmas, sigma, 'IgnoreCase', true);
        j = find(match,1);
        if isempty(j) || (strlength(sigma) == 0)
            error(message('MATLAB:svds:InvalidSigma'))
        else
            % Reset sigma to the correct valid sigma for cheaper checking
            sigma = ValidSigmas{j};
        end
    elseif isFloatDouble(sigma)
        % We pass numeric sigma into old code
        if ~isreal(sigma) || ~isscalar(sigma) || ~isfinite(sigma)
            error(message('MATLAB:svds:InvalidSigma'))
        end
    else
        error(message('MATLAB:svds:InvalidSigma'))
    end
    
    % Function handle is not implemented when sigma is  'smallest',
    % 'smallestnz', or numeric
    if isa(A, 'function_handle') && ~isequal(sigma,'largest')
        error(message('MATLAB:svds:FhandleNoLargest'))
    end
    
end

end

function [InnerOpts,Options,u0,v0] = getOptions(VarIn,m,n,k,sigma)
% Get options and set defaults if options are not provided

% Defaults for options

InnerOpts = struct;
% Tolerance is used as stopping criteria in Lanczos Process
InnerOpts.tol = 1e-10;
% Maxit is used as stopping criteria in Lanczos Process
InnerOpts.maxit = 100;
% p is the size of the Krylov Subspace
InnerOpts.p = max(3*k,15);
% disp: 0 means no display, 1 displays contextual messages
InnerOpts.disp = 0;

% Left and right starting vector, algorithm can use at most one
u0 = [];
v0 = [];

% fail determines the treatment of non-converged singular values
if isnumeric(sigma)
    InnerOpts.fail = 'drop';
else
    InnerOpts.fail = 'replacenan';
end

% Define sigma in InnerOpts to be used in a warning in LanczosBD
InnerOpts.sigma = sigma;

% Initialize Options as empty struct
Options = struct;

% Get Options, if provided
nVarIn = length(VarIn);
NameValueFlag = false;
if nVarIn >= 3
    if isstruct(VarIn{3})
        Options = VarIn{3};
        % VarIn should be {k, sigma, Options}
        if nVarIn > 3
            error(message('MATLAB:maxrhs'));
        end
    else
        % Convert the Name-Value pairs to a struct for ease of error
        % checking and to create the options struct to pass to svdsUsingEigs
        NameValueFlag = true;
        for j = 3:2:nVarIn
            name = VarIn{j};
            if (~(ischar(name) && isrow(name)) && ~(isstring(name) && isscalar(name))) ...
                    || (isstring(name) && strlength(name) == 0)
                error(message('MATLAB:svds:ParseFlags'));
            end
            nvNames = ["Tolerance", "MaxIterations", "SubspaceDimension", ...
                "LeftStartVector", "RightStartVector", "FailureTreatment", "Display"];
            ind = startsWith(nvNames, name, 'IgnoreCase', true);
            if nnz(ind) ~= 1
                error(message('MATLAB:svds:ParseFlags'))
            end
            if j+1 > nVarIn
                error(message('MATLAB:svds:KeyWithoutValue'));
            end
            
            structNames = {'tol','maxit','p','u0','v0','fail','disp'};
            Options.(structNames{ind}) = VarIn{j+1};
        end
    end
    if isfield(Options,'tol')
        InnerOpts.tol = Options.tol;
        if ~isnumeric(InnerOpts.tol) || ~isscalar(InnerOpts.tol) ...
                || ~isreal(InnerOpts.tol) || ~(InnerOpts.tol >= 0)
            if NameValueFlag
                error(message('MATLAB:svds:InvalidTolNameValue'))
            else
                error(message('MATLAB:svds:InvalidTol'))
            end
        end
    end
    if isfield(Options,'maxit')
        InnerOpts.maxit = Options.maxit;
        if ~isPosInt(InnerOpts.maxit) || ~isscalar(InnerOpts.maxit)...
                || InnerOpts.maxit == 0
            if NameValueFlag
                error(message('MATLAB:svds:InvalidMaxitNameValue'))
            else
                error(message('MATLAB:svds:InvalidMaxit'))
            end
        end
    end
    if isfield(Options, 'p')
        InnerOpts.p = Options.p;
        if ~isPosInt(InnerOpts.p) || ~isscalar(InnerOpts.p)
            if NameValueFlag
                error(message('MATLAB:svds:InvalidPNameValue'))
            else
                error(message('MATLAB:svds:InvalidP'))
            end
        end
        if InnerOpts.p < k+2
            if NameValueFlag
                error(message('MATLAB:svds:PlessKNameValue'))
            else
                error(message('MATLAB:svds:PlessK'))
            end
        end
    end
    if isfield(Options, 'v0')
        v0 = Options.v0;
        if ~iscolumn(v0) || length(v0) ~= n || ...
                ~isFloatDouble(v0)
            if NameValueFlag
                error(message('MATLAB:svds:InvalidV0NameValue'))
            else
                error(message('MATLAB:svds:InvalidV0'))
            end
        end
    end
    if isfield(Options, 'u0')
        u0 = Options.u0;
        if ~isempty(v0)
            if NameValueFlag
                error(message('MATLAB:svds:BothU0andV0NameValue'))
            else
                error(message('MATLAB:svds:BothU0andV0'))
            end
        elseif ~iscolumn(u0) || length(u0) ~= m || ...
                ~isFloatDouble(u0)
            if NameValueFlag
                error(message('MATLAB:svds:InvalidU0NameValue'))
            else
                error(message('MATLAB:svds:InvalidU0'))
            end
        end
    end
    if isfield(Options, 'fail')
        InnerOpts.fail = Options.fail;
        if (ischar(InnerOpts.fail) && isrow(InnerOpts.fail)) || (isstring(InnerOpts.fail) && isscalar(InnerOpts.fail))
            ValidFails = {'replacenan','keep','drop'};
            match = startsWith(ValidFails, InnerOpts.fail, 'IgnoreCase', true);
            ii = find(match,1);
            if isempty(ii) || (strlength(InnerOpts.fail) == 0)
                if NameValueFlag
                    error(message('MATLAB:svds:InvalidFailureTreatmentNameValue'))
                else
                    error(message('MATLAB:svds:InvalidFailureTreatment'))
                end
            else
                InnerOpts.fail = ValidFails{ii};
                
                % Error if Failure Treatment is set to 'replacenan' or
                % 'keep' and sigma is numeric
                if isnumeric(sigma) && any(strcmpi(ValidFails{ii},{'replacenan','keep'}))
                    if NameValueFlag
                        error(message('MATLAB:svds:NoFailNumSigmaNameValue'))
                    else
                        error(message('MATLAB:svds:NoFailNumSigma'))
                    end
                end
            end
        else
            if NameValueFlag
                error(message('MATLAB:svds:InvalidFailureTreatmentNameValue'))
            else
                error(message('MATLAB:svds:InvalidFailureTreatment'))
            end
        end
    end
    if isfield(Options, 'disp')
        disp = Options.disp;
        if ~isscalar(disp) || (~isnumeric(disp) && ~islogical(disp)) || ~isfinite(disp)
            if NameValueFlag
                error(message('MATLAB:svds:InvalidDispNameValue'))
            else
                error(message('MATLAB:svds:InvalidDisp'))
            end
        end
        InnerOpts.disp = disp ~= 0;
    end
end

end

function  [tf] = isPosInt(X)
% Check if X is a non-negative integer

tf = isnumeric(X) && isreal(X) && all(X(:) >= 0) && all(fix(X(:)) == X(:));
end
%%% Functions for function handles %%%

function b = AfunL(A,X,transflag)
% Afun for mode 'largest'

if strcmpi(transflag,'notransp')
    b = A*X;
elseif strcmpi(transflag,'transp')
    b = A'*X;
end
b = full(b); % otherwise, if A is a sparse vector, b is also sparse
end

function b = AfunS(R,X,transflag)
% Afun for mode 'smallest' or 'smallestnz'

if strcmpi(transflag,'notransp')
    b = R\X;
elseif strcmpi(transflag,'transp')
    b = R'\X;
end
end


function displayInitialInformation(innerOpts, m, n, k, sigma)
fprintf('\n');
disp(['=== ' getString(message('MATLAB:svds:Title')) ' ===']);
fprintf('\n');
if strcmp(sigma, 'largest')
    disp(getString(message('MATLAB:svds:KandSigmaLargest', k, m, n)));
elseif strcmp(sigma, 'smallest')
    disp(getString(message('MATLAB:svds:KandSigmaSmallest', k, m, n)));
elseif strcmp(sigma, 'smallestnz')
    disp(getString(message('MATLAB:svds:KandSigmaSmallestNz', k, m, n)));
else
    disp(getString(message('MATLAB:svds:KandSigmaNum', k, m, n, num2str(sigma))));
end
fprintf('\n');
disp(getString(message('MATLAB:svds:ListParam', num2str(innerOpts.maxit), num2str(innerOpts.tol), innerOpts.p)));
fprintf('\n');
end

function [Qfunc, R, perm, sizeR, Qend] = implicitQR(A, sizeR)
% Compute the QR decomposition of A, and return a function handle that
% applies Q (which is much cheaper than explicitly storing Q for large and
% sparse A). Also computes sizeR, the number of non-zero columns in R.

if issparse(A)
    % Compute QR decomposition, and return Householder vectors and
    % coefficients to represent Q.
    
    if nargin == 1
        % Same behavior as MATLAB's qr, but store Q efficiently in H, tau and pinv
        [H, tau, pinv, R, perm] = matlab.internal.math.implicitSparseQR(A);
    else
        % If the rank sizeR is given explicitly, we set the internal tolerance
        % for sparse qr to 0. This way, the second call to QR never reduces the
        % rank further - matrix R always has full rank sizeR.
        tol = 0;
        useAMD = true; % columns are permuted (default)
        [H, tau, pinv, R, perm] = matlab.internal.math.implicitSparseQR(A, useAMD, tol);
    end
else
    if nargin == 1
        [Q,R,perm] = qr(A,0);
    else
        % If sizeR is already defined, cut R back to first sizeR columns
        [Q,R,perm] = qr(A, 'vector');
        R = R(1:sizeR, :);
    end
end

% If sizeR was not defined yet, detect it from R
if nargin == 1
    % Explicitly check for singularity by finding the last nonzero on
    % the diagonal of R
    sizeR = find(diag(R),1,'last');
    if isempty(sizeR)
        % Occurs only when R is all zeros
        sizeR = 0;
    end
end

% Initialize function handle applying Q and Q' as needed.
if issparse(A)
    Qfunc = @(x, transflag) sparseQHandle(sizeR, ...
        H, tau, pinv, x, isequal(transflag, 'transp'));
    Qend = []; % not used in sparse case
else
    Qend = Q(:,sizeR+1:end);
    Q = Q(:, 1:sizeR);
    Qfunc = @(x, transflag) AfunL(Q, x, transflag);
end

end

function y = sparseQHandle(sizeR, H, tau, pinv, x, transp)
% The built-in applies full mxm matrix Q. We need to pad with zeros or
% truncate to get the required dimensions.
% Applies Q(:, 1:sizeR)*x or Q(:, 1:sizeR)'*x, using Householder vectors
% representing Q

if ~transp
    x(end+1:size(H, 1), :) = 0;
end

if isreal(H) && isreal(tau) && ~isreal(x)
    % Real Q applied to complex x not supported in built-in
    y = matlab.internal.math.applyHouseholder(H, tau, pinv, real(x), transp) + ...
        1i*matlab.internal.math.applyHouseholder(H, tau, pinv, imag(x), transp);
else
    y = matlab.internal.math.applyHouseholder(H, tau, pinv, x, transp);
end

if transp
    y = y(1:sizeR, :);
end

end

function Amat = getMatrix(Afun, m, n)
% Extract the underlying matrix of the function handle, for cases where we
% call svd directly.

% Extract Atranspose if this needs fewer applications of Afun
if m >= n
    mIn = m;
    nIn = n;
    transflag = 'notransp';
else
    mIn = n;
    nIn = m;
    transflag = 'transp';
end

I = eye(nIn);

% Check dimensions for first column of Amat
vec = Afun(I(:, 1), transflag);
if ~iscolumn(vec) || ~isFloatDouble(vec) || length(vec) ~= mIn
    % Will only error if the user provides a function handle that does not
    % output a vector of the expected size
    error(message('MATLAB:svds:InvalidFhandleOutput', transflag, mIn));
end

% Initialize Amat in the correct class
Amat = zeros(mIn, nIn, 'like', vec);

% Fill in Amat with function handle output
Amat(:, 1) = vec;
for ii=2:nIn
    Amat(:, ii) = Afun(I(:, ii), transflag);
end

% Transpose Amat if necessary
if m < n
    Amat = Amat';
end

end

function [U, S, V] = fullSVD(Amat, k, m, n, sigma)
% Compute svds(Amat, ...) using svd(full(Amat))

% Check all values are finite
if ~all(isfinite(Amat(:)))
    error(message('MATLAB:svds:BadCondition'))
end

% Call QR, then svd for inner matrix R
if ~issparse(Amat) || m == n
    % Direct call to svd
    [U, S, V] = svd(full(Amat), 'econ');
else
    % Make Amat tall
    if m < n
        Amat = Amat';
    end
    
    % Apply SVD only to R matrix of the QR decomposition of A
    [H, tau, pinv, R, perm] = matlab.internal.math.implicitSparseQR(Amat);
    [U, S, V] = svd(full(R));
    U(end+1:size(Amat, 1), :) = 0;
    U = matlab.internal.math.applyHouseholder(H, tau, pinv, U, false);
    V(perm, :) = V;
    
    % Revert transposition if needed
    if m < n
        tmp = U;
        U = V;
        V = tmp;
    end
    
end

% Extract largest or smallest k singular values
nrSV = min(m, n);
if isequal(sigma, 'largest')
    ind = 1:k;
else % case sigma = 'smallest'
    ind = nrSV-k+1:nrSV;
end

V = V(:, ind);
U = U(:, ind);
S = S(ind, ind);
end

function flag = isFloatDouble(A)
% Checks if input is double if hidden inside a distributed/gpuArray

flag = isfloat(A) && strcmp(superiorfloat(A), 'double');
end
