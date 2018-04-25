function setInteractiveMagnitudes(dlg,newOverExp,newUnderExp,wasExtraMSBBitsAdded,wasExtraLSBBitsAdded)
% Determine magnitude values from exponents
% Copy values (not exponent) into magnitudes

%   Copyright 2010 The MathWorks, Inc.


if dlg.extraMSBBitsSelected && wasExtraMSBBitsAdded
    newOverExp = newOverExp - dlg.BAILGuardBits;
end
if dlg.extraLSBBitsSelected && wasExtraLSBBitsAdded
    newUnderExp = newUnderExp + dlg.BAFLExtraBits;
end
dlg.BAILMagInteractive = pow2(newOverExp);
dlg.BAFLMagInteractive = pow2(newUnderExp);

