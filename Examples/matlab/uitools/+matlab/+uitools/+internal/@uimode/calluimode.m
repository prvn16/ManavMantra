function calluimode(hThis,name,callback,obj,evd)
% This function is undocumented and will change in a future release

% Activates a uimode and triggers a callback function with the given object
% and event data.

%   Copyright 2013 The MathWorks, Inc.

hThis.activateuimode(name);
hMode = hThis.getuimode(name);
defaultMode = hMode.DefaultUIMode;
% If the mode has been composited, recurse down to the mode to be called.
while ~isempty(defaultMode)
    hMode = hMode.getuimode(defaultMode);
    defaultMode = hMode.DefaultUIMode;
end
hgfeval(get(hMode,callback),obj,evd);