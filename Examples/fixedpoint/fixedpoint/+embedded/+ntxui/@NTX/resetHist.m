function resetHist(ntx)
% Reset Histogram and Dialog panel states, then update display.
% This is the public reset method.

%   Copyright 2010 The MathWorks, Inc.

resetDataHist(ntx);
resetThresholds(ntx);

% It's intuitive to see signedness get reset to unsigned
updateSignedStatus(ntx);

updateBar(ntx);
% Update the visual - this also performs an updateDialogContent(),
% effectively updating all visible readouts in reaction to the reset
% condition. 
updateVisual(ntx);
