function y = flipdim(x,dim)
%FLIPDIM Flip matrix along specified dimension.
%   FLIPDIM is not recommended. Use FLIP instead.
%
%   FLIPDIM(X,DIM) returns X with dimension DIM flipped.  
%   For example, FLIPDIM(X,1) where
%   
%       X = 1 4  produces  3 6
%           2 5            2 5
%           3 6            1 4
%
%
%   Class support for input X:
%      float: double, single
%
%   See also FLIP, FLIPLR, FLIPUD, ROT90, PERMUTE.

%   Copyright 1984-2015 The MathWorks, Inc.

% Argument parsing
if (nargin ~= 2)
    error(message('MATLAB:flipdim:nargin'));
end
dim = floor(dim);
if (dim <= 0) 
    error(message('MATLAB:flipdim:DimNotPos'));
end

dimsize = size(x,dim);
if (dimsize <= 1)
    % No-op.
    y = x;
else
    % Create the index that will transform x.
    v(1:ndims(x)) = {':'};
    % Flip dimension dim.
    v{dim} = dimsize:-1:1;
    % Index with v.
    y = x(v{:});
end
