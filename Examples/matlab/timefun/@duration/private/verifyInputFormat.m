function verifyInputFormat(fmt)

%   Copyright 2017 The MathWorks, Inc.

import matlab.internal.datatypes.isCharString

if isCharString(fmt)
    t = split(fmt,'.');
    if ~any(strcmp(t(1),["dd:hh:mm:ss" "hh:mm:ss" "mm:ss" "hh:mm"])) ...
       || (~isscalar(t) && ~(all(t{2}=='S') && strlength(t(2)) < 10)) % Optional fractional seconds up to 9S
       throwAsCaller(MException(message('MATLAB:duration:UnrecognizedInputFormat',fmt)));
    end
else
   throwAsCaller(MException(message('MATLAB:duration:InvalidInputFormat')));
end

