function z = cumtrapz(x,y,dim)
%CUMTRAPZ Cumulative trapezoidal numerical integration.
%   Z = CUMTRAPZ(Y) computes an approximation of the cumulative
%   integral of Y via the trapezoidal method (with unit spacing).  To
%   compute the integral for spacing different from one, multiply Z by
%   the spacing increment.
%
%   For vectors, CUMTRAPZ(Y) is a vector containing the cumulative
%   integral of Y. For matrices, CUMTRAPZ(Y) is a matrix the same size as
%   X with the cumulative integral over each column. For N-D arrays,
%   CUMTRAPZ(Y) works along the first non-singleton dimension.
%
%   Z = CUMTRAPZ(X,Y) computes the cumulative integral of Y with respect to
%   X using trapezoidal integration. X can be a scalar or a vector with the
%   same length as the first non-singleton dimension in Y. CUMTRAPZ
%   operates along this dimension. If X is a scalar, then CUMTRAPZ(X,Y) is
%   equivalent to X*CUMTRAPZ(Y).
%
%   Z = CUMTRAPZ(X,Y,DIM) or CUMTRAPZ(Y,DIM) integrates along dimension
%   DIM of Y. The length of X must be the same as size(Y,DIM)).
%
%   Example:
%       Y = [0 1 2; 3 4 5]
%       cumtrapz(Y,1)
%       cumtrapz(Y,2)
%
%   Class support for inputs X,Y:
%      float: double, single
%
%   See also TRAPZ, CUMSUM, INTEGRAL.

%   Copyright 1984-2017 The MathWorks, Inc. 

%   Make sure x and y are column vectors, or y is a matrix.

perm = []; nshifts = 0;
if nargin == 3 % cumtrapz(x,y,dim)
    if ~isscalar(dim) || ~isnumeric(dim) || (dim ~= floor(dim))
        error(message('MATLAB:getdimarg:dimensionMustBePositiveInteger'));
    end
    % Preserve existing errors for non-integer dim.
    dim = min(ndims(y)+1, dim);
    perm = [dim:max(length(size(y)),dim) 1:dim-1];
    y = permute(y,perm);
    [m,n] = size(y);
elseif nargin == 2 && isscalar(y) % cumtrapz(y,dim)
    dim = y;
    y = x;
    x = 1;
    if ~isnumeric(dim) || (dim ~= floor(dim))
        error(message('MATLAB:getdimarg:dimensionMustBePositiveInteger'));
    end
    % Preserve existing errors for non-integer dim.
    dim = min(ndims(y)+1, dim);
    perm = [dim:max(length(size(y)),dim) 1:dim-1];
    y = permute(y,perm);
    [m,n] = size(y);
else % cumtrapz(y) and cumtrapz(x, y)
    if nargin < 2
        y = x;
        x = 1;
    end
    [y,nshifts] = shiftdim(y);
    [m,n] = size(y);
end
if ~isvector(x)
    error(message('MATLAB:cumtrapz:xNotVector'));
end
% Make sure we have a column vector.
x = x(:);
if ~isscalar(x) && length(x) ~= m
    error(message('MATLAB:cumtrapz:LengthXMismatchY'));
end

if isempty(y)
    z = y;
elseif isscalar(x)
    z = [zeros(1,n,class(y)); x * cumsum((y(1:end-1,:) + y(2:end,:)),1)]/2;
else
    dt = diff(x,1,1)/2;
    z = [zeros(1,n,class(y)); cumsum(dt .* (y(1:end-1,:) + y(2:end,:)),1)];
end

siz = size(y);
z = reshape(z,[ones(1,nshifts),siz]);
if ~isempty(perm)
    z = ipermute(z,perm);
end
