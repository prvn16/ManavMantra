function changeRunNameAndRestoreDirty(modelName, runName)
% CHANGERUNNAMEANDRESTOREDIRTY Changes the run name without altering the "dirty" flag on the model

% Copyright 2017 The MathWorks, Inc.

origDirty = get_param(modelName, 'Dirty');
set_param(modelName,'FPTRunName',runName);
set_param(modelName, 'Dirty', origDirty);