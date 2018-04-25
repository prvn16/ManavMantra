function [X, arg2, condX] = sqrtm(A)
%SQRTM     Matrix square root.
%   X = SQRTM(A) is the principal square root of the square matrix A. 
%   That is, X*X = A.
%          
%   X is the unique square root for which every eigenvalue has nonnegative
%   real part.  If A has any real, negative eigenvalues then a complex
%   result is produced.  If A is singular then A may not have a
%   square root.  A warning is printed if exact singularity is detected.
%          
%   [X, RESNORM] = SQRTM(A) does not print any warning, and returns the
%   residual, norm(A-X^2,1)/norm(A,1).
%
%   [X, ALPHA, CONDX] = SQRTM(A) returns a stability factor ALPHA and an
%   estimate CONDX of the matrix square root condition number of X, in
%   the 1-norm. The residual norm(A-X^2,1)/norm(A,1) is bounded
%   approximately by N*ALPHA*EPS and the 1-norm relative error in X is
%   bounded approximately by N*ALPHA*CONDX*EPS, where N is the size of
%   the matrix.
%
%   See also EXPM, LOGM, FUNM.

%   References:
%   N. J. Higham, Computing real square roots of a real
%       matrix, Linear Algebra and Appl., 88/89 (1987), pp. 405-430.
%   A. Bjorck and S. Hammarling, A Schur method for the square root of a
%       matrix, Linear Algebra and Appl., 52/53 (1983), pp. 127-140.
%   E. Deadman, N. J. Higham and R. Ralha, Blocked Schur algorithms for
%       computing the matrix square root, Lecture Notes in Comput. Sci.
%       7782, Springer-Verlag, (2013), pp. 171-182.
%
%   Nicholas J. Higham and Samuel D. Relton
%   Copyright 1984-2015 The MathWorks, Inc.

validateattributes(A, {'double','single'}, {'finite', 'square'});
schurInput = matlab.internal.math.isschur(A);  % Check for basic Schur form.
if schurInput
    T = A;
else
    [Q, T] = schur(A);
end
n = size(A,1);

% Compute square root.
if isdiag(T)
    diagT = diag(T);
    nzeig = any(diagT == 0);  % Check for singularity.
    
    % Compute square root.
    if schurInput
        R = diag(sqrt(diagT));
        X = R;
    else
        R = sqrt(diagT);
        X = (Q.*R.')*Q';
        if isreal(R)
            X = (X+X')/2;
        end
        if nargout > 2
            R = diag(R);
        end
    end
    info = 0;
else
    % Check for negative real evals.
    ei = ordeig(T);
    if isreal(T)
        if any( real(ei) < 0 & imag(ei) == 0 )
            if schurInput
                % Output will be complex so change to complex Schur form.
                Q = eye(n, class(T));
                schurInput = false; % Need to undo rsf2csf at end.
            end
            [Q, T] = rsf2csf(Q, T);
        end
    end
    nzeig = any(ei == 0);  % Check for singularity.
    
    % Compute square root of (quasi-)triangular T.
    [R, info] = sqrtm_tri(T);
    
    % Undo Schur decomposition.
    if ~schurInput
        X = Q*R*Q';
    else
        X = R;
    end
end

if nargout ~= 2
    if nzeig
        warning(message('MATLAB:sqrtm:SingularMatrix'))
    elseif info ~= 0
        warning(message('MATLAB:sqrtm:IllConditionedSylvester'));
    end
end

% Compute residual and condition number.
if nargout == 2
    % Compute residual.
    arg2 = norm(X*X-A,1)./norm(A,1);
end
    
if nargout == 3
    % Compute stability factor.
    arg2 = norm(X,1)^2./norm(A,1);
    
    if nzeig
        condX = inf(class(A));
    else
        % Estimate 1-norm of Kronecker form to get condition number.
        if schurInput
            % If Q not needed above then just use Q = 1.
            Q = 1;
        end
        cn = normest1(@(x, y) sqrtm_derivative(x, y, R, Q));
        condX = cn.*norm(A,1)./norm(X,1);
    end
    
end
end % End of sqrtm

% Subfunctions
function out = sqrtm_derivative(flag, vecE, R, Q)
%SQRTM_DERIVATIVE Computes derivative in direction E for use with normest1.
n = size(R,1);

% Return queries from normest1.
if strcmp(flag, 'real')
    out = isreal(R);
    return;
elseif strcmp(flag, 'dim')
    out = n^2;
    return;
end

t = size(vecE, 2);
% Compute derivatives.
out = zeros(n^2, t, class(R));
for k = 1:t
    E = zeros(n, class(R));
    E(:) = vecE(:, k);
    if strcmp(flag, 'notransp')
        % Compute derivative.
        L = Q*sylvester_tri(R, R, Q'*E*Q)*Q';
        out(:, k) = L(:);
    else
        % Take transpose into account.
        L = Q*sylvester_tri(R, R, Q'*E'*Q)'*Q';
        out(:, k) = L(:);
    end
end % End of for loop
end % End of sqrtm_derivative
