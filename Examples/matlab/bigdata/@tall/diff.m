function Y = diff(X, n, dim)
%DIFF Difference and approximate derivative of a tall array.
%   DIFF(X,N,DIM)
%
%   Limitations:
%   The input arguments N and DIM must be specified.
%
%   See also DIFF, TALL.

%   Copyright 2016-2017 The MathWorks, Inc.

if nargin < 3
    error(message('MATLAB:bigdata:array:DiffOrderAndDimRequired'));
end

tall.checkIsTall(upper(mfilename), 1, X);
X = tall.validateType(X, mfilename, ...
    {'numeric', 'logical', 'datetime', 'duration'}, 1);
tall.checkNotTall(upper(mfilename), 1, n, dim);
tall.validateSyntax(@diff, {X, n, dim}, 'DefaultType', 'double');

if dim == 1
    Y = iTallDiff(X, n, dim);
else
    Y = iSmallDiff(X, n, dim);
end

% Reduce the output size in the diff dim by N
Y.Adaptor = reduceSizeInDimBy(X.Adaptor, dim, n);
Y = iSetDiffOutputType(Y, X.Adaptor.Class);
end

function Y = iTallDiff(X, n, dim)
% diff along tall dimension uses a backwards stencil operation
diffFcn = @(~, x) diff(x, n, dim);
window = [n 0];
Y = stencilfun(diffFcn, window, X);
end

function Y = iSmallDiff(X, n, dim)
% Diff along any small dimension gets computed slice-wise
Y = slicefun(@(x) diff(x, n, dim), X);
end

function output = iSetDiffOutputType(output, inputClass)
% For datetime or duration input, the output is always a duration
% Otherwise use the arithmetic rules for output type

if ismember(inputClass, {'datetime','duration'})
    outputType = 'duration';
else
    outputType = calculateArithmeticOutputType(inputClass, inputClass);
end

output = setKnownType(output, outputType);
end
