function tf = isCodegenForHost()
% Return true if codegen target is MATLAB Host. This is used for
% coder.ExternalDependency based functions to decide whether or not shared
% library code or generic code should be generated.

%   Copyright 2014 The MathWorks, Inc.

%#codegen

% Rapid Acceleration is currently not supported for
% coder.ExternalDependency based codegen.
isRapidAccel = coder.target('rtwForRapid');

isMATLABHost = ...
    coder.target('MATLAB') || ...
    coder.target('MEX'   ) || ...
    coder.target('Sfun'  ) || ...
    coder.target('Generic->MATLAB Host Computer');

tf = isMATLABHost && ~isRapidAccel;
end
