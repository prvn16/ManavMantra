function resizeVisualForToolbarInstall(ntx)
% RESIZEVISUALFORTOOLBARINSTALL Force a resize on the panels

%   Copyright 2012 The MathWorks, Inc.


% Since the outer position of the NTX window is fixed, we need to force a
% resize to account for space lost when toolbars are installed.
resizeParentPanel(ntx.dp);
