function updateDTXState(ntx)
% Update DTX controls within dialogs
%
% Called at creation, and when DTX is turned on/off

%   Copyright 2010 The MathWorks, Inc.

% Sets line colors appropriate to current MSB/LSB methods
bitAllocDlg = ntx.hBitAllocationDialog;
setBAILMethod(bitAllocDlg);
setBAFLMethod(bitAllocDlg);

% If mouse is already within axis bounds, and DTX just turned on,
% we won't lock the axis (which locks on a mouse *transition* from outside
% to inside axis, but not without the transition).
%
% So to be sure we lock the axis in this case, we set axis lock when
% turning on DTX, and vice-versa, if the mouse is already inside axes.
holdXAxisLimits(ntx,ntx.MouseInsideAxes);

% Minimal update of display
setYAxisLimits(ntx);
updateXAxisTextPos(ntx);
updateDTXTextAndLinesYPos(ntx);
updateThresholds(ntx);

% Update over/underflow arrow colors that appear when display
% is locked and new bin data appears before/after axis limits.
% That display is color coded when DTX is on, or blue when off.
% If the display is locked and DTX is toggles, the color needs to change
% dynamically while remaining locked.  A subtle issue, but leads to a
% highly consistent display.
showOutOfRangeBins(ntx);

% Enable bit allocation dialogs in DialogPanel
enableBAILPanel(bitAllocDlg);
enableBAFLPanel(bitAllocDlg);

% Always update dialogs since dialog visibility has changed
% Need to move panels appropriately
showDialogPanel(ntx.dp);

% Perform bit allocations
performAutoBA(ntx);

% Update the histogram visual components after numerictype changes are made.
updateDTXControls(ntx);
