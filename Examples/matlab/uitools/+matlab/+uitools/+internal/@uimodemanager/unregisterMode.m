function unregisterMode(hThis,hMode)
% This function is undocumented and will change in a future release

% Given a mode, remove it from the list of modes currently
% registered with the mode manager.

%   Copyright 2006-2013 The MathWorks, Inc.

allRegisteredModes = hThis.RegisteredModes;
for i = 1:length(allRegisteredModes)
    if isequal(allRegisteredModes(i),hMode)
        allRegisteredModes(i) = [];
        break;
    end
end

hThis.RegisteredModes = allRegisteredModes;