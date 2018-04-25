function removeContainerListeners(hMode)

%   Copyright 2013-2014 The MathWorks, Inc.

if ~isfield(hMode.ModeStateData,'ContainerListeners')
    return
end

delete(hMode.ModeStateData.ContainerListeners);
hMode.ModeStateData.ContainerListeners = [];


