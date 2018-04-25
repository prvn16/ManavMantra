function fmt = verifyFormat(fmt)

%   Copyright 2014-2017 The MathWorks, Inc.

import matlab.internal.datatypes.isCharString

if isCharString(fmt)
    % In simplest cases (including the seconds, minutes, etc. functions), can
    % avoid overhead of calling the internal package function
    if ~isscalar(fmt) || all(fmt ~= 'ydhms')
        try % try out the format, ignore any return value
            matlab.internal.duration.formatAsString(1234.56789,fmt,false,false);
        catch ME
            throwAsCaller(MException(message('MATLAB:duration:UnrecognizedFormat',fmt)));
        end
    end
else
    throwAsCaller(MException(message('MATLAB:duration:InvalidFormat')));
end
