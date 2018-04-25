function performAutoBA_WLforIL(ntx)
% Compute WL based on predetermined IL
%
% Note that WL, IL, and FL are numbers of bits, and not the specific bit
% weights of the MSB or LSB.  Guard bits and sign bit must be taken into
% consideration.

%   Copyright 2010-2012 The MathWorks, Inc.

dlg = ntx.hBitAllocationDialog;

% Determine if WL is appropriately sized by user
WL = dlg.BAWLBits; % Get WL from user

% Start assessing the bit budget
%
% Determine # of guard bits specified, if any, in case other failures
% require us to consider this for an override value.  We don't want to
% override then still be "short" later.
if extraMSBBitsSelected(dlg)
    guardBits = dlg.BAILGuardBits;
else
    guardBits = 0;
end

% First, we must represent the specified MSB itself, which takes 1 bit,
% and the sign bit takes another bit if specified.
msbBits = 1;
if WL < msbBits
    newWL = msbBits+guardBits;
    warndlg(getString(message('fixed:NumericTypeScope:InvalidWordBitLength', ...
        WL, newWL)), ...
        getString(message('fixed:NumericTypeScope:WordLengthDialogName')), 'modal');
    WL = newWL;
    setBAWLBits(dlg,WL);
end

% Now we can assess guard bits
% Having non-zero guard bits means we not only need to include the
% msb, but we also need all the bits from msb up to and including the
% highest guard bit.  That's a span of bits that may exceed WL by itself!
maxGuardBits = WL-msbBits;
if guardBits > maxGuardBits
    % Must keep ONE bit for the MSB itself, then one for the sign if
    % present --- rest can go to guard bits.  Leave FL=0, of course.
    warndlg(getString(message('fixed:NumericTypeScope:InvalidILBitLength', ...
        guardBits, maxGuardBits, WL)), ...
        getString(message('fixed:NumericTypeScope:IntegerLengthDialogName')), 'modal');
    guardBits = maxGuardBits;
    
    % Update ntx.LastOver before updating the Extra Bits. We do this
    % because ntx.LastOver accounted for the original guard bits.
    ntx.LastOver = ntx.LastOver-dlg.BAILGuardBits;
    
    % Update guard bit cache and edit box
    setBAILGuardBits(dlg,guardBits);
    
    % Add the new guardBits to ntx.LastOver
    ntx.LastOver = ntx.LastOver+guardBits;
end

% By constraints above, FL is guaranteed to be >= 0 here.
FL = WL-guardBits;

% Determine bit weight of LSB (and specifically, its exponent)
% based on FL.
% NOTE: exponent of bit weight in LastOver is ABOVE the actual msb bin
%      included in the word; this is because the threshold line goes "to
%      the left" of the bin, and the histogram bin is (a,b] which
%      is open on the left.
% ntx.LastOver accounted for the extra MSB bits specified - negate the
% guard bits from ntx.LastOver. We've already accounted for the signBit in
% the initial calculation of FL. Since ntx.LastOver includes the sign bit,
% remove it from the msb calculation too.
msb = ntx.LastOver-guardBits;
lsb = msb - FL;   % exponent of LSB bit weight
newUnder = lsb;

% Is the new position different from the last threshold value?
% If not, we can skip further changes
if ~isequal(newUnder,ntx.LastUnder) % careful for empty comparisons!
    ntx.LastUnder = newUnder;

    % Recompute x-axis, axis size, etc
    updateXTickLabels(ntx);
end


