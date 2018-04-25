function tX = validateMatrix(tX, varargin)
%validateType Possibly deferred check for matrix attribute
%   TX1 = validateMatrix(TX,ERRID,ERRARG1,ERRARG2,..)
%   validates that TX is a matrix. If TX is not a matrix, an error of the
%   given message ID will be issued.

% Copyright 2017 The MathWorks, Inc.

% This prevents this frame and anything below it being added to the gather
% error stack.
frameMarker = matlab.bigdata.internal.InternalStackFrame(); %#ok<NASGU>

narginchk(2, inf);
assert(~any(cellfun(@istall, varargin)), ...
    'Assertion failed: validateMatrix expects error message inputs to not be tall.');
assert(nargout >= 1, 'Assertion failed: validateMatrix expects output to be captured.');

try
    adaptor = matlab.bigdata.internal.adaptors.getAdaptor(tX);
    if adaptor.isKnownNotMatrix()
         error(message(varargin{:}));
    end
    if ~adaptor.isKnownMatrix()
        % Must be a tall array to reach here.
        tX = lazyValidate(tX, [{@ismatrix}, varargin]);
        tX.Adaptor = setSmallSizes(adaptor, NaN);
    end
catch err
    throwAsCaller(err);
end
