function ret = engineName
%matlab.engine.engineName Return name of shared MATLAB session
%
%  matlab.engine.engineName returns the name of the current MATLAB session if
%  the session is shared.  Otherwise, it returns an empty value.
%
%  Examples
%
%  % check the name of current MATLAB session
%  name = matlab.engine.engineName
%
%  See also matlab.engine.shareEngine, matlab.engine.isEngineShared.

% Copyright 2015 The MathWorks, Inc.

ret = attach_name;

end