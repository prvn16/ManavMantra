%REPELEM Replicate elements of an array.
%   U = REPELEM(V,N), where V is a vector, returns a vector of repeated
%   elements of V.
%   - If N is a scalar, each element of V is repeated N times.
%   - If N is a vector, element V(i) is repeated N(i) times. N must be the
%     same length as V.
%
%   B = repelem(A, R1, ..., RN), returns an array with each element of A
%   repeated according to R1, ..., RN. Each R1, ..., RN must either be a
%   scalar or a vector with the same length as A in the corresponding
%   dimension.
%
%   Example: If A = [1 2; 3 4], then repelem(A, 2, 3) returns a matrix 
%   containing a 2-by-3 block of each element of A:
%   [1 1 1 2 2 2; ...
%    1 1 1 2 2 2; ...
%    3 3 3 4 4 4; ...
%    3 3 3 4 4 4].
%
%   See also REPMAT, BSXFUN, MESHGRID.

%   Copyright 1984-2014 The MathWorks, Inc.
