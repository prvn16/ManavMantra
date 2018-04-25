function regMode = getMode(hThis,name)
% This function is undocumented and will change in a future release

% Given the name of a mode, return the mode object, providing it has been
% used and is registered with the mode manager.

%   Copyright 2013 The MathWorks, Inc.

allRegisteredModes = hThis.RegisteredModes;
regMode = [];
for i = 1:length(allRegisteredModes)
    if strcmpi(allRegisteredModes(i).Name,name)
        regMode = allRegisteredModes(i);
        break;
    end
end