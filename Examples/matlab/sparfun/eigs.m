function [V, D, flag] = eigs(varargin)
% EIGS   Find a few eigenvalues and eigenvectors of a matrix
%  D = EIGS(A) returns a vector of A's 6 largest magnitude eigenvalues.
%  A must be square and should be large and sparse.
%
%  [V,D] = EIGS(A) returns a diagonal matrix D of A's 6 largest magnitude
%  eigenvalues and a matrix V whose columns are the corresponding
%  eigenvectors.
%
%  [V,D,FLAG] = EIGS(A) also returns a convergence flag. If FLAG is 0 then
%  all the eigenvalues converged; otherwise not all converged.
%
%  EIGS(A,B) solves the generalized eigenvalue problem A*V == B*V*D. B must
%  be the same size as A. EIGS(A,[],...) indicates the standard eigenvalue
%  problem A*V == V*D.
%
%  EIGS(A,K) and EIGS(A,B,K) return the K largest magnitude eigenvalues.
%
%  EIGS(A,K,SIGMA) and EIGS(A,B,K,SIGMA) return K eigenvalues. If SIGMA is:
%
%      'largestabs' or 'smallestabs' - largest or smallest magnitude
%    'largestreal' or 'smallestreal' - largest or smallest real part
%                     'bothendsreal' - K/2 values with largest and
%                                      smallest real part, respectively
%                                      (one more from largest if K is odd)
%
%  For nonsymmetric problems, SIGMA can also be:
%    'largestimag' or 'smallestimag' - largest or smallest imaginary part
%                     'bothendsimag' - K/2 values with largest and
%                                     smallest imaginary part, respectively
%                                     (one more from largest if K is odd)
%
%  If SIGMA is a real or complex scalar including 0, EIGS finds the
%  eigenvalues closest to SIGMA.
%
%  EIGS(A,K,SIGMA,NAME,VALUE) and EIGS(A,B,K,SIGMA,NAME,VALUE) configures
%  additional options specified by one or more name-value pair arguments:
%
%  'IsFunctionSymmetric' - Symmetry of matrix applied by function handle Afun
%            'Tolerance' - Convergence tolerance
%         'MaxIterations - Maximum number of iterations
%    'SubspaceDimension' - Size of subspace
%          'StartVector' - Starting vector
%     'FailureTreatment' - Treatment of non-converged eigenvalues
%              'Display' - Display diagnostic messages
%           'IsCholesky' - B is actually its Cholesky factor
%  'CholeskyPermutation' - Cholesky vector input refers to B(perm,perm)
%  'IsSymmetricDefinite' - B is symmetric positive definite
%
%  EIGS(A,K,SIGMA,OPTIONS) and EIGS(A,B,K,SIGMA,OPTIONS) alternatively
%  configures the additional options using a structure. See the
%  documentation for more information.
%
%  EIGS(AFUN,N) and EIGS(AFUN,N,B) accept the function AFUN instead of the
%  matrix A. AFUN is a function handle and Y = AFUN(X) should return
%     A*X            if SIGMA is unspecified, or a string other than 'SM'
%     A\X            if SIGMA is 0 or 'SM'
%     (A-SIGMA*I)\X  if SIGMA is a nonzero scalar (standard problem)
%     (A-SIGMA*B)\X  if SIGMA is a nonzero scalar (generalized problem)
%  N is the size of A. The matrix A, A-SIGMA*I or A-SIGMA*B represented by
%  AFUN is assumed to be nonsymmetric unless specified otherwise
%  by OPTS.issym.
%
%  EIGS(AFUN,N,...) is equivalent to EIGS(A,...) for all previous syntaxes.
%
%  Example:
%     A = delsq(numgrid('C',15));  d1 = eigs(A,5,'SM');
%
%  Equivalently, if dnRk is the following one-line function:
%     %----------------------------%
%     function y = dnRk(x,R,k)
%     y = (delsq(numgrid(R,k))) \ x;
%     %----------------------------%
%
%     n = size(A,1);  opts.issym = 1;
%     d2 = eigs(@(x)dnRk(x,'C',15),n,5,'SM',opts);
%
%  See also EIG, SVDS, FUNCTION_HANDLE.

%  Copyright 1984-2018 The MathWorks, Inc.
%  References:
%  [1] Stewert, G.W., "A Krylov-Schur Algorithm for Large Eigenproblems."
%  SIAM. J. Matrix Anal. & Appl., 23(3), 601-614.
%  [2] Lehoucq, R.B. , D.C. Sorensen and C. Yang, ARPACK Users' Guide,
%  Society for Industrial and Applied Mathematics, 1998


% Error check inputs and derive some information from them
[A, n, B, k, Amatrix, eigsSigma, shiftAndInvert, cholB, permB, scaleB, spdB,...
    innerOpts, randStr, useEig, originalB] = checkInputs(varargin{:});

if ~useEig || ismember(innerOpts.method, {'LI', 'SI'})
    % Determine whether B is HPD and do a Cholesky decomp if necessary
    [R, permB, spdB] = CHOLfactorB(B, cholB, permB, shiftAndInvert, spdB);
    
    % Final argument checking before call to algorithm
    [innerOpts, useEig, eigsSigma] = extraChecks(innerOpts, B, n, k, spdB, useEig, eigsSigma);
end

if innerOpts.disp
    displayInitialInformation(innerOpts, B, n, k, spdB, useEig, eigsSigma, shiftAndInvert, Amatrix);
end

% We fall back on using the full EIG code if p is too large (size of
% subspace to build = size of whole problem)
% The K == 0 case is also handled here
if useEig
    if nargout <= 1
        V = fullEig(A, B, n, k, cholB, permB, scaleB, eigsSigma);
    else
        [V, D] = fullEig(A, B, n, k, cholB, permB, scaleB, eigsSigma);
        if strcmp(innerOpts.fail,'keep')
            flag = false(k,1);
        else
            flag = 0;
        end
    end
    return
end

% Define the operations needed for Krylov Schur algorithm
[applyOP, applyM] = getOps(A, B, n, spdB, shiftAndInvert, R, cholB, permB,...
    Amatrix, innerOpts);

% Send variables to KS and run algorithm
[V, d, isNotConverged, spdBout, VV] = KrylovSchur(applyOP, applyM, innerOpts, n, k,...
    shiftAndInvert, randStr, spdB);

% Do some post processing of the output for generalized problem
[V, d, isNotConverged] = postProcessing(V, d, isNotConverged, eigsSigma, B, scaleB, ...
    shiftAndInvert, R, permB, spdB, nargout);



