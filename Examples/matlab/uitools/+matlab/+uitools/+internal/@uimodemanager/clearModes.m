function clearModes(hThis)
% This function is undocumented and will change in a future release

% Delete all registered modes for the figure.

%   Copyright 2013 The MathWorks, Inc.

for hMode = hThis.RegisteredModes
    delete(hMode);
end