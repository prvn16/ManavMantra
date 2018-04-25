function tX = validateColumn(tX, varargin)
%validateType Possibly deferred check for column attribute
%   TX1 = validateColumn(TX,ERRID,ERRARG1,ERRARG2,..)
%   validates that TX is a column. If TX is not a column, an error of the
%   given message ID will be issued.

% Copyright 2017 The MathWorks, Inc.

% This prevents this frame and anything below it being added to the gather
% error stack.
frameMarker = matlab.bigdata.internal.InternalStackFrame(); %#ok<NASGU>

narginchk(2, inf);
assert(~any(cellfun(@istall, varargin)), ...
    'Assertion failed: validateColumn expects error message inputs to not be tall.');
assert(nargout >= 1, 'Assertion failed: validateColumn expects output to be captured.');

try
    adaptor = matlab.bigdata.internal.adaptors.getAdaptor(tX);
    if adaptor.isKnownNotColumn()
         error(message(varargin{:}));
    end
    if ~adaptor.isKnownColumn()
        % Must be a tall array to reach here.
        tX = lazyValidate(tX, [{@iscolumn}, varargin]);
        tX.Adaptor = setSmallSizes(adaptor, 1);
    end
catch err
    throwAsCaller(err);
end
