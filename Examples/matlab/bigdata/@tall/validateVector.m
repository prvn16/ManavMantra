function tX = validateVector(tX, varargin)
%validateVector Possibly deferred check for vector attribute
%   TX = validateVector(TX,ERRID,ERRARG1,ERRARG2,..)
%   validates that TX is a vector. If TX is not a vector, an error of the
%   given message ID will be issued. This requires a full pass of TX.

% Copyright 2017 The MathWorks, Inc.

% This prevents this frame and anything below it being added to the gather
% error stack.
frameMarker = matlab.bigdata.internal.InternalStackFrame(); %#ok<NASGU>

narginchk(2, inf);
assert(~any(cellfun(@istall, varargin)), ...
    'Assertion failed: validateVector expects error message inputs to not be tall.');
assert(nargout >= 1, 'Assertion failed: validateVector expects output to be captured.');

try
    adaptor = matlab.bigdata.internal.adaptors.getAdaptor(tX);
    if ~istall(tX)
        adaptor = setTallSize(adaptor, size(tX, 1));
    end
    if adaptor.isKnownNotVector()
         error(message(varargin{:}));
    end
    if adaptor.isKnownVector()
        return;
    end
    if adaptor.isTallSizeGuaranteedNonUnity()
        % Can optimize the check because this tall array cannot be a row.
        tX = tall.validateColumn(tX, varargin{:});
        return;
    end

    % Must be a tall array to reach here.
    errArgs = varargin;
    tSz = partitionfun(@(info, x) iValidatePartition(info, x, errArgs), tX);
    tSz = reducefun(@(sz) iValidateBetweenPartition(sz, errArgs, true), tSz);
    tSz = clientfun(@(sz) iValidateBetweenPartition(sz, errArgs, false), tSz);
    % The framework will assume tSz is partition dependent because it is
    % derived from partitionfun. It is not, so we must correct this.
    tSz = copyPartitionIndependence(tSz, tX);
    tX = slicefun(@(x, ~) x, tX, tSz);
    if isnan(adaptor.NDims)
        tX.Adaptor = setSmallSizes(adaptor, NaN);
    end
catch err
    throwAsCaller(err);
end

function [isFinished, sz] = iValidatePartition(info, x, errArgs)
% Validate that a partition is a row or column. The output is the size of
% the partition if it is a row or empty. This will also exit early if the
% array is a column.
sz = size(x);
if iscolumn(x)
    isFinished = true;
    return;
end

isFinished = info.IsLastChunk;
if ~ismatrix(x) || sz(1) + info.RelativeIndexInPartition - 1 > 1
    error(message(errArgs{:}));
end

function sz = iValidateBetweenPartition(sz, errArgs, allowEmpty)
% Validate that the size between partitions indicate a row or column.
sz = [sum(sz(:, 1)), sz(1, 2)];
if sz(2) == 1
    return;
end

if (sz(1) > 1) || (~allowEmpty && (sz(1) == 0))
    error(message(errArgs{:}));
end
