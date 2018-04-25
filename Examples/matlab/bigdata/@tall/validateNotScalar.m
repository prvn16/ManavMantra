function tX = validateNotScalar(tX, varargin)
%validateNotScalar Possibly deferred check for ~isscalar attribute
%   TX = validateNotScalar(TX,ERRID,ERRARG1,ERRARG2,..)
%   validates that TX is not a scalar. If TX is a scalar, an error of the
%   given message ID will be issued.
%

% Copyright 2017 The MathWorks, Inc.

% This prevents this frame and anything below it being added to the gather
% error stack.
frameMarker = matlab.bigdata.internal.InternalStackFrame(); %#ok<NASGU>

narginchk(2, inf);
assert(~any(cellfun(@istall, varargin)), ...
    'Assertion failed: validateNotScalar expects error message inputs to not be tall.');
assert(nargout >= 1, 'Assertion failed: validateNotScalar expects output to be captured.');

try
    adaptor = matlab.bigdata.internal.adaptors.getAdaptor(tX);
    if ~istall(tX)
        adaptor = setTallSize(adaptor, size(tX, 1));
    end
    if adaptor.isKnownScalar()
         error(message(varargin{:}));
    end
    if ~adaptor.isKnownNotScalar()
        % Must be a tall array to reach here.
        sz = size(head(tX, 2));
        messageArgs = varargin;
        tX = slicefun(@(x, s) iThrowIfNotScalar(x, s, messageArgs), tX, sz);
        tX.Adaptor = adaptor;
    end
catch err
    throwAsCaller(err);
end

function x = iThrowIfNotScalar(x, sz, messageArgs)
% Throw if the size input argument indicates the tall input is a scalar.
if isequal(sz, [1,1])
    error(message(messageArgs{:}));
end
