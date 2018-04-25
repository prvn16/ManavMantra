function performAutoBA_WLforFL(ntx)
% Compute WL based on predetermined FL
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
% Determine # of extra bits specified, if any, in case other failures
% require us to consider this for an override value.  We don't want to
% override then still be "short" later.
if extraLSBBitsSelected(dlg)
    extraBits = dlg.BAFLExtraBits;
else
    extraBits = 0;
end

% First, we must represent the implied MSB itself, which takes 1 bit,
% and the sign bit takes another bit if specified.
msbBits = 1;
if WL < msbBits
    newWL = msbBits+extraBits;
    warndlg(getString(message('fixed:NumericTypeScope:InvalidWordBitLength', ...
        WL, newWL)), ...
        getString(message('fixed:NumericTypeScope:WordLengthDialogName')), 'modal');
    WL = newWL;
    setBAWLBits(dlg,WL);
end

% Now we can assess extra bits
% With MSB, signed, and extra bits, this may exceed WL by itself!
maxExtraBits = WL-msbBits;
if extraBits > maxExtraBits
    % Must keep ONE bit for the MSB itself, then one for the sign if
    % present --- rest can go to extra bits.  Leaves IL=0, of course.
    warndlg(getString(message('fixed:NumericTypeScope:InvalidFLBitLength', ...
        extraBits, maxExtraBits, WL)), ...
        getString(message('fixed:NumericTypeScope:FracLengthDialogName')), 'modal');
    extraBits = maxExtraBits;
    
    % Update ntx.LastUnder before updating the Extra Bits. We do this
    % because ntx.LastUnder accounted for the original extra bits.
    ntx.LastUnder = ntx.LastUnder+dlg.BAFLExtraBits;
    
    % Update guard bit cache and edit box
    setBAFLExtraBits(dlg,extraBits);
    
    % Add the new extra bits to ntx.LastUnder
    ntx.LastUnder = ntx.LastUnder-extraBits;
end

% By constraints above, IL is guaranteed to be >= 0 here.
IL = WL-extraBits;

% Determine bit weight of MSB (and specifically, its exponent)
% based on IL.
% NOTE: exponent of bit weight in LastOver is ABOVE the actual msb bin
%      included in the word; this is because the threshold line goes "to
%      the left" of the bin, and the histogram bin is (a,b] which
%      is open on the left.
% ntx.LastUnder accounted for the extra LSB bits specified - negate the
% extra bits from ntx.LastUnder. We'll add the extra bits to negate.
lsb = ntx.LastUnder+extraBits;
msb = lsb + IL;   
newOver = msb;  % translate from MSB to threshold weight

% Is the new position different from the last threshold value?
% If not, we can skip further changes
if ~isequal(newOver,ntx.LastOver) % careful for empty comparisons!
    ntx.LastOver = newOver;
 
    % Recompute x-axis, axis size, etc
    updateXTickLabels(ntx);
end
