function b = circshift(a,p,dim)
%CIRCSHIFT Shift positions of elements circularly.
%   Y = CIRCSHIFT(X,K) where K is an integer scalar circularly shifts 
%   the elements in the array X by K positions. If X is a vector and K is
%   positive, then the values of X are circularly shifted from the beginning 
%   to the end. If K is negative, they are shifted from the end to the 
%   beginning. If X is a matrix, CIRCSHIFT shifts along columns. If X is an
%   N-D array, CIRCSHIFT shifts along the first nonsingleton dimension.
%   
%   Y = CIRCSHIFT(X,K,DIM) circularly shifts along the dimension DIM.
%
%   Y = CIRCSHIFT(X,V) circularly shifts the values in the array X
%   by V elements. V is a vector of integers where the N-th element 
%   specifies the shift amount along the N-th dimension of
%   array X. 
%
%   Examples:
%      A = [ 1 2 3;4 5 6; 7 8 9];
%      B = circshift(A,1) % circularly shifts first dimension values down by 1.
%      B =     7     8     9
%              1     2     3
%              4     5     6
%      B = circshift(A,[1 -1]) % circularly shifts first dimension values
%                              % down by 1 and second dimension left by 1.
%      B =     8     9     7
%              2     3     1
%              5     6     4
%
%   See also FFTSHIFT, SHIFTDIM, PERMUTE.

%   Copyright 1984-2015 The MathWorks, Inc.

if nargin < 2
    error(message('MATLAB:minrhs'));
end

% check for improper DIM input
if nargin > 2
    if ~(isscalar(p) && isscalar(dim))
        error(message('MATLAB:circshift:NonScalarDim'));
    elseif ~(isnumeric(dim) && isreal(dim) && isfinite(dim) ...
            && isequal(round(dim),dim) && dim>0)
        error(message('MATLAB:getdimarg:dimensionMustBePositiveInteger'));
    end
elseif isscalar(p)
    % first singleton dimension
    dim = find(size(a)~=1,1);
    if isempty(dim)
        dim = ndims(a);
    end
else
    dim = 1;
end

% Check for improper SHIFTSIZE input
if ~(isvector(p) && isnumeric(p) && isreal(p) && all(isfinite(p(:))) ...
        && isequal(round(p),p)) || isempty(p)
    error(message('MATLAB:circshift:InvalidShiftType'));
end

numDimsA = ndims(a);
p = [zeros(1,dim-1,'like',p) p];

% Make sure the shift vector has the same length as numDimsA.
% The missing shift values are assumed to be 0. The extra
% shift values are ignored when the shift vector is longer
% than numDimsA.
if (numel(p) < numDimsA)
    p(numDimsA) = 0;
end

% Calculate the indices that will convert the input matrix to the desired output
% Initialize the cell array of indices
idx = cell(1, numDimsA);

% Loop through each dimension of the input matrix to calculate shifted indices
for k = 1:numDimsA
    if p(k) == 0
        idx{k} = ':';
    else
        m      = size(a,k);
        idx{k} = mod((0:m-1)-double(rem(p(k),m)), m)+1;
    end
end

% Perform the actual conversion by indexing into the input matrix
b = a(idx{:});
