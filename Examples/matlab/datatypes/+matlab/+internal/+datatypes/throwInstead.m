function throwInstead(ME,oldMsgID,varargin)

%   Copyright 2014-2017 The MathWorks, Inc.

% If the exception is one of the specified errors, throw the desired one instead
throw(matlab.internal.datatypes.replaceException(ME,oldMsgID,varargin{:}));
end

