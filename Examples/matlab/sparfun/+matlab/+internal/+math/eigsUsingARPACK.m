function [V, D, flag] = eigsUsingARPACK(varargin)
%EIGS  Find a few eigenvalues and eigenvectors of a matrix

%   THIS IS AN UNDOCUMENTED FUNCTION THAT PROVIDES THE FUNCTION EIGS USING
%   ARPACK, AS IT WAS SHIPPED FOR R2017a. For R2017b, EIGS HAS SWITCHED TO 
%   USING THE KRYLOV-SCHUR METHOD INSTEAD. THIS METHOD IS PROVIDED IN CASE OF
%   ANY COMPATIBILITY ISSUES. 

%   D = EIGS(A) returns a vector of A's 6 largest magnitude eigenvalues.
%   A must be square and should be large and sparse.
%
%   [V,D] = EIGS(A) returns a diagonal matrix D of A's 6 largest magnitude
%   eigenvalues and a matrix V whose columns are the corresponding
%   eigenvectors.
%
%   [V,D,FLAG] = EIGS(A) also returns a convergence flag. If FLAG is 0 then
%   all the eigenvalues converged; otherwise not all converged.
%
%   EIGS(A,B) solves the generalized eigenvalue problem A*V == B*V*D. B must be
%   the same size as A. EIGS(A,[],...) indicates the standard eigenvalue problem
%   A*V == V*D.
%
%   EIGS(A,K) and EIGS(A,B,K) return the K largest magnitude eigenvalues.
%
%   EIGS(A,K,SIGMA) and EIGS(A,B,K,SIGMA) return K eigenvalues. If SIGMA is:
%      'LM' or 'SM' - Largest or Smallest Magnitude
%   For real symmetric problems, SIGMA may also be:
%      'LA' or 'SA' - Largest or Smallest Algebraic
%      'BE' - Both Ends, one more from high end if K is odd
%   For nonsymmetric or complex problems, SIGMA may also be:
%      'LR' or 'SR' - Largest or Smallest Real part
%      'LI' or 'SI' - Largest or Smallest Imaginary part
%   If SIGMA is a real or complex scalar including 0, EIGS finds the
%   eigenvalues closest to SIGMA.
%
%   EIGS(A,K,SIGMA,OPTS) and EIGS(A,B,K,SIGMA,OPTS) specify options:
%   OPTS.issym: symmetry of A or A-SIGMA*B represented by AFUN [{false} |
%   true]
%   OPTS.isreal: complexity of A or A-SIGMA*B represented by AFUN [false | {true}]
%   OPTS.tol: convergence: Ritz estimate residual <= tol*NORM(A) [scalar | {eps}]
%   OPTS.maxit: maximum number of iterations [integer | {300}]
%   OPTS.p: number of Lanczos vectors: K+1<p<=N [integer | {2K}]
%   OPTS.v0: starting vector [N-by-1 vector | {randomly generated}]
%   OPTS.disp: diagnostic information display level [{0} | 1 | 2]
%   OPTS.cholB: B is actually its Cholesky factor CHOL(B) [{false} | true]
%   OPTS.permB: sparse B is actually CHOL(B(permB,permB)) [permB | {1:N}]
%   Use CHOL(B) instead of B when SIGMA is a string other than 'SM'.
%
%   EIGS(AFUN,N) and EIGS(AFUN,N,B) accept the function AFUN instead of the
%   matrix A. AFUN is a function handle and Y = AFUN(X) should return
%      A*X            if SIGMA is unspecified, or a string other than 'SM'
%      A\X            if SIGMA is 0 or 'SM'
%      (A-SIGMA*I)\X  if SIGMA is a nonzero scalar (standard problem)
%      (A-SIGMA*B)\X  if SIGMA is a nonzero scalar (generalized problem)
%   N is the size of A. The matrix A, A-SIGMA*I or A-SIGMA*B represented by
%   AFUN is assumed to be real and nonsymmetric unless specified otherwise
%   by OPTS.isreal and OPTS.issym.
%
%   EIGS(AFUN,N,...) is equivalent to EIGS(A,...) for all previous syntaxes.
%
%   Example:
%      A = delsq(numgrid('C',15));  d1 = eigs(A,5,'SM');
%
%   Equivalently, if dnRk is the following one-line function:
%      %----------------------------%
%      function y = dnRk(x,R,k)
%      y = (delsq(numgrid(R,k))) \ x;
%      %----------------------------%
%
%      n = size(A,1);  opts.issym = 1;
%      d2 = eigs(@(x)dnRk(x,'C',15),n,5,'SM',opts);
%
%   See also EIG, SVDS, FUNCTION_HANDLE.

%   Copyright 1984-2017 The MathWorks, Inc.

%   EIGS provides the reverse communication interface to ARPACK library
%   routines. EIGS attempts to provide an interface for as many different
%   algorithms as possible. The reverse communication interfaces are
%   documented in the ARPACK Users' Guide, ISBN 0-89871-407-9.

t0 = tic; % start timing pre-processing

% Error check inputs and derive some information from them
[A, n, B, k, Amatrix, eigsSigma, mode, cholB, permB, scaleB, innerOpts] ...
    = checkInputs(varargin{:});

% Get more information from B to finalize problem type
[R, permB, BisHpd] = CHOLfactorB(B, cholB, permB, mode);

% Finalize problem type and argument checking
[innerOpts, useEig] = extraChecks(innerOpts, B, n, k, BisHpd);

% We fall back on using the full EIG code if K is too large (or == 0).
if useEig
    if nargout <= 1
        V = fullEig(A, B, n, k, cholB, permB, R, scaleB, eigsSigma);
    else
        [V, D] = fullEig(A, B, n, k, cholB, permB, R, scaleB, eigsSigma);
        flag = 0;
    end
    return
