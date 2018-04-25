function updateThresholdPosition(ntx)
%UPDATETHRESHOLDPOSITION Update the threshold position before extra IL/FL
%bits are updated if the Word Length mode is set to "Auto" since we accounted
%for them previously.

%   Copyright 2010 The MathWorks, Inc.

dlg = ntx.hBitAllocationDialog;
if (dlg.BAWLMethod ~= 1) % If not auto.
    return;
end

% Get the current overflow and underflow cursor position and update it
% before extra IL/FL bits change to a new value. This is done because the
% cursor positions take into account the extra IL/FL bits that were
% previously specified. Not doing so will lead to erroneous computations of
% integer and fraction lengths.

if dlg.extraMSBBitsSelected
    ntx.LastOver = ntx.LastOver - dlg.BAILGuardBits;
    ntx.wasExtraMSBBitsAdded = false;
end

if dlg.extraLSBBitsSelected
    ntx.LastUnder = ntx.LastUnder + dlg.BAFLExtraBits;
    ntx.wasExtraLSBBitsAdded = false;
end
    


% [EOF]
