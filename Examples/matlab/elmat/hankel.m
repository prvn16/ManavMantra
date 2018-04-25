function H = hankel(c,r)
%HANKEL Hankel matrix.
%   HANKEL(C) is a square Hankel matrix whose first column is C and
%   whose elements are zero below the first anti-diagonal.
%
%   HANKEL(C,R) is a Hankel matrix whose first column is C and whose
%   last row is R.
%
%   Hankel matrices are symmetric, constant across the anti-diagonals,
%   and have elements H(i,j) = P(i+j-1) where P = [C R(2:END)]
%   completely determines the Hankel matrix.
%
%   Class support for inputs C,R:
%      float: double, single
%      integer: int8, int16, int32, int64, uint8, uint16, uint32, uint64
%
%   See also TOEPLITZ.

%   Copyright 1984-2017 The MathWorks, Inc.

c = c(:);
nc = length(c);

if nargin < 2
    r = zeros(size(c), 'like', c);    % will need zeros below main diagonal
elseif ~isempty(c) && ~isempty(r) && c(nc) ~= r(1)
    warning(message('MATLAB:hankel:AntiDiagonalConflict'))
end

r = r(:);                            % force column structure
nr = length(r);

x = [ c; r(2:nr, 1) ];               % build vector of user data

ij = (1:nc)' + (0:(nr-1));           % Hankel subscripts
H = x(ij);                           % actual data
if isrow(ij) && ~isempty(H)          % preserve shape for a single row
    H = H.';
end

