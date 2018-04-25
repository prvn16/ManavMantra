function x = lsqminnorm(A, b, varargin)
%LSQMINNORM Minimum-norm solution of least-square system
%    X = LSQMINNORM(A, B) returns a vector X that minimizes norm(A*X - B).
%    If there are many solutions X to this problem, then the solution with
%    minimal norm(X) is returned.
%
%    X = LSQMINNORM(A, B, TOL) additionally specifies the tolerance, which
%    is used to determine the rank of A. By default, TOL is computed based
%    on the QR decomposition of A.
%
%    LSQMINNORM(A, B, TOL) is a possible alternative to PINV(A, TOL) * B.
%    It is supported for sparse matrices, and is typically more efficient.
%    The two functions are not exactly equivalent, since LSQMINNORM uses
%    the Complete Orthogonal Decomposition (COD) to find a low-rank
%    approximation of A, while PINV uses the Singular Value Decomposition
%    (SVD).
%
%    X = LSQMINNORM(..., RANKWARN) specifies whether LSQMINNORM should
%    produce a warning when the matrix A is detected to be of low rank.
%    RANKWARN can be:
%        'nowarn' - (default) No warning is given if A has low rank.
%          'warn' - A warning is given if A has low rank.
%
%    See also: PINV, DECOMPOSITION

%   Copyright 2017 The MathWorks, Inc.

narginchk(2, 4);

tol = -2; % this signals to internal classes to use default tolerance
checkCondition = false;

if ~isfloat(A) || ~ismatrix(A)
    error(message('MATLAB:decomposition:InvalidA'));
end

if ~isfloat(b) || ~ismatrix(b)
    error(message('MATLAB:decomposition:InvalidB'));
end

if nargin > 2
    offset = 1;
    if isnumeric(varargin{offset})
        tol = varargin{1};
        validateattributes(tol, {'double'}, {'scalar', 'real', 'nonnegative', 'nonnan'});
        offset = offset+1;
    end
    setWarn = false;
    
    for ii=offset:length(varargin)
        
        name = validatestring(varargin{ii}, {'warn', 'nowarn'});
        if ~setWarn
            if strcmp(name, 'warn')
                checkCondition = true;
            else
                checkCondition = false;
            end
            setWarn = true;
        else
            error('MATLAB:lsqminnorm:InvalidSol', 'Invalid option combination. Can only set one of ''warn'', ''nowarn''.');
        end
    end
end

castBack = @(x) x;
if isa(A, 'single') ~= isa(b, 'single')
    if issparse(A) || issparse(b)
        error(message('MATLAB:mldivide:sparseSingleNotSupported'));
    end
    if isa(b, 'single')
        % Note: A\b would cast matrix A to single - but here the decomposition
        % is already done in double, so return x = single( dA\double(b) ) instead.
        b = double(b);
        castBack = @single;
    else
        b = single(b);
    end
end

if ~issparse(A) && issparse(b)
    b = full(b);
end

if size(b, 1) ~= size(A, 1)
    error(message('MATLAB:decomposition:mldivide'));
end

if ~issparse(A) || size(A, 1) < size(A, 2)
    if issparse(A)
        dA = matlab.internal.decomposition.SparseCOD(A, tol, true);
    else
        dA = matlab.internal.decomposition.DenseCOD(A, tol);
    end
    
    x = solve(dA, b, false);
    
    if checkCondition && dA.rank_ < min(size(A))
        warning(message('MATLAB:rankDeficientMatrix',sprintf('%d',dA.rank_),sprintf('%13.6e',dA.ranktol_)));
    end

else % issparse(A) && size(A, 1) >= size(A, 2)
    % More efficient variant without using internal decomposition objects
    % This avoids having to store the Householder vectors even implicitly
    
    [m, n] = size(A);
    
    [R, colperm1, QTb, rank_, ranktol_] = ...
            matlab.internal.math.sparseQRnoQ(A, true, tol, b);
        
    if rank_ == min(m, n)
        x = QTb(1:rank_, :);
        
        % x2 = R(1:rank_, 1:rank_) \ x;
        x2 = matlab.internal.decomposition.builtin.sparseTriangSolve(R(1:rank_,1:rank_), x, 'upper', false);
        
        x = zeros(n, size(b, 2), 'like', b);
        
        x(colperm1, :) = x2;
        
    else
        
        if checkCondition
            warning(message('MATLAB:rankDeficientMatrix',sprintf('%d',rank_),sprintf('%13.6e',ranktol_)));
        end
        
        M = R;
        M(rank_+1:end, :) = [];
        
        [H2, tau2, rowperm2, R, colperm2] = ...
            matlab.internal.math.implicitSparseQR(M', true, 0);
        
        rowperm2(colperm1) = rowperm2;
        
        x = QTb(colperm2, :);
        
        %x2 = R' \ x;
        x2 = matlab.internal.decomposition.builtin.sparseTriangSolve(R, x, 'upper', true);
                
        x = zeros(n, size(b, 2), 'like', b);
        
        x(1:rank_, :) = x2;
        
        if rank_ < min(m, n)
            import matlab.internal.math.applyHouseholder;
            
            if isreal(H2) && isreal(tau2) && ~isreal(x)
                % Real Q applied to complex x not supported in built-in
                x = applyHouseholder(H2, tau2, rowperm2, real(x), false) + ...
                    1i*applyHouseholder(H2, tau2, rowperm2, imag(x), false);
            else
                x = applyHouseholder(H2, tau2, rowperm2, x, false);
            end
        end
    end
end

x = castBack(x);
