function y = flip(x,dim)
%FLIP Flip the order of elements
%   Y = FLIP(X)
%   Y = FLIP(X,DIM)
%
%   Limitations:
%   DIM must be greater than one.
%
%   See also FLIP, TALL.

%   Copyright 2017 The MathWorks, Inc.

% If no dimension was specified, try to deduce it
if nargin<2
    useSecondDimForScalar = true;
    dim = matlab.bigdata.internal.util.deduceReductionDimension(x.Adaptor, useSecondDimForScalar);
else
    % User-supplied dimension. Make sure it is valid by calling built-in
    % FLIP on a double scalar.
    tall.checkNotTall(upper(mfilename), 1, dim); % DIM cannot be tall
    try
        flip(1,dim);
    catch err
        rethrow(err);
    end
end

if isempty(dim)
    % Failed to deduce, so determine if size(x,1)==1 lazily
    isUnitHeight = iLazyIsUnitHeight(x);
    % Force a single row so that the subsequent elementfun doesn't throw an
    % incompatible dimensions error when combining x with isUnitHeight.
    % This will usually be fused with the reduction used to calculate the
    % size.
    x = head(x,1);
    % Insert the error flag into the op-tree
    y = slicefun(@iCheckAndFlip, isUnitHeight, x);
    
elseif dim==1
    % Trying to flip the tall dimension is not allowed
    error(message('MATLAB:bigdata:array:FlipTallDim'));
    
else
    y = slicefun(@flip, x, dim);
    
end

% Output is always same size and type as the input
y.Adaptor = x.Adaptor;

end


function tf = iLazyIsUnitHeight(X)
% Lazily determine whether X is size 1 in dim 1
tf = clientfun(@(x) isequal(1, x), size(X,1));
tf.Adaptor = matlab.bigdata.internal.adaptors.getScalarLogicalAdaptor();
end

function x = iCheckAndFlip(isUnitHeight, x)
% Flip the data along a small dim if unit height, otherwise error
if isUnitHeight
    x = flip(x); % guaranteed to be along a small dimension
else
    error(message('MATLAB:bigdata:array:FlipTallDim'));
end
end
