function ret = isEngineShared
%matlab.engine.isEngineShared Return true if current MATLAB session is shared
%  matlab.engine.isEngineShared returns logical 1 (true) if the current
%  MATLAB session is shared and logical 0 (false) otherwise.
%
%  Examples
%
%  % check if the current MATLAB session is shared.
%  status = matlab.engine.isEngineShared
%
%  See also matlab.engine.shareEngine, matlab.engine.engineName

% Copyright 2015 The MathWorks, Inc.

ret = true;

name = attach_name;
if isempty(name)
    ret = false;
end

end