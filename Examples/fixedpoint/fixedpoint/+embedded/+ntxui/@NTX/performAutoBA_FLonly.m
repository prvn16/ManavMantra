function isFLUpdated = performAutoBA_FLonly(ntx,skipCrossTest)
% Take action for Bit Allocation Fraction Length options. The optional input
% skipCrossTest decides if the cursor cross-over check needs to be
% performed. The optional output indicates if the FL cursor moved based on
% modifications made to the BitAllocation panel. This information is used to
% decide if we should try to move the IL cursor or not.

%   Copyright 2010-2012 The MathWorks, Inc.

if nargin<2
    skipCrossTest = false;
end

dlg = ntx.hBitAllocationDialog;
ntx.wasExtraLSBBitsAdded = false;
if dlg.BAGraphicalMode % Interactive overflow mode
        % Exponent (N), not value (2^N)
        bin_data = getBinsForData(ntx, dlg.BAFLMagInteractive);
        % exponent returned is the upper edge of the interval. negate by 1 to get the cursor position.
        newUnder = bin_data-1; 
        % If the magnitude is too small, use the last underflow cursor
        % position. This gives us the position to which the cursor moved.
        if isinf(newUnder)
            newUnder = ntx.LastUnder;
        end
        if dlg.extraLSBBitsSelected
            % newUnder is negative, so we'll subtract the extra bits to
            % increase the value.
            newUnder = newUnder - dlg.BAFLExtraBits;
            ntx.wasExtraLSBBitsAdded = true;
        end
else
    switch dlg.BAFLMethod
        case 1 % Smallest magnitude
            % Determine graphical position of threshold that would be used,
            % had the user set it interactively
            bin_data = getBinsForData(ntx, dlg.BAFLSpecifyMagnitude);
            % exponent returned is the upper edge of the interval.
            newUnder = bin_data-1; 
            if dlg.extraLSBBitsSelected
                % newUnder is negative, so we'll subtract the extra bits to
                % increase the value.
                newUnder = newUnder - dlg.BAFLExtraBits;
                ntx.wasExtraLSBBitsAdded = true;
            end
            
        case 2 % Specify FL bits
            % Directly specify bit weight as a power of 2
            % This will be the NEGATIVE of the number of bits specified
            newUnder = -dlg.BAFLSpecifyBits;
      otherwise
        % Internal message to help debugging. Not intended to be user-visible.
        error(message('fixed:NumericTypeScope:invalidBAFLMethod',dlg.BAFLMethod));
    end
end


if nargout>0
    % Default value to state that the FL cursor moved.
    isFLUpdated = false;
end

% Don't go more than overflow cursor
% Move to the side of this bin to include the bin inside the threshold
if ~skipCrossTest
    newUnder = min(ntx.LastOver,newUnder);
end

% Is the new position different from the last threshold value?
% If not, we can skip further changes
if ~isequal(newUnder,ntx.LastUnder) % careful for empty comparisons!
    ntx.LastUnder = newUnder;
    if nargout > 0
        isFLUpdated = true;
    end
    % Recompute x-axis, axis size, etc
    updateXTickLabels(ntx);
end
% Defer call to updateThresholds() until both Int and Frac automation
% functions have executed.  Otherwise, it could change values unexpectedly.
