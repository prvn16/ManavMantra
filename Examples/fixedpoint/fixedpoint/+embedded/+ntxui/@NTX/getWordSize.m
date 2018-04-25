function [intBits,fracBits,wordBits,isSigned] = getWordSize(ntx,extra)
% Get selected word size from underflow and overflow thresholds.
% If extra=true, guard bits and precision bits are added to bit counts.
% Otherwise, by default, they are NOT added to bit counts.
%
% This returns "syntax" for fi object constructor, not true bit counts.
% Ex: FL may be negative, etc.

%   Copyright 2010 The MathWorks, Inc.

isSigned = ntx.IsSigned;
dlg = ntx.hBitAllocationDialog;

% Distance from radix point to underflow threshold is the fraction length. If
% extra bits are selected, then negate by the number of bits specified
% since ntx.LastUnder has already accounted for it.
fracBits = round(-ntx.LastUnder);
if dlg.extraLSBBitsSelected
    fracBits = fracBits - dlg.BAFLExtraBits;
end

% Distance from overflow thresh to the radix point is the int length. We
% add 1 to account for zeroth bin. If extra bits are selected, then negate
% by the number of bits specified since ntx.LastOver has already accounted
% for it.
intBits = round(ntx.LastOver); 
if dlg.extraMSBBitsSelected
    intBits = intBits - dlg.BAILGuardBits;
end

% % Careful: if fracBits < 0, we add it to reduce intBits
% if fracBits < 0
%     intBits = intBits + fracBits;
% end
% % intBits includes the sign bit.
% wordBits = intBits + max(0,fracBits); 
wordBits = intBits + fracBits;
if nargin>1 && extra
    % If DTX is on, add guard bits and precision bits
    % to frac and word
    if extraLSBBitsSelected(dlg)
        fracBits = fracBits + dlg.BAFLExtraBits;
        wordBits = wordBits + dlg.BAFLExtraBits;
    end
    if extraMSBBitsSelected(dlg)
        intBits  = intBits  + dlg.BAILGuardBits;
        wordBits = wordBits + dlg.BAILGuardBits;
    end
end
