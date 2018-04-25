function tX = validateVectorOrEmpty(tX, varargin)
%validateVectorOrEmpty Possibly deferred check for vector or empty attribute
%   TX = validateVectorOrEmpty(TX,ERRID,ERRARG1,ERRARG2,..)
%   validates that TX is a vector. If TX is not a vector and not empty, an
%   error of the given message ID will be issued. This requires a full pass
%   of TX.

% Copyright 2017 The MathWorks, Inc.

% This prevents this frame and anything below it being added to the gather
% error stack.
frameMarker = matlab.bigdata.internal.InternalStackFrame(); %#ok<NASGU>

narginchk(2, inf);
assert(~any(cellfun(@istall, varargin)), ...
    'Assertion failed: validateVectorOrEmpty expects error message inputs to not be tall.');
assert(nargout >= 1, 'Assertion failed: validateVectorOrEmpty expects output to be captured.');

try
    adaptor = matlab.bigdata.internal.adaptors.getAdaptor(tX);
    if ~istall(tX)
        adaptor = setTallSize(adaptor, size(tX, 1));
    end
    if adaptor.isKnownNotVector() && adaptor.isKnownNotEmpty()
         error(message(varargin{:}));
    end
    if adaptor.isKnownVector() || adaptor.isKnownEmpty()
        return;
    end
    
    % Must be a tall array to reach here.
    errArgs = varargin;
    tSz = partitionfun(@(info, x) iValidatePartition(info, x, errArgs), tX);
    tSz = reducefun(@(sz) iValidateBetweenPartition(sz, errArgs), tSz);
    % The framework will assume tSz is partition dependent because it is
    % derived from partitionfun. It is not, so we must correct this.
    tSz = copyPartitionIndependence(tSz, tX);
    tX = slicefun(@(x, ~) x, tX, tSz);
catch err
    throwAsCaller(err);
end

function [isFinished, sz] = iValidatePartition(info, x, errArgs)
% Validate that a partition is a row or column or empty. The output is the
% size of the partition if it is a row or empty. This will also exit early
% if the array is a column or empty in a small dim.
isFinished = info.IsLastChunk;
sz = size(x);
if iscolumn(x) || any(sz(2 : end) == 0)
    isFinished = true;
    return;
end

if ~ismatrix(x) || sz(1) + info.RelativeIndexInPartition - 1 > 1
    error(message(errArgs{:}));
end

function sz = iValidateBetweenPartition(sz, errArgs)
% Validate that the size between partitions indicate a row or column or
% empty. Empties include N-D empties.
sz = [sum(sz(:, 1)), sz(1, 2 : end)];
if (numel(sz) == 2 && sz(2) == 1) || any(sz(2 : end) == 0)
    return;
end

if (sz(1) > 1)
    error(message(errArgs{:}));
end
