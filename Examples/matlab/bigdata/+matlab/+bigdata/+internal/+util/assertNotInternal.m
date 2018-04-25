function assertNotInternal(err)
% Assert the given error has been marked as user-visible. If not, this will
% rethrow it as an Internal Error.

% Copyright 2017 The MathWorks, Inc.

if ~isa(err, 'matlab.bigdata.BigDataException')
    err = matlab.bigdata.BigDataException.buildInternal(err);
    updateAndRethrow(err);
elseif err.identifier == "MATLAB:bigdata:array:ExecutionError"
    rethrow(err);
end