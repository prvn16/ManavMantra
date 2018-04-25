function Y = caldiff(X, components, dim)
%CALDIFF Successive differences between datetimes as calendar durations.
%   D = CALDIFF(X,COMPONENTS,DIM)
%
%   Limitations:
%   The input argument DIM must be specified. Use CALDIFF(X,'',DIM) to get
%   the default components.
%
%   See also CALDIFF, TALL.

%   Copyright 2017 The MathWorks, Inc.

if nargin < 3
    error(message('MATLAB:bigdata:array:CaldiffDimRequired'));
end

tall.checkIsTall(upper(mfilename), 1, X);
tall.checkNotTall(upper(mfilename), 1, components, dim);
X = tall.validateType(X, mfilename, {'datetime'}, 1);

tall.validateSyntax(@caldiff,{X, components, dim},'DefaultType', 'datetime');

if dim == 1
    Y = iTallDiff(X, components, dim);
else
    Y = iSmallDiff(X, components, dim);
end

% Reduce the output size in the diff dim by N
Y.Adaptor = reduceSizeInDimBy(X.Adaptor, dim, 1);
Y = setKnownType(Y, 'calendarDuration');
end

function Y = iTallDiff(X, components, dim)
% Caldiff along tall dimension uses a backwards stencil operation
diffFcn = @(~, x) iCalDiffChunk(x, components, dim);
window = [1 0];
Y = stencilfun(diffFcn, window, X);
end

function Y = iCalDiffChunk(X, components, dim)
% Differentiate one chunk. We have to wrap the underlying function as it
% has a bug when presented with >2D arrays that are empty in the diff
% dimension (it throws an unexpected error).
if ~ismatrix(X) && size(X,1)==0
    % Call caldiff on a 2D version to get the correct format etc., then
    % reshape back.
    Y = caldiff(X(:,:), components, dim);
    Y = reshape(Y, size(X));
else
    Y = caldiff(X, components, dim);
end
end

function Y = iSmallDiff(X, components, dim)
% Caldiff along any small dimension gets computed slice-wise
Y = slicefun(@(x) caldiff(x, components, dim), X);
end
