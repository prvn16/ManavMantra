function tX = validateNumColumns(tX, N, varargin)
%validateNumColumns Possibly deferred check for number of columns equal to N.
%   TX1 = validateNumColumns(TX,N,ERRID,ERRARG1,ERRARG2,..)
%   validates that TX has N columns. If TX is not a does not have N columns,
%   an error of the given message ID will be issued.

% Copyright 2017 The MathWorks, Inc.

% This prevents this frame and anything below it being added to the gather
% error stack.
frameMarker = matlab.bigdata.internal.InternalStackFrame(); %#ok<NASGU>

narginchk(3, inf);
nargoutchk(1, 1);
assert(~any(cellfun(@istall, varargin)), ...
    'Assertion failed: validateNumColumns expects error message inputs to not be tall.');

try
    if istall(N)
        [isGathered, gatheredN] = matlab.bigdata.internal.util.isGathered(N);
        if isGathered
            N = gatheredN;
        end
    end
    N = tall.validateScalar(N, 'MATLAB:bigdata:array:ValidateNumColumnsBadN');
    
    adaptor = matlab.bigdata.internal.adaptors.getAdaptor(tX);
    if ~istall(N)
        if ~isnan(adaptor.NDims) && ~any(isnan(adaptor.SmallSizes))
            numColumns = prod(adaptor.SmallSizes);
            if numColumns ~= N
                error(message(varargin{:}));
            end
            return;
        end
    end
    
    errorArgs = varargin;
    tX = slicefun(@(x, n) iCheckNumColumns(x, n, errorArgs), tX, N);
    tX.Adaptor = adaptor;
catch err
    throwAsCaller(err);
end

function x = iCheckNumColumns(x, expectedN, errorArgs)
% Check that x has the expected number of columns.
sz = size(x);
actualN = prod(sz(2 : end));
if ~isequal(actualN, expectedN)
    error(message(errorArgs{:}));
end
