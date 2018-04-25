function adduimode(hThis,hMode)
% This function is undocumented and will change in a future release

%ADDUIMODE
%   ADDUIMODE(THIS,UIMODE) registers the given mode with the mode. After
%   being registered, a mode may be accessed in a manner analogous to other
%   already registered modes.

%   Copyright 2013 The MathWorks, Inc.

if ~isempty(getuimode(hThis,hMode.Name))
    error(message('MATLAB:adduimode:ExistingMode'));
else
    registerMode(hThis,hMode);
end
