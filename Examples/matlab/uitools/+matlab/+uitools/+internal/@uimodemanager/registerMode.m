function hMode = registerMode(hThis,hMode)
% This function is undocumented and will change in a future release

% Create a new mode and register it with the mode manager.

%   Copyright 2013 The MathWorks, Inc.

% First check if a mode by this name is registered. If it is, error out.
if isempty(hThis.RegisteredModes)
    hThis.RegisteredModes = hMode;
else
    hThis.RegisteredModes(end+1) = hMode;
end