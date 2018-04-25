function X = sylvester(A, B, C)
%SYLVESTER Solve Sylvester Equations.
%   X = SYLVESTER(A,B,C) solves the Sylvester equation A*X + X*B = C,
%   where A is a m-by-m matrix, B is a n-by-n matrix, and X and C are
%   m-by-n matrices.

%   Copyright 2013-2015 The MathWorks, Inc.

parse_inputs(A, B, C);   %check inputs

% Reduce equation to triangular form
flag = 'real';
if ~isreal(A) || ~isreal(B) || ~isreal(C)
    flag = 'complex'; % Need complex Schur form
end

CC = C;
schurA = matlab.internal.math.isschur(A,flag);
if schurA
    TA = A;
else
    [QA, TA] = schur(A, flag);
    CC = QA'*CC;
end
schurB = matlab.internal.math.isschur(B,flag);
if schurB
    TB = B;
else
    [QB, TB] = schur(B, flag);
    CC = CC*QB;
end

% Solve Sylvester Equation TA*X + X*TB = QA'*C*QB.
[X, info] = sylvester_tri(TA, TB, CC);
if info == 1
    error(message('MATLAB:sylvester:solutionNotUnique'))
end

% Recover X
if ~schurA
    X = QA*X;
end
if ~schurB
    X = X*QB';
end

function parse_inputs(A, B, C)
% Check inputs
if ~isfloat(A) || ~isfloat(B) || ~isfloat(C)
    error(message('MATLAB:sylvester:inputType'))
end
if ~ismatrix(A) || ~ismatrix(B) || ~ismatrix(C)
    error(message('MATLAB:sylvester:inputMustBe2D'))
end
if issparse(A) || issparse(B) || issparse(C)
    error(message('MATLAB:sylvester:inputMustBeFull'))
end
if size(A,1) ~= size(A,2) || size(B,1) ~= size(B,2)
    error(message('MATLAB:sylvester:inputMustBeSquare'))
end
if size(A,1) ~= size(C,1) || size(B,1) ~= size(C,2)
    error(message('MATLAB:sylvester:inputMustBeCompatibleSize'));
end
if ~all(isfinite(A(:))) || ~all(isfinite(B(:)))
    error(message('MATLAB:sylvester:inputWithNaNInf'));
end
