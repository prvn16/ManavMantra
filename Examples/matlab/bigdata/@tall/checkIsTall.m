function checkIsTall(fcn, argPosition, arg)
%checkIsTall Throw an error if an input argument is not tall
%   checkIsTall(FCN, ARGPOSITION, ARG) throws (as caller) error(message(ID,
%   FCN)) if the specified input is not tall.

% Copyright 2016-2017 The MathWorks, Inc.

if ~istall(arg)
    msg = message('MATLAB:bigdata:array:ArgMustBeTall', argPosition, fcn);
    throwAsCaller(MException(msg.Identifier, '%s', getString(msg)));
end
end
