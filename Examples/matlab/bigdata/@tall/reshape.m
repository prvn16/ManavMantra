function Y = reshape(X,tallSize,varargin)
%RESHAPE Reshape array.
%   Y = RESHAPE(X,[],M,N,...) returns an N-D array with the same elements
%   as X but reshaped to have the size M-by-N-by-P-by-.... The first
%   dimension input must always be empty since the tall dimension cannot be
%   reshaped.
%
%   See also tall/PERMUTE.

% Copyright 2015-2016 The MathWorks, Inc.

% Using a dimension vector or specifying the tall dimension are both
% unsupported
if nargin == 2
    error(message('MATLAB:bigdata:array:ReshapeDimVector'));
elseif ~isempty(tallSize)
    error(message('MATLAB:bigdata:array:ReshapeTallDim'));
end

X = tall.validateType(X, mfilename, {'~table', '~timetable'}, 1);

% Also check the dimensions now so that we don't waste time finding
% problems during evaluation.
if any(~cellfun(@isRealIntScalar, varargin))
    error(message('MATLAB:getReshapeDims:notRealInt'));
end

% Must treat the size as double so that we can concatenate with NaN without it
% decaying to zero.
newSliceSize = cellfun(@double, varargin);
% Do it!
Y = slicefun(@(z) iReshape(z, newSliceSize), X);

% Carefully construct a new adaptor based on the original by first resetting the
% size, and then copying across the required size information.
adaptor   = resetSizeInformation(X.Adaptor);
adaptor   = copyTallSize(adaptor, X.Adaptor);
Y.Adaptor = setSmallSizes(adaptor, newSliceSize);
end


function out = iReshape(in, newSliceSize)
% Helper function to check the dimensions and throw the right error if
% there is a dimension mismatch.
oldSliceSize = size(in);
oldSliceSize(1) = [];
if prod(oldSliceSize) ~= prod(newSliceSize)
    error(message('MATLAB:bigdata:array:ReshapeNotSameNumel', ...
        prod(newSliceSize), prod(oldSliceSize)));
end

% Call reshape on the local part, ignoring the tall dimension
tmp = num2cell(newSliceSize);
out = reshape(in, [], tmp{:});
end


function tf = isRealIntScalar(x)
% Check for a real integer-valued positive scalar
tf = isnumeric(x) && isscalar(x) && isreal(x) && mod(x,1)==0 && x>0;
end