end

% Define the operations needed for ARPACK
[applyOP, applyM] = getOps(A, B, n, BisHpd, mode, R, cholB, permB,...
    Amatrix, innerOpts);

if Amatrix    
    % Turn off excess warnings. We will create our own that only show once.
    W = warning;
    cleanup = onCleanup(@()warning(W));
    warning('off', 'MATLAB:nearlySingularMatrix');
    warning('off', 'MATLAB:illConditionedMatrix');
    warning('off', 'MATLAB:singularMatrix');
end

% Send variables to ARPACK and run algorithm
[V, d, flag, timings, t0] = CallARPACK(applyOP, applyM, n, k, ...
    innerOpts, mode, t0, nargout);

% Do some post-processing for Generalized problem
if ~isempty(B)
    d = d./scaleB;
    if BisHpd && nargout >= 2
        V = postProcessVectors(V, B, scaleB, mode, R, cholB, permB, k);
    end
end

% Assign outputs
if nargout <= 1
    V = d;
else
    D = diag(d);
end

timings(4) = toc(t0); % end timing post-processing

timings(5) = sum(timings(1:4)); % total time

if innerOpts.eigsDisplay == 2
    printTimings(timings, mode, Amatrix, B);
end
end

function [A, n, B, k, Amatrix, eigsSigma, mode, cholB, permB, scaleB, ...
    innerOpts]  = checkInputs(varargin)
% Process the inputs and get some information from them

isrealprob = true;
ishermA = false;

if isa(varargin{1},'double')
    A = varargin{1};
    Amatrix = true;
    isrealprob = isreal(A);
    ishermA = ishermitian(A);
    [m, n] = size(A);
    if m ~= n
        error(message('MATLAB:eigsUsingARPACK:NonSquareMatrixOrFunction'));
    end
else
    % By checking the function A with fcnchk, we can now use direct
    % function evaluation on the result, without resorting to feval
    [A, notFunc] = fcnchk(varargin{1});
    Amatrix = false;
    if ~isempty(notFunc)
        error(message('MATLAB:eigsUsingARPACK:NonDoubleOrFunction'));
    end
    n = varargin{2};
    if ~isscalar(n) || ~isreal(n) || n<0 || ~isfinite(n) || round(n) ~= n
        error(message('MATLAB:eigsUsingARPACK:NonPosIntSize'));
    end
    n = full(n);
end

% Process the input B and derive the class of the problem.
% Is B present in the eigs call or not?
Bpresent = true;
if nargin < 3-Amatrix
    B = [];
    Bpresent = false;
else
    % Is the next input B or K?
    B = varargin{3-Amatrix};
    if ~isempty(B) % allow eigs(A,[],k,sigma,opts);
        if isscalar(B)
            if n ~= 1
                % this input is really K and B is not specified
                B = [];
                Bpresent = false;
            else
                % This input could be B or K.
                % If A is scalar, then the only valid value for k is 1.
                % So if this input is scalar, let it be B, namely
                % eigs(4,2,...) assumes A=4, B=2, NOT A=4, k=2
                if ~isnumeric(B)
                    error(message('MATLAB:eigsUsingARPACK:BnonDouble'));
                end
                % Unless, of course, the scalar is 1, in which case
                % assume that it is meant to be K.
                if (B == 1) && ((Amatrix && nargin <= 4) || ...
                        (~Amatrix && nargin <= 5))
                    B = [];
                    Bpresent = false;
                elseif ~isa(B,'double')
                    error(message('MATLAB:eigsUsingARPACK:BnonDouble'));
                end
            end
        else
            % B is a not a scalar.
            if ~isa(B,'double')
                error(message('MATLAB:eigsUsingARPACK:BnonDouble'));
            elseif ~isequal(size(B), [n,n])
                error(message('MATLAB:eigsUsingARPACK:BsizeMismatchA'));
            end
        end
    end
end

if Bpresent
    isrealprob = isrealprob && isreal(B);
end

% argOffset tells us where to get the eigs inputs K, SIGMA and OPTS.
% If A is really the function afun, then it also helps us find the
% trailing parameters in eigs(afun,n,[B],k,sigma,opts,P1,P2,...)
argOffset = Amatrix + ~Bpresent;
if Amatrix && nargin > 4 + Bpresent
    error(message('MATLAB:eigsUsingARPACK:TooManyInputs'));
end

% Process the input K
if nargin < 4-argOffset
    k = min(n,6);
