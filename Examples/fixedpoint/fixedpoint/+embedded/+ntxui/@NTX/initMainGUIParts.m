function initMainGUIParts(ntx)
% First-time initialization of widgets in primary GUI
% Installs current widget settings, resizes figures/panels
% Leaves GUI ready for user interaction, but invisible

%   Copyright 2010 The MathWorks, Inc.

dp = ntx.dp;

% First step of init is to finalize dialogs for dialog panel
% -> no more dialogs should be registered after this point!
finalizeDialogRegistration(dp);

% Establish the histogram and statistics state caches
resetDataHist(ntx);

% Define and initialize .IsSigned
updateSignedStatus(ntx);

resetThresholds(ntx);  % establishes LastOver/LastUnder

setDialogPanelVisible(dp,true); % performs showDialogPanel(), etc

% Guarantee at least one call to resize on exit
% We may get another resize() call by HG
resizeBody(ntx);

enableMouse(ntx);
updateDTXState(ntx);   % calls updateDTXControls()
resetHist(ntx);
updateThresholds(ntx); % uses LastOver/LastUnder

% Initialize pointer
setptr(dp.hFig,'arrow');

% Enable resize callback for histogram body panel
set(dp.hBodyPanel,'ResizeFcn',@(h,e)resizeBody(ntx));
