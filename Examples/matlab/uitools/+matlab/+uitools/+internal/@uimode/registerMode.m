function hMode = registerMode(hThis,hMode)
% This function is undocumented and will change in a future release

% Register a mode with this mode to be composed.

%   Copyright 2013 The MathWorks, Inc.

% Specify that this mode is being composed
hMode.ParentMode = hThis;

if isempty(hThis.RegisteredModes)
    hThis.RegisteredModes = hMode;
else
    hThis.RegisteredModes(end+1) = hMode;
end