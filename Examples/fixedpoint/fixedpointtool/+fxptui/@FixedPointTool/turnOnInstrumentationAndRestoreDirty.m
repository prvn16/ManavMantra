function turnOnInstrumentationAndRestoreDirty(this)
% TURNONINSTRUMENTATIONANDRESTOREDIRTY Turns on MinMaxOverflow logging and restores the dirty flag on all models including referenced models

% Copyright 2017 The MathWorks, Inc.

try
    [refMdls, ~] = find_mdlrefs(this.getModel);
catch  % Model not on path.
     return;
end

origDirty(1:length(refMdls)) = {''};

for i = 1:length(refMdls)
    origDirty{i} = get_param(refMdls{i}, 'dirty');
    set_param(refMdls{i}, 'MinMaxOverflowLogging','MinMaxAndOverflow');
    if strcmp(origDirty{i}, 'off')
        set_param(refMdls{i}, 'dirty','off')
    end
end
