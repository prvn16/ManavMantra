function runName = getCurrentRunName(this)
% GETRUNNAME Gets the current run name to store data

%   Copyright 2012-2016 The MathWorks, Inc.


% The root model might be part of a model reference hierarchy. In that
% case, we need to look at the FPTRunName parameter on the top model and not
% the root model.
mdlObj = get_param(Simulink.ID.getModel(this.Source),'Object');
mdlrefPath = mdlObj.modelReferenceNormalModeVisibilityBlockPath;
if isempty(mdlrefPath)
    runName = mdlObj.FPTRunName;
else
    % Top model is always the first element of the BlockPath object
    topParent = bdroot(mdlrefPath.getBlock(1));
    runName = get_param(topParent,'FPTRunName');
end

%--------------------------------------------------------
%[EOF]
