function tX = validateScalar(tX, varargin)
%validateType Possibly deferred check for scalar attribute
%   TX = validateScalar(TX,ERRID,ERRARG1,ERRARG2,..)
%   validates that TX is a scalar. If TX is not a scalar, an error of the
%   given message ID will be issued.
%
% The output TX can be used in a scalar expanded operation, even if the
% input could not.

% Copyright 2017 The MathWorks, Inc.

% This prevents this frame and anything below it being added to the gather
% error stack.
frameMarker = matlab.bigdata.internal.InternalStackFrame(); %#ok<NASGU>

narginchk(2, inf);
assert(~any(cellfun(@istall, varargin)), ...
    'Assertion failed: validateScalar expects error message inputs to not be tall.');
assert(nargout >= 1, 'Assertion failed: validateScalar expects output to be captured.');

try
    tX = tall.validateColumn(tX, varargin{:});
    tX = tall.validateRow(tX, varargin{:});
catch err
    throwAsCaller(err);
end
