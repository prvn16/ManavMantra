function checkNotTall(fcn, offset, varargin)
%checkNotTall Throw an error if any trailing argument is tall
%   checkNotTall(FCN,OFFSET,V1,V2,...) throws (as caller) error(message(ID,
%   FCN)) if any of V1,V2,... is tall. OFFSET is the number of arguments to the
%   original function prior to those input to this function.

% Copyright 2016-2017 The MathWorks, Inc.

firstTallArg = find(cellfun(@istall, varargin), 1, 'first');
if ~isempty(firstTallArg)
    argPosition = offset + firstTallArg;
    msg = message('MATLAB:bigdata:array:ArgMustNotBeTall', argPosition, fcn);
    throwAsCaller(MException(msg.Identifier, '%s', getString(msg)));
end
end