if spdB && ~spdBout && ~any(isNotConverged)
    % This happens if B is symmetric positive semi-definite, and the rank
    % of B is not larger than the subspace dimension used in KrylovSchur.
    % Project both A and B into the orthogonal subspace VV found in
    % KrylovSchur, and apply EIG directly to this generalized problem.
    
    applyA = createApplyA(A, Amatrix);
    applyB = createApplyB(originalB, originalB, cholB, permB);
    Asmall = VV'*applyA(VV);
    if innerOpts.ishermprob
        Asmall = (Asmall + Asmall')/2;
    end
    Bsmall = VV'*applyB(VV);
    Bsmall = (Bsmall + Bsmall')/2;
    
    [V, D] = fullEig(Asmall, Bsmall, size(VV, 2), k, false, [], 1, eigsSigma);
    V = VV*V;
    d = diag(D);
end

% Give correct output based on Failure Treatment option (replacenan is default)
if strcmpi(innerOpts.fail,'keep')
    flag = isNotConverged;
elseif strcmpi(innerOpts.fail,'drop')
    d = d(~isNotConverged);
    if nargout > 1
        V = V(:,~isNotConverged);
    end
    flag = double(any(isNotConverged));
else
    d(isNotConverged) = NaN;
    flag = double(any(isNotConverged));
end

% If flag is not returned, give warning about convergence failure
if nargout < 3 && any(isNotConverged)
    if strcmpi(innerOpts.fail,'keep')
        warning(message('MATLAB:eigs:NotAllEigsConvKeep', sum(~isNotConverged), k));
    elseif strcmpi(innerOpts.fail,'drop')
        warning(message('MATLAB:eigs:NotAllEigsConvDrop', sum(~isNotConverged), k));
    else
        warning(message('MATLAB:eigs:NotAllEigsConverged', sum(~isNotConverged), k));
    end
end

% Assign outputs
if nargout <= 1
    V = d;
else
    D = diag(d);
end

end

function [A, n, B, k, Amatrix, eigsSigma, shiftAndInvert, cholB, permB, scaleB, spdB, ...
    innerOpts, randStr, useEig, originalB]  = checkInputs(varargin)
% Process the inputs and get some information from them

% Set the rand stream to make algorithm reproducible
randStr = RandStream('dsfmt19937','Seed',0);

isrealprob = true;
ishermprob = false;

if isa(varargin{1},'double')
    A = varargin{1};
    Amatrix = true;
    isrealprob = isreal(A);
    ishermprob = ishermitian(A);
    [m, n] = size(A);
    if m ~= n
        error(message('MATLAB:eigs:NonSquareMatrixOrFunction'));
    end
else
    % By checking the function A with fcnchk, we can now use direct
    % function evaluation on the result, without resorting to feval
    [A, notFunc] = fcnchk(varargin{1});
    Amatrix = false;
    if ~isempty(notFunc)
        error(message('MATLAB:eigs:NonDoubleOrFunction'));
    end
    if nargin < 2
        error(message('MATLAB:eigs:MustHaveSecondInput'));
    end
    n = varargin{2};
    if ~isscalar(n) || ~isreal(n) || n<0 || ~isfinite(n) || round(n) ~= n
        error(message('MATLAB:eigs:NonPosIntSize'));
    end
    n = full(n);
end

% Process the input B. Is B present in the eigs call or not?
if nargin < 3-Amatrix
    Bpresent = false;
    B = [];
else
    % Is the next input B or K?
    Bpresent = isBpresent(varargin{3-Amatrix}, nargin, Amatrix, n);
    if Bpresent
        B = varargin{3-Amatrix};
        isrealprob = isrealprob && isreal(B);
    else
        B = [];
    end
end

% Store the original B before any scaling
originalB = B;

% argOffset tells us where to get the eigs inputs K, SIGMA and OPTS.
% If A is really the function afun, then it also helps us find the
% trailing parameters in eigs(afun,n,[B],k,sigma,opts,P1,P2,...)
% Values of argOffset:
%  0: Amatrix is false and Bpresent is true:
%     eigs(afun,n,B,k,sigma,opts,P1,P2,...)
%  1: Amatrix and Bpresent are both true, or both false
%     eigs(A,B,k,sigma,opts)
%     eigs(afun,n,k,sigma,opts,P1,P2,...)
%  2: Amatrix is true and Bpresent is false:
%     eigs(A,k,sigma,opts)
argOffset = Amatrix + ~Bpresent;

% Process the input K
if nargin < 4-argOffset
    k = min(n,6);
else
    k = varargin{4-argOffset};
    if ~isnumeric(k) || ~isscalar(k) || ~isreal(k) || k>n || ...
            k<0 || ~isfinite(k) || round(k) ~= k
        if isnumeric(k) && isscalar(k)
            error(message('MATLAB:eigs:NonIntegerEigQtyDetail', n, num2str(k)));
        elseif ischar(k)
            error(message('MATLAB:eigs:NonIntegerEigQtyDetail', n, ['''' k '''']));
        elseif isstruct(k)
            error(message('MATLAB:eigs:NonIntegerEigQtyStruct', n));
        else
            error(message('MATLAB:eigs:NonIntegerEigQty', n));
        end
    end
    k = double(full(k));
end

% Process the input SIGMA:
% eigsSigma = 'SM' or 0 : sigma = 0, method = 'LM' , shiftAndInvert = true
% eigsSigma is scalar : sigma = eigsSigma, method = 'LM' , shiftAndInvert = true
% otherwise: sigma = 0, method = eigsSigma, shiftAndInvert = false
if nargin < 5-argOffset
    % set default
    eigsSigma = 'largestabs';
    method = 'largestabs';
    sigma = 0;
    shiftAndInvert = false;
else
    eigsSigma = varargin{5-argOffset};
    if (ischar(eigsSigma) && isrow(eigsSigma)) || (isstring(eigsSigma) && isscalar(eigsSigma))
        validSigmasOld = {'LM','SM','LA','LR','SA','SR','BE','LI','SI'};
        validSigmasNew = {'largestabs','smallestabs','largestreal','smallestreal',...
            'bothendsreal','largestimag','smallestimag','bothendsimag'};
        if length(eigsSigma) == 2
            match = startsWith(validSigmasOld, eigsSigma, 'IgnoreCase', true);
            if nnz(match) ~= 1 || strlength(eigsSigma) == 0
                error(message('MATLAB:eigs:InvalidSigma'));
            else
                eigsSigma = validSigmasOld{match};
            end
        else
            match = startsWith(validSigmasNew, eigsSigma, 'IgnoreCase', true);
            if nnz(match) ~= 1 || strlength(eigsSigma) == 0
                error(message('MATLAB:eigs:InvalidSigma'));
            else
                eigsSigma = validSigmasNew{match};
            end
        end
        
        if ismember(eigsSigma,{'SM','smallestabs'})
            eigsSigma = 'smallestabs';
            method = 'largestabs';
            shiftAndInvert = true;
        else
            % Allow old sigma values to flow through. Will convert 'LI' and
            % 'SI' in extraChecks once we have the required info
            if strcmp(eigsSigma,'LM')
                eigsSigma = 'largestabs';
            elseif ismember(eigsSigma,{'LA','LR'})
                eigsSigma = 'largestreal';
            elseif ismember(eigsSigma,{'SA','SR'})
                eigsSigma = 'smallestreal';
            elseif strcmp(eigsSigma,'BE')
                eigsSigma = 'bothendsreal';
            end
            
            method = eigsSigma;
            shiftAndInvert = false;
        end
        sigma = 0;
    elseif isfloat(eigsSigma) && isscalar(eigsSigma)
        % SIGMA is a scalar
        eigsSigma = double(full(eigsSigma));
        sigma = eigsSigma;
        isrealprob = isrealprob && isreal(sigma);
        method = 'largestabs';
        shiftAndInvert = true;
    else
        error(message('MATLAB:eigs:InvalidSigma'));
    end
end

% Set defaults for input options
tol = 1e-14;
maxit = 300;
p =  min(max(2*k,20),n);
userp = false; % logical -- did the user set option p?
v0 = randn(randStr, n,1);
fail = 'replacenan';
disp = 0;
cholB = false;
permB = [];
spdB = [];

% Process the input options struct
NameValueFlag = false;
optsStart = 6-argOffset;
if nargin >= optsStart
    if isstruct(varargin{optsStart})
        opts = varargin{optsStart};
        if nargin > optsStart
            if Amatrix
                error(message('MATLAB:eigs:TooManyInputs'));
            else
                % Add trailing parameters into function handle A
                args = varargin(7-argOffset:nargin);
                A = createAfun(A, args{:});
            end
        end
    else
        % Convert name-value pairs to struct for ease of error checking
        NameValueFlag = true;
        for j = optsStart:2:length(varargin)
            name = varargin{j};
            if (~(ischar(name) && isrow(name)) && ~(isstring(name) && isscalar(name))) ...
                    || (isstring(name) && strlength(name) == 0)
                error(message('MATLAB:eigs:ParseFlags'));
            end
            nvNames = ["IsFunctionSymmetric", "Tolerance", "MaxIterations", ...
                "SubspaceDimension", "StartVector", "IsSymmetricDefinite", ...
                "IsCholesky", "CholeskyPermutation", "FailureTreatment", ...
                "Display"];
            structNames = {'issym','tol','maxit','p','v0','spdB','cholB','permB','fail','disp'};
            ind = startsWith(nvNames, name, 'IgnoreCase', true);
            if nnz(ind) ~= 1
                error(message('MATLAB:eigs:ParseFlags'));
            end
            if j+1 > length(varargin)
                error(message('MATLAB:eigs:KeyWithoutValue'));
            end
            
            opts.(structNames{ind}) = varargin{j+1};
        end
    end
    
    % Check option for AFUN: issym and isreal
    if isfield(opts,'issym')
        ishermprob = checkIsSym(opts.issym, ishermprob, Amatrix, NameValueFlag);
    end
    if isfield(opts,'isreal') && ~Amatrix
        % opts.isreal is an old option that is now only used with inputs
        % 'si' or 'li', to determine to which new sigma value they
        % translate.
        if ~isscalar(opts.isreal) || (opts.isreal ~= true && opts.isreal ~= false)
            error(message('MATLAB:eigs:InvalidOptsIsreal'));
        end
        isrealprob = isrealprob && opts.isreal;
    end
    
    % Check options for algorithm: tol, p, maxit, v0, and fail
    if isfield(opts,'tol')
        tol = checkTol(opts.tol, NameValueFlag);
    end
    if isfield(opts,'p')
        p = checkP(opts.p, n, k, NameValueFlag);
        userp = true;
    end
    if isfield(opts,'maxit')
        maxit = checkMaxit(opts.maxit, NameValueFlag);
    end
    if isfield(opts,'v0')
        v0 = checkV0(opts.v0, n, NameValueFlag);
        isrealprob = isrealprob && isreal(v0);
    end
    if isfield(opts, 'fail')
        fail = checkFail(opts.fail, NameValueFlag);
    end
    if isfield(opts, 'disp')
        disp = checkDisp(opts.disp, NameValueFlag);
    end
    
    % Check options for B: cholB, permB and spdB
    if ~isempty(B) && isfield(opts,'cholB')
        cholB = checkCholB(opts.cholB, B, NameValueFlag);
        if isfield(opts,'permB')
            % Note, permB is silently ignored if user does not give cholB
            permB = checkPermB(opts.permB, cholB, issparse(B), n, NameValueFlag);
        end
    end
    
    if ~isempty(B) && isfield(opts, 'spdB')
        spdB = checkSPDB(opts.spdB, B, cholB, NameValueFlag);
    end
    
end

if p >= n || k == 0
    % Since we are going to build the whole subspace anyway, just use
    % full eig. Ignore starting vector and InnerOpts.
    useEig = true;
else
    useEig = false;
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

% Create an inner options struct to carry around values
innerOpts = struct('tol', tol, 'maxit', maxit, 'p', p, 'v0', v0, 'method',...
    method, 'sigma', sigma, 'ishermprob', ishermprob, 'isrealprob', isrealprob, ...
    'fail', fail, 'disp', disp, 'userp', userp);

end


function Bpresent = isBpresent(B, nin, Amatrix, n)

if isempty(B) % allow eigs(A,[],k,sigma,opts);
    Bpresent = true; % this will cause input [] to be skipped
    return;
end
if ~isnumeric(B)
    Bpresent = false;
    return;
end
if ~isscalar(B)
    % B is not a scalar.
    if ~isa(B,'double')
        error(message('MATLAB:eigs:BnonDouble'));
    elseif ~isequal(size(B), [n,n])
        error(message('MATLAB:eigs:BsizeMismatchA'));
    end
    Bpresent = true;
    return;
end

if n ~= 1
    % B is a numeric scalar, and A is not scalar:
    % This input is really K and B is not specified
    Bpresent = false;
    return;
end
% This input could be B or K.
% If A is scalar, then the only valid value for k is 1.
% So if this input is scalar, let it be B, namely
% eigs(4,2,...) assumes A=4, B=2, NOT A=4, k=2
% Unless, of course, the scalar is 1, in which case
% assume that it is meant to be K.
if (B == 1) && ((Amatrix && nin <= 4) || (~Amatrix && nin <= 5))
    Bpresent = false;
else
    Bpresent = true;
    if ~isa(B,'double')
        error(message('MATLAB:eigs:BnonDouble'));
    end
end
end


function ishermprob = checkIsSym(issym, ishermprob, Amatrix, NameValueFlag)
if Amatrix
    % only read opts.issym if A is function handle
    if NameValueFlag
        warning(message('MATLAB:eigs:IgnoredIsFunctionSymmetric'));
    else
        warning(message('MATLAB:eigs:IgnoredOptionIssym'));
    end
else
    ishermprob = issym;
    if ~isscalar(ishermprob) || (ishermprob ~= true && ishermprob ~= false)
        if NameValueFlag
            error(message('MATLAB:eigs:InvalidIsFunctionSymmetric'));
        else
            error(message('MATLAB:eigs:InvalidOptsIssym'));
        end
    end
end
end

function tol = checkTol(tol, NameValueFlag)
if ~isfloat(tol) || ~isscalar(tol) || ~isreal(tol) || (tol<=0) ...
        || ~isfinite(tol)
    if NameValueFlag
        error(message('MATLAB:eigs:InvalidTolerance'));
    else
        error(message('MATLAB:eigs:InvalidOptsTol'));
    end
end
tol = double(full(tol));
end


function p = checkP(p, n, k, NameValueFlag)
if ~isnumeric(p) || ~isscalar(p) || ~isreal(p) || p<=0 || p>n ...
        || round(p) ~= p || ~isfinite(p)
    if NameValueFlag
        error(message('MATLAB:eigs:InvalidSubspaceDimension'));
    else
        error(message('MATLAB:eigs:InvalidOptsP'));
    end
end
if p <= k+1
    if NameValueFlag
        error(message('MATLAB:eigs:SubspaceDimensionTooSmall'));
    else
        error(message('MATLAB:eigs:OptsPtooSmall'));
    end
end
p = double(full(p));
end

function maxit = checkMaxit(maxit, NameValueFlag)
if ~isnumeric(maxit) || ~isscalar(maxit) || ~isreal(maxit) ...
        || (maxit<=0) || ~isfinite(maxit) || round(maxit) ~= maxit
    if NameValueFlag
        error(message('MATLAB:eigs:MaxIterationsNotPosInt'));
    else
        error(message('MATLAB:eigs:OptsMaxitNotPosInt'));
    end
end
maxit = double(full(maxit));
end

function v0 = checkV0(v0, n, NameValueFlag)
if ~isa(v0, 'double') || ~iscolumn(v0) || length(v0) ~= n
    if NameValueFlag
        error(message('MATLAB:eigs:WrongSizeStartVector'));
    else
        error(message('MATLAB:eigs:WrongSizeOptsV0'));
    end
end
v0 = full(v0);
end

function fail = checkFail(fail, NameValueFlag)
if (ischar(fail) && isrow(fail)) || (isstring(fail) && isscalar(fail))
    ValidFails = {'replacenan','keep','drop'};
    match = startsWith(ValidFails, fail, 'IgnoreCase', true);
    if nnz(match) ~= 1 || (strlength(fail) == 0)
        if NameValueFlag
            error(message('MATLAB:eigs:InvalidFailureTreatment'))
        else
            error(message('MATLAB:eigs:InvalidOptsFail'))
        end
    else
        fail = ValidFails{match};
    end
else
    if NameValueFlag
        error(message('MATLAB:eigs:InvalidFailureTreatment'));
    else
        error(message('MATLAB:eigs:InvalidOptsFail'));
    end
end
end

function cholB = checkCholB(cholB, B, NameValueFlag)
if ~isscalar(cholB) || (cholB ~= true && cholB ~= false)
    if NameValueFlag
        error(message('MATLAB:eigs:InvalidIsCholesky'));
    else
        error(message('MATLAB:eigs:InvalidOptsCholB'));
    end
end
if cholB
    if ~istriu(B) % Make sure B is upper triangular
        if NameValueFlag
            error(message('MATLAB:eigs:BNotCholNV'));
        else
            error(message('MATLAB:eigs:BNotChol'));
        end
    end
end
end

function permB = checkPermB(permB, cholB, issparseB, n, NameValueFlag)
if issparseB && cholB
    if ~isvector(permB) || ~isequal(sort(permB(:)),(1:n)')
        if NameValueFlag
            error(message('MATLAB:eigs:InvalidCholeskyPermutation'));
        else
            error(message('MATLAB:eigs:InvalidOptsPermB'));
        end
    end
else
    if NameValueFlag
        warning(message('MATLAB:eigs:IgnoredCholeskyPermutation'));
    else
        warning(message('MATLAB:eigs:IgnoredOptionPermB'));
    end
end
permB = sparse(permB,1:n,1,n,n);
end

function spdB = checkSPDB(spdB, B, cholB, NameValueFlag)
if ~isscalar(spdB) || (spdB ~= true && spdB ~= false)
    if NameValueFlag
        error(message('MATLAB:eigs:InvalidIsSymmetricDefinite'));
    else
        error(message('MATLAB:eigs:InvalidOptsSpdB'));
    end
end
if ~spdB && cholB
    if NameValueFlag
        error(message('MATLAB:eigs:InvalidIsSymmetricDefiniteWithIsCholesky'));
    else
        error(message('MATLAB:eigs:InvalidSpdBwithCholB'));
    end
end
if spdB && ~cholB && ~ishermitian(B)
    if NameValueFlag
        error(message('MATLAB:eigs:IsSymmetricDefiniteNotSymmetric'));
    else
        error(message('MATLAB:eigs:spdBNotSymmetric'));
    end
end
end

function disp = checkDisp(disp, NameValueFlag)
if ~(isnumeric(disp) || islogical(disp)) || ~isscalar(disp) || ~isfinite(disp)
    if NameValueFlag
        error(message('MATLAB:eigs:InvalidDisplay'));
    else
        error(message('MATLAB:eigs:OptsInvalidDisp'));
    end
end
disp = disp ~= 0;
end

function A = createAfun(Afun, varargin)
% Add trailing parameters into function handle A
A = @(v) Afun(v, varargin{:});
end

function [R, permB, spdB] = CHOLfactorB(B, cholB, permB, shiftAndInvert, spdB)
% Get the Cholesky factorization of B and determine if it is Hermitian
% Positive (semi) Definite

if isempty(B)
    % Standard problem, set values to flow through
    R = [];
    permB = [];
    spdB = false;
elseif cholB
    % We already have the Cholesky factor, store it in R
    R = B;
    spdB = true;
elseif ishermitian(B) && (isempty(spdB)|| (spdB && ~shiftAndInvert))
    % We need to see if B is SPD by using chol OR
    % We know B is SPD, and we need Cholesky decomposition
    if issparse(B)
        [R, idxB, permB] = chol(B);
    else
        [R, idxB] = chol(B);
    end
    
    if idxB == 0
        % B is SPD, no further check needed
        spdB = true;
    elseif shiftAndInvert && isreal(B)
        % Check whether B is positive SEMI-definite by checking D from the
        % whether the D LDL decomposition is positive semi-definite
        [~, D, ~] = ldl(B,'vector');
        % Check that diagonal elements are non-negative and 2x2 diagonal
        % blocks are positive semi-definite:
        alpha = diag(D);
        beta = diag(D,1);
        spdB = checkTridiagForHSD(alpha, beta);
    else
        if spdB
            error(message('MATLAB:eigs:IsSymmetricDefiniteNotPD'));
        else % spdB is false or []
            spdB = false;
        end
    end
    
    if shiftAndInvert || ~spdB
        % We do not actually need the Cholesky factor to solve the problem
        R = [];
        permB = [];
    end
    
else
    % We do not need chol
    R = [];
    permB = [];
    if isempty(spdB)
        % B is empty or not Hermitian
        spdB = false;
    end
    % else we take the user's input
end
end

function spdB = checkTridiagForHSD(alpha, beta)
% CHECKTRIDIAGFORHSD
%   Uses Sturm sequence on alpha (diagonal) and beta (superdiagonal) to
%   determine if the matrix diag(alpha,0) + diag(beta,1) + diag(beta,-1) is
%   Positive Semi-definite.
n = length(alpha);
spdB = true;
d = alpha(1);
if d < 0
    spdB = false;
    return;
end
for k = 1:(n-1)
    if d == 0
        d = eps*(abs(beta(k))+eps);
    end
    d = alpha(k+1) - beta(k)*(beta(k)/d);
    if d < 0
        spdB = false;
        return;
    end
end
end

function [innerOpts, useEig, eigsSigma] = extraChecks(innerOpts, B, n, k, spdB, useEig, eigsSigma)
% Do remaining argument checks that require knowing the problem type

% If B not HPD, OP is not Hermitian (even if A is)
innerOpts.ishermprob = innerOpts.ishermprob && (isempty(B) || spdB);

% Maintain old sigma behavior and convert to new sigma
if ismember(innerOpts.method, {'LI', 'SI'})
    if innerOpts.isrealprob && ~innerOpts.ishermprob
        if strcmp(innerOpts.method, 'LI')
            eigsSigma = 'bothendsimag';
            innerOpts.method = eigsSigma;
        else
            eigsSigma = 'smallestimagabs';
            innerOpts.method = eigsSigma;
        end
    else
        if strcmp(innerOpts.method, 'LI')
            eigsSigma = 'largestimag';
            innerOpts.method = eigsSigma;
        else
            eigsSigma = 'smallestimag';
            innerOpts.method = eigsSigma;
        end
    end
end

% Extra Checks on sigma
if innerOpts.ishermprob
    if ismember(innerOpts.method, {'largestimag', 'smallestimag', 'bothendsimag'})
        % Problem has all real eigenvalues, and therefore we cannot sort
        % them by imaginary part. Sort instead by abs(real)
        innerOpts.method = 'largestabs';
    end
    
    if ~isreal(innerOpts.sigma)
        % Problem has all real eigenvalues but a complex shift
        % Taking the real part keeps the problem real and symmetric but
        % results will be the same
        innerOpts.sigma = real(innerOpts.sigma);
    end
end

% Extra check/set default for input OPTS.p

if ~innerOpts.userp && innerOpts.isrealprob && ~innerOpts.ishermprob ...
        && ismember(innerOpts.method, {'largestimag', 'smallestimag'})
    
    % Raise p to account for needing to add conjugate pairs to the subspace
    innerOpts.p = min(max(4*k,20),n);
    
    if innerOpts.p == n
        % Since we are building the whole space anyway, do a full
        % decomposition
        useEig = true;
    end
end

end

function displayInitialInformation(innerOpts, B, n, k, spdB, useEig, eigsSigma, shiftAndInvert, Amatrix)
fprintf('\n');
if isempty(B)
    disp(['=== ' getString(message('MATLAB:eigs:TitleSimple')) ' ===']);
else
    disp(['=== ' getString(message('MATLAB:eigs:TitleGeneralized')) ' ===']);
end
fprintf('\n');
if innerOpts.isrealprob
    if innerOpts.ishermprob
        disp(getString(message('MATLAB:eigs:ProbSym')));
    else
        disp(getString(message('MATLAB:eigs:ProbNonSym')));
    end
else
    if innerOpts.ishermprob
        disp(getString(message('MATLAB:eigs:ProbHerm')));
    else
        disp(getString(message('MATLAB:eigs:ProbNonHerm')));
    end
end
if ~isempty(B)
    if innerOpts.isrealprob
        if spdB
            disp(getString(message('MATLAB:eigs:BSPD')));
        else
            disp(getString(message('MATLAB:eigs:BNonSPD')));
        end
    else
        if spdB
            disp(getString(message('MATLAB:eigs:BHPD')));
        else
            disp(getString(message('MATLAB:eigs:BNonHPD')));
        end
    end
end
fprintf('\n');
if ~isnumeric(eigsSigma)
    disp(getString(message('MATLAB:eigs:KandSigmaString', k, eigsSigma)));
else
    disp(getString(message('MATLAB:eigs:KandSigmaNum', k, num2str(eigsSigma))));
end
fprintf('\n');
% Pre-compute string describing A - sigma*B
if shiftAndInvert
    if isequal(eigsSigma, 'smallestabs') || isequal(eigsSigma, 0)
        shiftedAstring = 'A';
    elseif isempty(B)
        shiftedAstring = '(A - sigma*I)';
    else
        shiftedAstring = '(A - sigma*B)';
    end
end

if ~Amatrix
    if ~shiftAndInvert
        disp(getString(message('MATLAB:eigs:Afun', n, n, 'A * x')));
    else
        disp(getString(message('MATLAB:eigs:Afun', n, n, [shiftedAstring ' \ x'])));
    end
end
fprintf('\n');
disp(getString(message('MATLAB:eigs:ListParam', num2str(innerOpts.maxit), num2str(innerOpts.tol), innerOpts.p)));
fprintf('\n');
if useEig
    disp(getString(message('MATLAB:eigs:EigFallback')));
else
    % Description of eigenvalue problem being passed to Krylov-Schur
    % method:
    if isempty(B)
        if ~shiftAndInvert
            disp(getString(message('MATLAB:eigs:SimpleDir')));
        else
            disp(getString(message('MATLAB:eigs:SimpleInv', shiftedAstring, shiftedAstring)));
        end
    elseif spdB
        if ~shiftAndInvert
            disp(getString(message('MATLAB:eigs:GenSPDDir')));
        else
            disp(getString(message('MATLAB:eigs:GenSPDInv', shiftedAstring, shiftedAstring)));
        end
    else
        if ~shiftAndInvert
            disp(getString(message('MATLAB:eigs:GenDir')));
        else
            disp(getString(message('MATLAB:eigs:GenInv', shiftedAstring, shiftedAstring)));
        end
    end
    fprintf('\n');
end
end

function displayIteration(mm, maxit, nconv, k0, minrelres, tol)

mmstr = sprintf('%*d', ceil(log10(maxit+1)), mm);
nconvstr = sprintf('%*d', ceil(log10(k0+1)), nconv);
k0str = sprintf('%*d', ceil(log10(k0+1)), k0);

if ~isempty(minrelres)
    disp(getString(message('MATLAB:eigs:KrylovSchurIter', ...
        mmstr, nconvstr, k0str, ...
        sprintf('%.1e', minrelres), ...
        sprintf('%.1e', tol))));
else
    disp(getString(message('MATLAB:eigs:KrylovSchurLastIter', ...
        mmstr, nconvstr, k0str)));
end
end

function [V, D] = fullEig (A, B, n, k, cholB, permB, scaleB, eigsSigma)
% Use EIG(FULL(A),FULL(B)) instead of Krylov Schur algorithm

if k == 0
    if nargout <= 1
        V = zeros(0, 1);
        return;
    else
        V = zeros(n, 0);
        D = zeros(0,0);
        return;
    end
end

if ~isempty(B)
    if cholB % use B's cholesky factor and its transpose
        if ~isempty(permB)
            B = B*permB';
        end
        B = B'*B;
    end
    B = full(B.*scaleB);
end
if isa(A, 'double')
    A = full(A);
else
    % A is specified by a function.
    % Check output of Afun
    vec = A(eye(n,1));
    if ~iscolumn(vec) || ~isa(vec,'double') || length(vec) ~= n
        % Will only error if the user provides a function handle that does
        % not output a vector of the expected size
        error(message('MATLAB:eigs:InvalidFhandleOutput',n))
    end
    % Form the matrix A by applying the function
    if ischar(eigsSigma) && ~strcmp(eigsSigma,'smallestabs')
        % A is a function multiplying A*x
        AA = eye(n);
        for i = 1:n
            AA(:,i) = A(AA(:,i));
        end
        A = AA;
    else
        if (isfloat(eigsSigma) && eigsSigma == 0) || strcmp(eigsSigma,'smallestabs')
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

% Check that values are finite (infs and NaNs cause eig to fail)
if ~all(isfinite(A(:))) || ~all(isfinite(B(:)))
    error(message('MATLAB:eigs:VeryBadCondition'))
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
    if ishermitian(A) && isreal(d) && ismember(eigsSigma, {'largestimag', 'smallestimag', 'bothendsimag'})
        eigsSigma = 'largestabs';
    end
    ind = whichEigenvalues(d, eigsSigma);
else
    % sigma is a scalar
    [~,ind] = sort(abs(d-eigsSigma));
end

ind = ind(1:k);

if isequal(eigsSigma, 'bothendsreal')
    % Choose eigenvalues alternating between top and bottom, but then sort
    % them in ascending direction
    [~, ind2] = sort(real(d(ind)), 'ascend');
    ind = ind(ind2);
end

if nargout <= 1
    V = d(ind);
else
    V = V(:,ind);
    D = diag(d(ind));
end

end

function ind = whichEigenvalues(d, method)

switch method
    case 'largestabs'
        [~, ind] = sort(abs(d), 'descend');
    case 'largestreal'
        [~, ind] = sort(real(d), 'descend');
    case 'smallestreal'
        [~, ind] = sort(real(d), 'ascend');
    case 'largestimag'
        [~, ind] = sort(imag(d), 'descend');
    case 'smallestimag'
        [~, ind] = sort(imag(d), 'ascend');
    case 'bothendsreal'
        [~, ind] = sort(real(d), 'descend');
        ind2 = [ind, flip(ind)]';
        ind2 = ind2(:);
        ind = ind2(1:size(d,1));
    case 'bothendsimag'
        [~, ind] = sort(imag(d), 'descend');
        ind2 = [ind, flip(ind)]';
        ind2 = ind2(:);
        ind = ind2(1:size(d,1));
    case 'smallestabs'
        [~,ind] = sort(abs(d), 'ascend');
    case 'smallestimagabs'
        [~,ind] = sort(abs(imag(d)), 'ascend');
end

end

function [applyOP, applyM] = getOps(A, B, n, spdB, shiftAndInvert, R, cholB, ...
    permB, Amatrix, innerOpts)
% Create the operations used in algorithm

applyA = createApplyA(A, Amatrix);
applyB = createApplyB(B, R, cholB, permB);
applyM = @(v) v;

if isempty(B) % Standard problem
    if ~shiftAndInvert% OP = A
        applyOP = applyA;
    else  % OP = (A-sigma I)^{-1}
        applyOP = AminusSigmaISolve(A, innerOpts.sigma, Amatrix, n, applyA);
    end
else % Generalized Problem
    if ~shiftAndInvert
        if spdB % OP = R^{-T} A R^{-1} (B = R^T R)
            applyOP = applyAwithCholB(R, permB, applyA);
        else % B not HPD, OP = B^{-1} A
            applyOP = applyAwithInvB(B, applyA);
        end
    else % OP = (A-sigma B)^{-1}
        applyOP = AminusSigmaBSolve(A, B, innerOpts.sigma, Amatrix, n, ...
            applyA, applyB, cholB);
        if ~spdB % OP = (A-sigma B)^{-1}*B
            applyOP = @(v) applyOP(applyB(v));
        else % B is Hpd, OP = (A-sigma B)^{-1}, M = B
            applyM = applyB;
        end
    end
end
end

function applyA = createApplyA(A, Amatrix)
if Amatrix
    applyA = @(u) A*u;
else % A is already a function handle
    applyA = A;
end
end

function applyB = createApplyB(B, R, cholB, permB)
% Apply B
if isempty(B)
    applyB = @(u) u;
elseif cholB % use B's cholesky factor and its transpose
    if ~isempty(permB)
        applyB = @(u) permB*(R'* (R * (permB'*u)));
    else
        applyB = @(u) R'* (R * u);
    end
else
    applyB = @(u) B * u;
end
end

function applyOP = applyAwithCholB(R, permB, applyA)
if issparse(R)
    dR = matlab.internal.decomposition.SparseTriangular(R, 'upper', [], []);
else
    dR = matlab.internal.decomposition.DenseTriangular(R, 'upper', [], []);
end

if isempty(permB)
    % applyOP = @(v) R' \ (applyA(R \ v));
    applyOP = @(v) solve(dR, applyA( solve(dR, v, false) ), true);
else
    % applyOP = @(v) R' \ (permB'*(applyA(permB*(R \ v))));
    applyOP = @(v) solve(dR, permB' * applyA( permB * solve(dR, v, false) ), true);
end
WarnIfIllConditioned(rcond(dR), 'R', []);
end

function applyOP = applyAwithInvB(B, applyA)
if issparse(B)
    umf = matlab.internal.decomposition.builtin.UMFPACKWrapper(B, 0.1, 0.001, true, 0);
    applyOP = @(v) solve(umf, applyA(v), false);
    WarnIfIllConditioned(rcond(umf), 'B', []);
else
    dB = decomposition(B, 'lu', 'CheckCondition', false);
    applyOP = @(v) dB\applyA(v);
    WarnIfIllConditioned(rcond(dB), 'B', []);
end
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
        umf = matlab.internal.decomposition.builtin.UMFPACKWrapper(AminusSigmaI, 0.1, 0.001, true, 0);
        applyOP = @(v) solve(umf, v, false);
        WarnIfIllConditioned(rcond(umf), 'A', sigma);
    else
        dAminusSigmaI = decomposition(AminusSigmaI, 'lu', 'CheckCondition', false);
        applyOP = @(v) dAminusSigmaI\v;
        WarnIfIllConditioned(rcond(dAminusSigmaI), 'A', sigma);
    end
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
        umf = matlab.internal.decomposition.builtin.UMFPACKWrapper(AminusSigmaB, 0.1, 0.001, true, 0);
        applyOP = @(v) solve(umf, v, false);
        WarnIfIllConditioned(rcond(umf), 'A', sigma);
    else
        dAminusSigmaB = decomposition(AminusSigmaB, 'lu', 'CheckCondition', false);
        applyOP = @(v) dAminusSigmaB\v;
        WarnIfIllConditioned(rcond(dAminusSigmaB), 'A', sigma);
    end
else
    applyOP = applyA;
end
end

function WarnIfIllConditioned(rcondest, type, sigma)
if type == 'A'
    if sigma == 0 % Warn if A is ill-conditioned
        warningZero = 'MATLAB:eigs:SingularA';
        warningEps = 'MATLAB:eigs:IllConditionedA';
    else % Warn if A-sigmaB is ill-conditioned
        warningZero = 'MATLAB:eigs:AminusBSingular';
        warningEps = 'MATLAB:eigs:SigmaNearExactEig';
    end
else % Warn if B is ill-conditioned
    warningZero = 'MATLAB:eigs:SingularB';
    warningEps = 'MATLAB:eigs:IllConditionedB';
end
% Check for singularity and ill-condition
if type == 'R'
    rcondest = rcondest^2;
end
if rcondest == 0
    error(message(warningZero));
elseif rcondest < eps || isnan(rcondest)
    warning(message(warningEps, sprintf('%13.6e',rcondest)));
end
end

function [V, d, isNotConverged, spdB, VV] = KrylovSchur(applyOP, applyM, ...
    innerOpts, n, k, shiftAndInvert, randStr, spdB)

if innerOpts.disp
    disp(['--- ' getString(message('MATLAB:eigs:StartKrylovSchur')) ' ---']);
end

% Normalize starting vector
v = innerOpts.v0;
v = v/sqrt(abs(v'*applyM(v)));

if ~(abs(sqrt(v'*applyM(v)) - 1) < 1e-14)
    % Normalization of starting vector failed
    v2 = innerOpts.v0/norm(innerOpts.v0);
    if ~(abs(norm(v2) - 1) < 1e-14)
        error(message('MATLAB:eigs:InvalidStartingVector'))
    else
        error(message('MATLAB:eigs:InvalidStartingVectorBnorm'))
    end
end

innerOpts.v0 = v;

if innerOpts.ishermprob
    [V, d, isNotConverged, stopAlgorithm] = KSherm(applyOP, applyM, n, k, ...
        innerOpts, randStr, shiftAndInvert);
    VV = V; % V already orthogonal
else
    [V, d, isNotConverged, stopAlgorithm, VV] = KSnonherm(applyOP, applyM, n, k, ...
        innerOpts, randStr, shiftAndInvert);
end

if stopAlgorithm
    if spdB && shiftAndInvert
        % Could not build an orthogonal subspace, possibly due to B being
        % low rank. Attempt again, treating B as not HPD
        if innerOpts.disp
            disp(getString(message('MATLAB:eigs:FailKrylovSchur')))
            fprintf('\n');
            disp(['--- ' getString(message('MATLAB:eigs:StartKrylovSchur')) ' ---'])
        end
        
        spdB = false; % Communicate that columns of V will not be B-orthogonal.
        v = v/norm(v);
        innerOpts.v0 = v;
        applyOP = @(x) applyOP(applyM(x));
        applyM = @(x) x;
        [V, d, isNotConverged, stopAlgorithm, VV] = KSnonherm(applyOP, applyM, n, k, ...
            innerOpts, randStr, shiftAndInvert);
    end
    
    if stopAlgorithm
        % Failure to build an orthogonal subspace
        error(message('MATLAB:eigs:NoOrthogonalSubspace'));
    end
end

if shiftAndInvert
    d = 1./d + innerOpts.sigma;
end

end

function [U, d, isNotConverged, stopAlgorithm] = KSherm(applyOP, applyM, n, k, ...
    innerOpts, randStr, shiftAndInvert)
% Applies Krylov Schur algorithm for Hermitian matrices (reference 1)

% Get previously set algorithm options
maxit = innerOpts.maxit;
tol = innerOpts.tol;
p = innerOpts.p;
method = innerOpts.method;

% Initialize variables
V = zeros(n, p);
v = innerOpts.v0;
stopAlgorithm = false;
k0 = k; % k0 is original k. (variable k will be adaptively increased)
Alpha = [];
Beta = [];
d = [];
c = [];
normRes = [];
justRestarted = false;
sizeV = 1;

% Do one step of power iteration
v = applyOP(applyM(v));

normv = sqrt(abs(v'*(applyM(v))));
v = v / normv;
normv = sqrt(abs(v'*(applyM(v))));
if ~(abs(normv - 1) < 1e-10)
    v = innerOpts.v0;
end


% Begin Main Algorithm
for mm=1:maxit
    
    % Build Krylov subspace in V, H:
    for jj = sizeV : p
        V(:,jj) = v;
        Mv = applyM(v);
        r = applyOP(Mv);
        alpha = real(Mv'*r); % to make sure H is Hermitian
        
        if jj == 1
            r = r - alpha*v;
        elseif justRestarted
            % Do r = r - V(:,1:jj)*V(:,1:jj)'*applyM(r)
            r = r - matlab.internal.math.projectInto(V, applyM(r), jj);
            justRestarted = false;
        else
            r = r - alpha*v - normRes*V(:, jj-1);
        end
        
        [r, normRes, stopAlgorithm] = robustReorthogonalize(V, r, applyM, jj, randStr);
        
        if stopAlgorithm
            U = [];
            d = [];
            isNotConverged = false(0,1);
            return;
        end
        
        % Save data
        v = r;
        Alpha = [Alpha, alpha]; %#ok<AGROW>
        Beta = [Beta, normRes];%#ok<AGROW>
    end
    
    % Build matrix H
    H1 = diag(Alpha) + diag(Beta(1:end-1), 1) + diag(Beta(1:end-1), -1);
    H = blkdiag(diag(d), H1);
    if ~isempty(d)
        H( 1:k , k+1 ) = c';
        H( k+1 , 1: k ) = c;
    end
    Alpha = [];
    Beta = [];
    
    % Check that values are finite (infs and NaNs rarely occur due to
    % random restarts)
    if ~all(isfinite(H(:))) || ~all(isfinite(V(:)))
        error(message('MATLAB:eigs:VeryBadCondition'))
    end
    
    % Compute eigenvalues
    [U, d] = eig(H, 'vector');
    
    % Implicitly calculate residuals
    res = abs(normRes * U(end, :));
    
    % Sort eigenvalues and residuals
    ind = whichEigenvalues(d, method);
    d = d(ind);
    res = res(ind);
    
    % Number of converged eigenpairs:
    isNotConverged = ~(res(1:k0)' < tol*max(eps^(2/3), abs(d(1:k0))));
    nconv = nnz(~isNotConverged);
    
    if innerOpts.disp
        minrelres = min(res(isNotConverged)' ./ max(eps^(2/3), ...
            abs(d(isNotConverged))));
        displayIteration(mm, maxit, nconv, k0, minrelres, tol);
    end
    
    if nconv >= k0 || mm == maxit
        % Stop the algorithm now
        break;
    else
        % Adjust k to prevent stagnating (see reference 2)
        k = k0 + min(nconv, floor((p - k0) / 2));
        if k == 1 && p > 3
            k = floor(p / 2);
        end
    end
    
    % Find k most desired eigenvalues of d
    ind = ind(1:k);
    U = U(:,ind);
    
    % Store variables for next iteration
    V(:,1:k) = V*U;
    d = d(1:k);
    c = normRes * U(end, :);
    justRestarted = true;
    sizeV = k + 1;
end

U = U(:, ind(1:k0));
d = d(1:k0);
isNotConverged = isNotConverged(1:k0);

if shiftAndInvert
    % Implicit extra step of power iteration (see reference 2)
    c = normRes * U(end, ~isNotConverged);
    U = V*U;
    UU = U(:,~isNotConverged).*d(~isNotConverged).' + v*c;
    % Renormalize
    UU = UU./ sqrt(abs( sum(conj(UU).* applyM(UU), 1) ));
    U(:, ~isNotConverged) = UU;
else
    U = V*U;
end

end

function [U, d, isNotConverged, stopAlgorithm, V] = KSnonherm(applyOP, applyM, n, k, ...
    innerOpts, randStr, shiftAndInvert)
% Applies Krylov Schur algorithm for non-Hermitian matrices (reference 1)

% Get previously set algorithm options
maxit = innerOpts.maxit;
tol = innerOpts.tol;
p = innerOpts.p;
method = innerOpts.method;

% Initialize variables
V = zeros(n, p);
v = innerOpts.v0;
stopAlgorithm = false;
k0 = k; % k0 is original k. (variable k will be adaptively increased)
H = [];
nconv = 0;
sizeV = 1;

% Do one step of power iteration
v = applyOP(applyM(v));
normv = sqrt(abs(v'*(applyM(v))));
v = v / normv;
normv = sqrt(abs(v'*(applyM(v))));
if ~(abs(normv - 1) < 1e-12)
    v = innerOpts.v0;
end

% Begin Main Algorithm
for mm = 1 : maxit
    
    % Build Krylov subspace in V, H:
    for jj = sizeV: p
        V(:, jj) = v;
        r = applyOP(applyM(v));
        
        [projr, w] = matlab.internal.math.projectInto(V, applyM(r), jj);
        r = r - projr;
        
        % Reorthogonalize
        [r, normRes, stopAlgorithm, w] = robustReorthogonalize(V, r, applyM, jj, randStr, w);
        
        if stopAlgorithm
            U = [];
            d = [];
            isNotConverged = false(0,1);
            return;
        end
        
        % Save data
        v = r;
        H = [H w; zeros(1, jj-1) normRes]; %#ok<AGROW>
    end
    
    % Should we expect conjugate pairs?
    isrealprob = isreal(H);
    
    % Check that values are finite (infs and NaNs rarely occur due to
    % random restarts)
    if ~all(isfinite(H(:))) || ~all(isfinite(V(:)))
        error(message('MATLAB:eigs:VeryBadCondition'))
    end
    
    % Returns 2x2 block form if H is real
    [X, T] = schur(H(1:end-1, :));
    
    % Compute eigenvalues
    [U, d] = eig(T, 'vector');
    U = X*U;
    
    % Implicitly calculate residuals
    res = abs(H(end, :) * U);
    
    % Sort eigenvalues and residuals
    ind = whichEigenvalues(d, method);
    d = d(ind);
    res = res(ind);
    
    % Number of converged eigenpairs:
    nconvold = nconv;
    isNotConverged = ~(res(1:k0)' < tol*max(eps^(2/3), abs(d(1:k0))));
    nconv = nnz(~isNotConverged);
    
    if innerOpts.disp
        minrelres = min(res(isNotConverged)' ./ max(eps^(2/3), ...
            abs(d(isNotConverged))));
        displayIteration(mm, maxit, nconv, k0, minrelres, tol);
    end
    
    if nconv >= k0 || mm == maxit
        % Stop the algorithm now
        break;
    else
        % Adjust k to prevent stagnating (see reference 2)
        k = k0 + min(nconv, floor((p - k0) / 2));
        if k == 1 && p > 3
            k = floor(p / 2);
        end
        % Lola's heuristic
        if  k + 1 < p && nconvold > nconv
            k = k + 1;
        end
    end
    
    % Get original ordering of eigenvalues back
    d = ordeig(T);
    
    % Choose desired eigenvalues in d to create a Boolean select vector
    ind = whichEigenvalues(d, method);
    ind = ind(1:k);
    select = false(1, p);
    select(ind) = true;
    
    % Make sure both parts of a conjugate pair are present
    if isrealprob
        for i = ind'
            if i < p && T(i+1,i) ~= 0 && ~select(i+1)
                select(i+1) = true;
                k = k+1;
            end
            if i > 1 && T(i, i-1) ~= 0 && ~select(i-1)
                select(i-1) = true;
                k = k+1;
            end
        end
    end
    
    % Reorder X and T based on select
    [X, T] = ordschur(X, T, select);
    
    % Store variables for next iteration
    H = [T(1:k, 1:k); H(end, :) * X(:, 1:k)];
    V(:,1:k) = V * X(:, 1:k);
    sizeV = k + 1;
end

U = U(:, ind(1:k0));
d = d(1:k0);

if shiftAndInvert
    % Implicit extra step of power iteration (see reference 2)
    c = normRes*U(end, ~isNotConverged);
    U = V*U;
    UU = U(:, ~isNotConverged) .* d(~isNotConverged).' + v*c;
    
    % Renormalize
    U(:, ~isNotConverged) = UU./ sqrt(abs( sum(conj(UU).* applyM(UU), 1) ));
else
    U = V*U;
end

end

function [r, normRes, stopAlgorithm, w] = robustReorthogonalize(V, r, ...
    applyM, index, randStr, wIn)

normr0 = sqrt(abs(r'*(applyM(r))));

if nargin < 6
    wIn = zeros(index,1);
end
w = wIn;

stopAlgorithm = false;
% Reorthogonalize:
[projr, dw] = matlab.internal.math.projectInto(V, applyM(r), index);
r = r - projr;
w = w + dw;
normRes = sqrt(abs(r'*(applyM(r))));

numReorths = 1;
while normRes <= (1/sqrt(2))*normr0 && numReorths < 5
    [projr, dw] = matlab.internal.math.projectInto(V, applyM(r), index);
    r = r - projr;
    w = w + dw;
    normr0 = normRes;
    normRes = sqrt(abs(r'*(applyM(r))));
    numReorths = numReorths + 1;
end

if normRes <= (1/sqrt(2))*normr0
    % Cannot Reorthogonalize, invariant subspace found.
    normRes = 0;
    w = wIn;
    
    % Try a random restart
    stopAlgorithm = true;
    
    for restart=1:3
        % Do a random restart: Will try at most three times
        r = randn(randStr, size(r,1), 1);
        
        % Orthogonalize r
        r = r - matlab.internal.math.projectInto(V, applyM(r), index);
        rMr = sqrt(abs(r'*applyM(r)));
        r = r / rMr;
        
        % Re-orthogonalize if necessary
        stopAlgorithm = true;
        for reorth=1:5
            
            % Check orthogonality
            Mr = applyM(r);
            [projr, VMr] = matlab.internal.math.projectInto(V, Mr, index);
            rMr = sqrt(abs(r'*Mr));
            
            if abs(rMr - 1) <= 1e-10 && all(abs(VMr) <= 1e-10)
                stopAlgorithm = false;
                break;
            end
            
            % Re-orthogonalize
            r = r - projr;
            r = r / sqrt(abs(r'*applyM(r)));
        end
        
        if ~stopAlgorithm
            break;
        end
    end
else
    r = r/normRes;
end
end

function [V, d, isNotConverged] = postProcessing(V, d, isNotConverged, eigsSigma, B, scaleB, shiftAndInvert, R, ...
    permB, spdB, nOutputs)

% Do some post-processing for generalized problem
if ~isempty(B)
    d = d./scaleB;
    if spdB && nOutputs >= 2
        
        if ~shiftAndInvert % Do R^(-1) v
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
        V = V / sqrt(scaleB);
    end
end

% Re-order eigenvalues to have ascending real part if sigma is 'bothendsreal'
if strcmp(eigsSigma, 'bothendsreal')
    [~, ind] = sort(real(d), 'ascend');
    d = d(ind);
    V = V(:, ind);
    isNotConverged = isNotConverged(ind);
end

end
