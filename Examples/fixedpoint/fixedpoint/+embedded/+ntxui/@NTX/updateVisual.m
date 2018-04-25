function updateVisual(ntx)
%UPDATEVISUAL Updates the visual based on processed data.

%   Copyright 2010 The MathWorks, Inc.

checkXAxisLock(ntx);
updateHistBarPlot(ntx);

% updates the histogram visual components - title,signed text, overflow & underflow etc
updateDTXHistReadouts(ntx);

% Update visible dialogs
updateDialogContent(ntx.dp);

% Minimal update of display
setYAxisLimits(ntx);
updateXTickLabels(ntx);  % - optimized
updateDTXTextAndLinesYPos(ntx);
showOutOfRangeBins(ntx);

% [EOF]