else
    k = varargin{4-argOffset};
    if ~isnumeric(k) || ~isscalar(k) || ~isreal(k) || k>n || ...
            k<0 || ~isfinite(k) || round(k) ~= k
        if isnumeric(k) && isscalar(k)
            error(message('MATLAB:eigsUsingARPACK:NonIntegerEigQtyDetail', n, num2str(k)));
        elseif ischar(k)
            error(message('MATLAB:eigsUsingARPACK:NonIntegerEigQtyDetail', n, ['''' k '''']));
        elseif isstruct(k)
            error(message('MATLAB:eigsUsingARPACK:NonIntegerEigQtyStruct', n));
        else
            error(message('MATLAB:eigsUsingARPACK:NonIntegerEigQty', n));
        end
    end
    k = double(full(k));
end

% Process the input SIGMA and derive ARPACK values whch, sigma,
% and mode. Possibilities include:
% eigsSigma = 'SM' or 0 : sigma = 0, whch = 'LM' , mode = 3
% eigsSigma is scalar : sigma = eigsSigma, whch = 'LM', mode = 3
% otherwise: sigma = 0, whch = eigsSigma, mode = 1
if nargin < 5-argOffset
    % default: eigs 'LM' => ARPACK whch='LM', sigma=0, mode=1
    eigsSigma = 'LM';
    whch = 'LM';
    sigma = 0;
    mode = 1;
else
    eigsSigma = varargin{5-argOffset};
    if ischar(eigsSigma)
        if ~isrow(eigsSigma)|| length(eigsSigma) ~=2
            error(message('MATLAB:eigsUsingARPACK:InvalidSigma'));
        end
        eigsSigma = upper(eigsSigma);
        if strcmp(eigsSigma,'SM')
            % eigs('SM') => ARPACK which='LM', sigma=0
            whch = 'LM';
            mode = 3;
        else
            % eigs(other string) => ARPACK which=string, sigma=0
            whch = eigsSigma;
            mode = 1;
            if ~ismember(whch,{'LM', 'LA', 'SA', 'BE', ...
                    'LR', 'SR', 'LI', 'SI'})
                error(message('MATLAB:eigsUsingARPACK:InvalidSigma'));
            end
        end
        sigma = 0;
        
    else
        % eigs(scalar) => ARPACK which='LM', sigma=scalar
        if ~isfloat(eigsSigma) || ~isscalar(eigsSigma)
            error(message('MATLAB:eigsUsingARPACK:InvalidSigma'));
        end
        sigma = double(full(eigsSigma));
        isrealprob = isrealprob && isreal(sigma);
        whch = 'LM';
        mode = 3;
    end
end
% Process the input OPTS and derive some ARPACK values
tol = eps;
maxit = [];
p = [];
% Always use v0 as the start vector, whether it is OPTS.v0 or randomly
% generated within eigs.  We default v0 to empty here. If the user does
% not initialize it, we provide a random starting vector below.
v0 = [];
eigsDisplay = 0;
cholB = false;
permB = [];
if nargin >= 6-argOffset
    opts = varargin{6-argOffset};
    if ~isa(opts,'struct')
        error(message('MATLAB:eigsUsingARPACK:OptionsNotStructure'));
    end
    % Check options for AFUN: issym and isreal
    if isfield(opts,'issym') && ~Amatrix
        ishermA = opts.issym;
        if ~isscalar(ishermA) || (ishermA ~= true && ishermA ~= false)
            error(message('MATLAB:eigsUsingARPACK:InvalidOptsIssym'));
        end
    end
    if isfield(opts,'isreal') && ~Amatrix
        if ~isscalar(opts.isreal) || (opts.isreal ~= true && opts.isreal ~= false)
            error(message('MATLAB:eigsUsingARPACK:InvalidOptsIsreal'));
        end
        isrealprob = isrealprob && opts.isreal;
    end
    % Check options for B: cholB and permB
    if ~isempty(B) && isfield(opts,'cholB')
        cholB = opts.cholB;
        if ~isscalar(cholB) || (cholB ~= true && cholB ~= false)
            error(message('MATLAB:eigsUsingARPACK:InvalidOptsCholB'));
        end
        if isfield(opts,'permB')
            if issparse(B) && cholB
                permB = opts.permB;
                if ~isvector(permB) || ~isequal(sort(permB(:)),(1:n)')
                    error(message('MATLAB:eigsUsingARPACK:InvalidOptsPermB'));
                end
            else
                warning(message('MATLAB:eigsUsingARPACK:IgnoredOptionPermB'));
            end
        end
        if cholB
            if ~istriu(B) % Make sure B is upper triangular
                error(message('MATLAB:eigsUsingARPACK:BNotChol'));
            end
        end
    end
    % Check options for ARPACK: tol, p, maxit, and v0
    if isfield(opts,'tol')
        tol = opts.tol;
        if ~isfloat(tol) || ~isscalar(tol) || ~isreal(tol) || (tol<=0) ...
                || ~isfinite(tol)
            error(message('MATLAB:eigsUsingARPACK:InvalidOptsTol'));
        end
        tol = double(full(tol));
    end
    if isfield(opts,'p')
        p = opts.p;
        if ~isnumeric(p) || ~isscalar(p) || ~isreal(p) || p<=0 || p>n ...
                || round(p) ~= p || ~isfinite(p)
            error(message('MATLAB:eigsUsingARPACK:InvalidOptsP'));
        end
        p = double(full(p));
    end
    if isfield(opts,'maxit')
        maxit = opts.maxit;
        if ~isnumeric(maxit) || ~isscalar(maxit) || ~isreal(maxit) ...
                || (maxit<=0) || ~isfinite(maxit) || round(maxit) ~= maxit
            error(message('MATLAB:eigsUsingARPACK:OptsMaxitNotPosInt'));
        end
        maxit = double(full(maxit));
    end
    if isfield(opts,'v0')
        if ~isa(opts.v0, 'double') || ~iscolumn(opts.v0) || length(opts.v0) ~= n
            error(message('MATLAB:eigsUsingARPACK:WrongSizeOptsV0'));
        end
        if isrealprob
            if ~isreal(opts.v0)
                error(message('MATLAB:eigsUsingARPACK:NotRealOptsV0'));
            end
            v0(1:n,1) = full(opts.v0);
        else
            v0(2:2:2*n,1) = full(imag(opts.v0));
            v0(1:2:(2*n-1),1) = full(real(opts.v0));
        end
    end
    % Check option for display: possible values are 0,1,2
    if isfield(opts,'disp')
        eigsDisplay = opts.disp;
        if  ~isscalar(eigsDisplay) || (eigsDisplay ~= 0 && ...
                eigsDisplay ~= 1 && eigsDisplay ~= 2)
            error(message('MATLAB:eigsUsingARPACK:NonIntegerDiagnosticLevel'));
        end
    end
end

if isempty(v0)
    if isrealprob
        v0 = rand(n,1);
    else
        v0 = rand(2*n,1);
    end
end

if ~Amatrix && nargin > 7-argOffset
    % Add trailing parameters into function handle A
    args = varargin(7-argOffset:nargin);
    A = createAfun(A, args{:});
end

% Scale the matrix B, if needed
if ~isempty(B)
    scaleB = norm(B,'fro')./sqrt(n);
    scaleB = 2.^floor(log2(scaleB+1));
    B = B./scaleB;
    if cholB
        scaleB = scaleB.^2;
    end
    if isscalar(eigsSigma)
        sigma = scaleB.*eigsSigma;
    end
else
    scaleB = [];
end

% Create an inner options struct to carry around our values
innerOpts = struct('tol', tol, 'maxit', maxit, 'p', p, 'v0', v0, ...
    'eigsDisplay', eigsDisplay, 'whch', whch, 'sigma', sigma, ...
    'ishermA', ishermA, 'isrealprob', isrealprob);

end

function A = createAfun(Afun, varargin)
% Add trailing parameters into function handle A
A = @(v) Afun(v, varargin{:});
end

function [R, permB, BisHpd] = CHOLfactorB(B, cholB, permB, mode)
% Get the Cholesky factorization of B and determine if it is Hermitian
% Positive (semi) Definite

if cholB
    % CHOL(B) was passed in as B
    R = B;
    BisHpd = true;
    if ~isempty(permB)
        n = size(B,1);
        permB = sparse(permB,1:n,1,n,n);
    end
elseif ~isempty(B) && ishermitian(B)
    % CHOL(B) was not passed into EIGS, Algorithm requires CHOL(B)
    % to be computed, if only to determine BisHPD
    if issparse(B)
        [R, idxB, permB] = chol(B,'vector');
    else
        [R, idxB] = chol(B);
    end
    if mode == 3
        R = [];
        permB = [];
    end
    if idxB == 0
        BisHpd = true;
    elseif mode == 3 && isreal(B)
        % LDL decomposition is only for 'SM' eigenvalues of the
        % pair (A,B) where B is Hermitian positive
        % semi-definite; in this case, as ARPACK users' guide
        % suggests, one should still use B-(semi)inner product
        [~, D, ~] = ldl(B,'vector');
        % Determine if D is positive semi-definite, by checking diagonal
        % elements are non-negative and 2x2 diagonal blocks are positive
        % semi-definite:
        alpha = diag(D);
        beta = diag(D,1);
        BisHpd = checkTridiagForHSD(alpha, beta);
    else
        BisHpd = false;
    end
    if ~isempty(permB)
        n = size(B,1);
        permB = sparse(permB,1:n,1,n,n);
    end
else
    R = [];
    permB = [];
    BisHpd = false;
end
end

function BisHpd = checkTridiagForHSD(alpha, beta)
% CHECKTRIDIAGFORHSD
%   Uses Sturm sequence on alpha (diagonal) and beta (superdiagonal) to
%   determine if the matrix diag(alpha,0) + diag(beta,1) + diag(beta,-1) is
%   Positive Semi-definite.
n = length(alpha);
BisHpd = true;
d = alpha(1);
if d < 0
    BisHpd = false;
    return;
end
for k = 1:(n-1)
    if d == 0
        d = eps*(abs(beta(k))+eps);
    end
    d = alpha(k+1) - beta(k)*(beta(k)/d);
    if d < 0
        BisHpd = false;
        return;
    end
end
end

function [V, D] = fullEig (A, B, n, k, cholB, permB, R, scaleB, eigsSigma)
% Use EIG(FULL(A)) or EIG(FULL(A),FULL(B)) instead of ARPACK
if ~isempty(B)
    if cholB % use B's cholesky factor and its transpose
        if ~isempty(permB)
            R = R * permB';
        end
        B = R'*R;
    end
    B = full(B.*scaleB);
end
if isa(A, 'double')
    A = full(A);
else
    % A is specified by a function.
    % Form the matrix A by applying the function
    if ischar(eigsSigma) && ~strcmp(eigsSigma,'SM')
        % A is a function multiplying A*x
        AA = eye(n);
        for i = 1:n
            AA(:,i) = A(AA(:,i));
        end
        A = AA;
    else
        if (isfloat(eigsSigma) && eigsSigma == 0) || strcmp(eigsSigma,'SM')
            % A is a function solving A\x
            invA = eye(n);
            for i = 1:n
                invA(:,i) = A(invA(:,i));
            end
            A = eye(n) / invA;
        else
            % A is a function solving (A-sigma*B)\x
            % B may be [], indicating the identity matrix
            % U = (A-sigma*B)\sigma*B
            % => (A-sigma*B)*U = sigma*B
            % => A*U = sigma*B*(U + eye(n))
            % => A = sigma*B*(U + eye(n)) / U
            if isempty(B)
                sB = eigsSigma*eye(n);
            else
                sB = eigsSigma*B;
            end
            U = zeros(n,n);
            for i = 1:n
                U(:,i) = A(sB(:,i));
            end
            A = sB*(U+eye(n)) / U;
        end
    end
end

% Now with full floating point matrices A and B, use EIG:
if nargout <= 1
    if isempty(B)
        d = eig(A);
    else
        d = eig(A, B);
    end
else
    if isempty(B)
        [V, d] = eig(A, 'vector');
    else
        [V, d] = eig(A, B, 'vector');
    end
end

% Grab the eigenvalues we want, based on sigma
if ischar(eigsSigma)
    switch eigsSigma
        case 'LM'
            [~,ind] = sort(abs(d));
            ind = ind(n-k+1:n);
        case 'SM'
            [~,ind] = sort(abs(d));
            ind = ind(k:-1:1);
        case 'LA'
            [~,ind] = sort(d);
            ind = ind(n:-1:n-k+1);
        case 'SA'
            [~,ind] = sort(d);
            ind = ind(1:k);
        case 'LR'
            [~,ind] = sort(real(d));
            ind = ind(n-k+1:n);
        case 'SR'
            [~,ind] = sort(real(d));
            ind = ind(k:-1:1);
        case 'LI'
            [~,ind] = sort(imag(d));
            ind = ind(n-k+1:n);
        case 'SI'
            [~,ind] = sort(imag(d));
            ind = ind(k:-1:1);
        case 'BE'
            [~,ind] = sort(d);
            ind = ind([1:floor(k/2), n-ceil(k/2)+1:n]);
    end
else
    % sigma is a scalar
    [~,ind] = sort(abs(d-eigsSigma));
    ind = ind(1:k);
end

if nargout <= 1
    V = d(ind);
else
    V = V(:,ind);
    D = diag(d(ind));
end

end

function [innerOpts, useEig] = extraChecks(innerOpts, B, n, k, BisHpd)
% Here we finalize problem type (ishermprob), and do remaining argument
% checks that require knowing the problem type: Check on correct sigma,
% check that k is not too large, and set defaults for p and maxit.

% If B not HPD, OP is not Hermitian (even if A is)
innerOpts.ishermprob = innerOpts.ishermA && (isempty(B) || BisHpd);
isrealprob = innerOpts.isrealprob;
ishermprob = innerOpts.ishermprob;

% Extra Checks on sigma
if ishermprob && ~isreal(innerOpts.sigma)
    warning(message('MATLAB:eigsUsingARPACK:ComplexShiftForHermitianProblem'));
end

if isrealprob && ishermprob
    if strcmp(innerOpts.whch,'LR')
        innerOpts.whch = 'LA';
        warning(message('MATLAB:eigsUsingARPACK:SigmaChangedToLA'));
    end
    if strcmp(innerOpts.whch,'SR')
        innerOpts.whch = 'SA';
        warning(message('MATLAB:eigsUsingARPACK:SigmaChangedToSA'));
    end
    if ~ismember(innerOpts.whch,{'LM', 'SM', 'LA', 'SA', 'BE'})
        error(message('MATLAB:eigsUsingARPACK:EigenvalueRangeNotValidSym'));
    end
else
    if strcmp(innerOpts.whch,'BE')
        warning(message('MATLAB:eigsUsingARPACK:SigmaChangedToLM'));
        innerOpts.whch = 'LM';
    end
    if ~ismember(innerOpts.whch,{'LM', 'SM', 'LR', 'SR', 'LI', 'SI'})
        error(message('MATLAB:eigsUsingARPACK:EigenvalueRangeNotValidComp'));
    end
end

% Large values of K force us to use full EIG instead of ARPACK.
useEig = false;
if k == 0
    useEig = true;
end
if isrealprob && ishermprob
    if k > n-1
        useEig = true;
    end
else
    if k > n-2
        useEig = true;
    end
end
% The remainder of the error checking does not apply for full EIG
if useEig
    return
end

% Extra check/set defaults for input OPTS.p and OPTS.maxit
if isempty(innerOpts.p)
    if isrealprob && ~ishermprob
        innerOpts.p = min(max(2*k+1,20),n);
    else
        innerOpts.p = min(max(2*k,20),n);
    end
else
    if isrealprob && ishermprob
        if innerOpts.p <= k
            error(message('MATLAB:eigsUsingARPACK:InvalidOptsPforRealSymProb'));
        end
    else
        if innerOpts.p <= k+1
            error(message('MATLAB:eigsUsingARPACK:InvalidOptsPforComplexOrNonSymProb'));
        end
    end
end
if isempty(innerOpts.maxit)
    innerOpts.maxit = max(300,ceil(2*n/max(innerOpts.p,1)));
end
end

function [applyOP, applyM] = getOps(A, B, n, BisHpd, mode, R, cholB, ...
    permB, Amatrix, innerOpts)
% Create the operations used for ARPACK

applyA = @(v) createApplyA(v, A, Amatrix, innerOpts.isrealprob);
applyB = @(v) createApplyB(v, B, R, cholB, permB);
applyM = @(v) v;
if mode == 1
    if isempty(B) % OP = A
        applyOP = applyA;
    elseif BisHpd % OP = R^{-T} A R^{-1} (B = R^T R)
        applyOP = applyAwithCholB(B, R, permB, applyA);
    else % B not HPD, OP = U^{-1} L^{-1} A (B = L U)
        applyOP = applyAwithLUB(B, applyA, n);
    end
else % mode == 3
    if isempty(B) % OP = (A-sigma I)^{-1}
        applyOP = AminusSigmaISolve(A, innerOpts.sigma, Amatrix, n, applyA);
    else % B is not empty, OP = (A-sigma B)^{-1}*B
        applyOP = AminusSigmaBSolve(A, B, innerOpts.sigma, Amatrix, n, ...
            applyA, applyB, cholB);
    end
    if BisHpd
        applyM = applyB;
    end
end

end

function v = createApplyA(u, A, Amatrix, isrealprob)
if Amatrix
    v = A*u;
else % A is a function handle
    v = A(u);
    if isrealprob && ~isreal(v)
        error(message('MATLAB:eigsUsingARPACK:complexFunction'));
    end
end
end

function v = createApplyB(u, B, R, cholB, permB)
% Apply B
if cholB % use B's cholesky factor and its transpose
    if ~isempty(permB)
        v = permB*(R'* (R * (permB'*u)));
    else
        v = R'* (R * u);
    end
else
    v = B * u;
end
end

function applyOP = applyAwithCholB(B, R, permB, applyA)
if issparse(B)
    RT = R'; % Compute R' explicitly for performance reasons
    if ~isempty(permB)        
        applyOP = @(v) RT \ (permB'*(applyA(permB*(R \ v))));
    else
        applyOP = @(v) RT \ (applyA(R \ v));
    end
else
    applyOP = @(v) fullApplyAwithCholB(v, R, applyA);
end
end

function v = fullApplyAwithCholB(u, R, applyA)
v = linsolve(R,u,struct('UT',true));
v = applyA(v);
v = linsolve(R,v,struct('UT',true, 'TRANSA', true));
end

function applyOP = applyAwithLUB(B, applyA, n)
if issparse(B)
    [L, U, P, Q, D] = lu(B);
    applyOP = @(v) Q*(U \ (L \ (P*(D\(applyA(v))))));
else
    [L,U,p] = lu(B,'vector');
    P = sparse(1:n,p,1,n,n);
    applyOP = @(v) U \ (L \ (P*applyA(v)));
end
WarnIfIllConditioned(L, U, 'B', []);
end

function applyOP = AminusSigmaISolve(A, sigma, Amatrix, n, applyA)
if Amatrix
    % Build A - sigma I
    if sigma == 0
        AminusSigmaI = A;
    else
        AminusSigmaI = A - sigma * speye(n);
    end
    % Do LU factorization of AminusSigmaI and create applyOP
    if issparse(AminusSigmaI)
        [L,U,P,Q,D] = lu(AminusSigmaI);
        applyOP = @(v) Q * (U \ (L \ (P * (D\v))));
    else
        [L,U,p] = lu(AminusSigmaI,'vector');
        applyOP = @(v) U \ (L \ v(p));
    end
    WarnIfIllConditioned(L, U, 'A', sigma);
else
    applyOP = applyA;
end

end

function applyOP = AminusSigmaBSolve(A, B, sigma, Amatrix, n, applyA, ...
    applyB, cholB)
if Amatrix
    if sigma == 0
        AminusSigmaB = A;
    elseif cholB
        AminusSigmaB = A - sigma * applyB(speye(n));
    else
        AminusSigmaB = A - sigma * B;
    end
    if issparse(AminusSigmaB)
        [L,U,P,Q,D] = lu(AminusSigmaB);
        applyOP = @(v) Q * (U \ (L \ (P * (D\applyB(v)))));
    else
        [L,U,p] = lu(AminusSigmaB,'vector');
        P = sparse(1:n,p,1,n,n);
        applyOP = @(v) U \ (L \ (P * applyB(v)));
    end
    WarnIfIllConditioned(L, U, 'A', sigma);
else
    applyOP = @(v) applyA(applyB(v));
end
end

function WarnIfIllConditioned(L, U, type, sigma)
if type == 'A' 
    if sigma == 0 % Warn if lu(A) is ill-conditioned
        warningZero = 'MATLAB:eigsUsingARPACK:SingularA';
        warningEps = 'MATLAB:eigsUsingARPACK:IllConditionedA';
    else % Warn if lu(A-sigmaB) is ill-conditioned
        warningZero = 'MATLAB:eigsUsingARPACK:AminusBSingular';
        warningEps = 'MATLAB:eigsUsingARPACK:SigmaNearExactEig';
    end
else % Warn if lu(B) is ill-conditioned
    warningZero = 'MATLAB:eigsUsingARPACK:SingularB';
    warningEps = 'MATLAB:eigsUsingARPACK:IllConditionedB';
end
% Check for singularity and ill-condition
dU = diag(U);
if any(dU == 0) || any(diag(L) == 0)
    error(message(warningZero));
end
rcondestU = full(min(abs(dU)) / max(abs(dU)));
if rcondestU < eps
    warning(message(warningEps, sprintf('%f',rcondestU)));
end
end

function [v, d, flag, timings, t0] = CallARPACK(applyOP, applyM, n, k, ...
    innerOpts, mode, t0, nOutputs)
% Send variables to ARPACK and run algorithm

% Platform dependent integer type
if strfind(computer, '64')
    intconvert = @(arraytoconvert) int64(arraytoconvert);
    inttype = 'int64';
else
    intconvert = @(arraytoconvert) int32(arraytoconvert);
    inttype = 'int32';
end

% Allocate outputs and ARPACK work variables
p = innerOpts.p;
isrealprob = innerOpts.isrealprob;
ishermprob = innerOpts.ishermprob;
if isrealprob
    if ishermprob % real and symmetric
        aupdfun = 'dsaupd';
        eupdfun = 'dseupd';
        lworkl = intconvert(p*(p+8));
    else % real but not symmetric
        aupdfun = 'dnaupd';
        eupdfun = 'dneupd';
        lworkl = intconvert(3*p*(p+2));
        workev = zeros(3*p,1);
    end
    v = zeros(n,p);
    workd = zeros(n,3);
    workl = zeros(lworkl,1);
else % complex
    aupdfun = 'znaupd';
    eupdfun = 'zneupd';
    zv = zeros(2*n*p,1);
    workd = complex(zeros(n,3));
    zworkd = zeros(2*numel(workd),1);
    lworkl = intconvert(2*(3*p^2+5*p));
    workl = zeros(lworkl,1);
    workev = zeros(2*2*p,1);
    rwork = zeros(p,1);
end

% Convert/Define some other ARPACK variables
whch = innerOpts.whch;
sigma = innerOpts.sigma;
v0 = innerOpts.v0;
tol = innerOpts.tol;
p = intconvert(p); % number of Lanczos vectors, in ARPACK: ncv
k = intconvert(k); % number of eigenvalues requested, in ARPACK: nev
ndouble = n; % use the double version of n for division
n = intconvert(n); % problem size, in ARPACK: ldv
info = intconvert(1); % makes ARPACK take v0 as starting vector
ipntr = zeros(15,1,inttype); % initialize pointers
ido = intconvert(0); % reverse communication parameter, initial value
iparam = zeros(11,1,inttype); % initializes parameters/options
% iparam(1) = ishift = 1 ensures we are never asked to handle ido=3
iparam([1 3 7]) = [1 innerOpts.maxit mode];
select = zeros(p,1,inttype); % specifies which ritz values to compute, etc
if mode == 1
    bmat = 'I'; % standard eigenvalue problem
else
    bmat = 'G'; % generalized eigenvalue problem
end
% The ARPACK routines return to EIGS many times per each iteration but we
% only want to display the Ritz values once per iteration (if opts.disp>0).
% Keep track of whether we've displayed this iteration yet in eigsIter.
eigsIter = 0;

timings = zeros(5,1);
timings(1) = toc(t0); % end timing pre-processing

% Reset random seed of arpackc
arpackc_reset();

% Iterate until ARPACK's reverse communication parameter ido says to stop
while ido ~= 99
    
    t0 = tic; % start timing ARPACK calls **aupd
    
    if isrealprob
        [ido, info] = arpackc( aupdfun, ido, bmat, n, whch, ...
            k, tol, v0, p, v, n, iparam, ipntr, workd, workl, ...
            lworkl, info );
    else
        % The FORTRAN ARPACK routine expects the complex input zworkd to have
        % real and imaginary parts interleaved, but the OP about to be
        % applied to workd expects it in MATLAB's complex representation with
        % separate real and imaginary parts. Thus we need both.
        zworkd(1:2:end-1) = real(workd);
        zworkd(2:2:end) = imag(workd);
        [ido, info] = arpackc( aupdfun, ido, bmat, n, whch, ...
            k, tol, v0, p, zv, n, iparam, ipntr, zworkd, workl, ...
            lworkl, rwork, info );
        workd = reshape(complex(zworkd(1:2:end-1),zworkd(2:2:end)),[n,3]);
    end
    
    if info < 0
        error(message('MATLAB:eigsUsingARPACK:ARPACKroutineError', aupdfun, full(double(info))));
    end
    
    timings(2) = timings(2) + toc(t0); % end timing ARPACK calls **aupd
    t0 = tic; % start timing MATLAB OP(X)
    
    % Compute which columns of workd ipntr references
    cols = checkIpntr;
    
    % The ARPACK reverse communication parameter ido tells EIGS what to do
    switch ido
        case -1
            workd(:,cols(2)) = applyOP(workd(:,cols(1)));
        case 1
            workd(:,cols(3)) = applyM(workd(:,cols(1)));
            workd(:,cols(2)) = applyOP(workd(:,cols(1)));
        case 2
            workd(:,cols(2)) = applyM(workd(:,cols(1)));
        case 99
            % ARPACK has converged
        otherwise
            error(message('MATLAB:eigsUsingARPACK:UnknownIdo'));
    end
    
    timings(3) = timings(3) + toc(t0); % end timing MATLAB OP(X)
    
    if innerOpts.eigsDisplay
        displayRitzValues();
    end
    
end % while ido ~= 99

t0 = tic; % start timing post-processing

if nOutputs >= 2
    rvec = intconvert(true); % compute eigenvectors
else
    rvec = intconvert(false); % do not compute eigenvectors
end

if isrealprob
    if ishermprob
        [d, info] = arpackc(eupdfun, rvec, 'A', select, v, n, sigma, ...
            bmat, n, whch, k, tol, v0, p, v, n, ...
            iparam, ipntr, workd, workl, lworkl, info);
        v(:,k+1:end) = [];
        converged = ~isnan(d);
        if strcmp(whch,'LM') || strcmp(whch,'LA')
            d(converged) = flip(d(converged),1);
            if rvec
                v(:,converged) = flip(v(:,converged),2);
            end
        end
        if (strcmp(whch,'SM') || strcmp(whch,'SA')) && ~rvec
            d(converged) = flip(d(converged),1);
        end
    else
        % If sigma is complex, isrealprob=true and we use [c,z]neupd.
        % So use sigmar=sigma and sigmai=0 here in dneupd.
        [d, info] = arpackc(eupdfun, rvec, 'A', select, v, n, ...
            sigma, 0, workev, bmat, n, whch, k, tol, v0, ...
            p, v, n, iparam, ipntr, workd, workl, lworkl, info );
        if rvec
            d(k+1) = [];
            cplxd = find(imag(d) ~= 0 & ~isnan(imag(d)));
            % complex conjugate pairs of eigenvalues occur together
            cplxd = cplxd(1:2:end);
            v(:,[cplxd cplxd+1]) = [complex(v(:,cplxd),v(:,cplxd+1)) ...
                complex(v(:,cplxd),-v(:,cplxd+1))];
            v(:,k+1:end) = [];
        else
            converged = ~isnan(d);
            if all(converged)
                d = d(k+1:-1:2);
            else
                d(k+1) = [];
                d(converged) = flip(d(converged),1);
            end
        end
    end
else
    zsigma = [real(sigma); imag(sigma)];
    [zd, info] = arpackc(eupdfun, rvec, 'A', select, zv, n, zsigma, ...
        workev, bmat, n, whch, k, tol, v0, p, zv, ...
        n, iparam, ipntr, zworkd, workl, lworkl, rwork, info );
    if ishermprob
        d = zd(1:2:end-1);
    else
        d = complex(zd(1:2:end-1),zd(2:2:end));
    end
    d(k+1) = [];
    v = reshape(complex(zv(1:2:end-1),zv(2:2:end)),[n p]);
    v(:,k+1:end) = [];
    if ~rvec
        converged = ~isnan(d);
        if ~all(converged)
            d(converged) = flip(d(converged),1);
        end
    end
end

flag = processEUPDinfo(nOutputs<3);

% Nested functions in CallARPACK
    function cols = checkIpntr
        % Check that ipntr returned from ARPACK refers to the start of a
        % column of workd.
        if ido == 1
            inds = double(ipntr(1:3));
        else
            inds = double(ipntr(1:2));
        end
        rows = mod(inds-1,ndouble)+1;
        cols = (inds-rows)/ndouble+1;
        if ~all(rows==1)
            error(message('MATLAB:eigsUsingARPACK:ipntrMismatchWorkdColumn'));
        end
    end

    function displayRitzValues
        % Display a few Ritz values at the current iteration
        iter = double(ipntr(15));
        if iter > eigsIter && ido ~= 99
            eigsIter = iter;
            ds = getString(message('MATLAB:eigsUsingARPACK:RitzValuesDisplayHeader',iter,p,p));
            disp(ds)
            if isrealprob
                if ishermprob
                    dispvec = workl(double(ipntr(6))+(0:p-1));
                    if strcmp(whch,'BE')
                        % roughly k Large eigenvalues and k Small eigenvalues
                        disp(dispvec(max(end-2*k+1,1):end))
                    else
                        % k eigenvalues
                        disp(dispvec(max(end-k+1,1):end))
                    end
                else
                    dispvec = complex(workl(double(ipntr(6))+(0:p-1)), ...
                        workl(double(ipntr(7))+(0:p-1)));
                    % k+1 eigenvalues (keep complex conjugate pairs together)
                    disp(dispvec(max(end-k,1):end))
                end
            else
                dispvec = complex(workl(2*double(ipntr(6))-1+(0:2:2*(p-1))), ...
                    workl(2*double(ipntr(6))+(0:2:2*(p-1))));
                disp(dispvec(max(end-k+1,1):end))
            end
        end
    end

    function flag = processEUPDinfo(warnNonConvergence)
        % Process the info flag returned by the ARPACK routine **eupd
        if info ~= 0 && info ~= -14
            error(message('MATLAB:eigsUsingARPACK:ARPACKroutineError', eupdfun, full(info)));
        end
        nconv = double(iparam(5));
        flag = double(nconv < k);
        if flag && warnNonConvergence
            warning(message('MATLAB:eigsUsingARPACK:NotAllEigsConverged', nconv, k));
        end
    end
end

function V = postProcessVectors(V, B, scaleB, mode, R, cholB, permB, k)
if mode == 1 % Do R^(-1) v
    if issparse(B)
        if ~isempty(permB)
            V = permB* (R \ V);
        else
            V = R \ V;
        end
    else
        V = linsolve(R,V,struct('UT',true));
    end
end
% Normalize in B norm
if cholB
    if ~isempty(permB)
        R = R * permB';
    end
    for ii = 1:k
        vn = sqrt(scaleB) * norm(R*V(:,ii));
        V(:,ii) = V(:,ii)/vn;
    end
else
    for ii = 1:k
        vii = V(:,ii);
        vn2 = scaleB * (vii'*B*vii);
        V(:,ii) = V(:,ii)/sqrt(vn2);
    end
end
end

function printTimings(timings, mode, Amatrix, B)
% Print the time taken for each major stage of the EIGS algorithm
if mode == 1
    innerstr = getString(message('MATLAB:eigsUsingARPACK:PrintTimingsComputeAX',sprintf('%f',timings(3))));
else % mode = 3
    if isempty(B)
        innerstr = getString(message('MATLAB:eigsUsingARPACK:PrintTimingsSolveASIGMAI',sprintf('%f',timings(3))));
    else
        innerstr = getString(message('MATLAB:eigsUsingARPACK:PrintTimingsSolveASIGMAB',sprintf('%f',timings(3))));
    end
end
if mode == 3 && Amatrix
    if isempty(B)
        prepstr = getString(message('MATLAB:eigsUsingARPACK:PrintTimingsPreproSigmaI',sprintf('%f',timings(1))));
    else
        prepstr = getString(message('MATLAB:eigsUsingARPACK:PrintTimingsPreproSigmaB',sprintf('%f',timings(1))));
    end
else
    prepstr = getString(message('MATLAB:eigsUsingARPACK:PrintTimingsPreprocessing',sprintf('%f',timings(1))));
end
sstr = getString(message('MATLAB:eigsUsingARPACK:PrintTimingsCPUTimingResults'));
postpstr = getString(message('MATLAB:eigsUsingARPACK:PrintTimingsPostprocessing',sprintf('%f',timings(4))));
totalstr = getString(message('MATLAB:eigsUsingARPACK:PrintTimingsTotal',sprintf('%f',timings(5))));
fprintf(['\n' sstr '\n' ...
    prepstr ...
    'IRAM/IRLM:                                 %f\n' ...
    innerstr ...
    postpstr...
    '***************************************************\n' ...
    totalstr ...
    sstr '\n'], ...
    timings(2));
end