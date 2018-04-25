function t = toeplitz(c,r)
%TOEPLITZ Toeplitz matrix.
%   TOEPLITZ(C,R) is a non-symmetric Toeplitz matrix having C as its
%   first column and R as its first row.
%
%   TOEPLITZ(R) is a symmetric Toeplitz matrix for real R.
%   For a complex vector R with a real first element, T = toeplitz(r)
%   returns the Hermitian Toeplitz matrix formed from R. When the
%   first element of R is not real, the resulting matrix is Hermitian
%   off the main diagonal, i.e., T_{i,j} = conj(T_{j,i}) for i ~= j.
%
%   Class support for inputs C,R:
%      float: double, single
%      integer: uint8, int8, uint16, int16, uint32, int32, uint64, int64
%
%   See also HANKEL.

%   Thanks to A.K. Booer for the original version.
%   Copyright 1984-2017 The MathWorks, Inc.

if ~(isnumeric(c) && (nargin < 2 || isnumeric(r)))
    error(message('MATLAB:toeplitz:nonNumericInputs'));
end

if nargin < 2
    c(1) = conj(c(1));                    % set up for Hermitian Toeplitz
    r = c;
    c = conj(c);
else
    if ~isempty(c) && ~isempty(r) && ~isequaln(r(1),c(1))
        warning(message('MATLAB:toeplitz:DiagonalConflict'))
    end
end

r = r(:);                               % force column structure
c = c(:);
p = length(r);
m = length(c);
x = [r(p:-1:2, 1) ; c];                 % build vector of user data
ij = (0:m-1)' + (p:-1:1);               % Toeplitz subscripts
t = x(ij);                              % actual data
if isrow(ij) && ~isempty(t)             % preserve shape for a single row
    t = t.';
end

