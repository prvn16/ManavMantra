function tX = validateRow(tX, varargin)
%validateType Possibly deferred check for row attribute
%   TX = validateRow(TX,ERRID,ERRARG1,ERRARG2,..)
%   validates that TX is a row. If TX is not a row, an error of the
%   given message ID will be issued.
%
% The output TX can be used in a height singleton expanded operation, even
% if the input could not.

% Copyright 2017 The MathWorks, Inc.

% This prevents this frame and anything below it being added to the gather
% error stack.
frameMarker = matlab.bigdata.internal.InternalStackFrame(); %#ok<NASGU>

narginchk(2, inf);
assert(~any(cellfun(@istall, varargin)), ...
    'Assertion failed: validateRow expects error message inputs to not be tall.');
assert(nargout >= 1, 'Assertion failed: validateRow expects output to be captured.');

try
    adaptor = matlab.bigdata.internal.adaptors.getAdaptor(tX);
    if ~istall(tX)
        adaptor = setTallSize(adaptor, size(tX, 1));
    end
    if adaptor.isKnownNotRow()
         error(message(varargin{:}));
    end
    if ~adaptor.isKnownRow() || ~matlab.bigdata.internal.util.isBroadcast(tX)
        % Must be a tall array to reach here. We explicitly reduce tX here
        % because that allows tX to be singleton expanded in the first
        % dimension for future operations. We could use clientfun for the
        % same effect, but this version also guards against out-of-memory
        % if tX is truly tall.
        tX = reducefun(@(x) iThrowIfNotRow(x, true, varargin), tX);
        tX.Adaptor = adaptor;
        tX = clientfun(@(x) iThrowIfNotRow(x, false, varargin), tX);
        tX.Adaptor = setTallSize(resetTallSize(adaptor), 1);
    end
catch err
    throwAsCaller(err);
end

function x = iThrowIfNotRow(x, allowEmpty, errorArgs)
% Reduction function that asserts the given data is a single row.
height = size(x, 1);
if ~ismatrix(x) || (height > 1) || (~allowEmpty && (height == 0))
    error(message(errorArgs{:}));
end
