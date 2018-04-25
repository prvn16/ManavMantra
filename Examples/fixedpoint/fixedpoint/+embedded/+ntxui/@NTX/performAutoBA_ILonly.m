function isILUpdated  = performAutoBA_ILonly(ntx,skipCrossTest)
% Take action for Bit Allocation Integer Length options. The optional input
% skipCrossTest decides if the cursor cross-over check needs to be
% performed. The optional output indicates if the IL cursor moved based on
% modifications made to the BitAllocation panel. This information is used to
% decide if we should try to move the IL cursor again or not.

%   Copyright 2010-2012 The MathWorks, Inc.

if nargin<2
    skipCrossTest = false;
end

dlg = ntx.hBitAllocationDialog;
ntx.wasExtraMSBBitsAdded = false;
if dlg.BAGraphicalMode % Interactive overflow mode
    % Exponent (N), not value (2^N)
    % Exponent assumes the signed interval. 
    bin_data = getBinsForData(ntx, dlg.BAILMagInteractive);
    % The magnitude was calculated using 2^cursor location. The bin data
    % returned gives the upeer end of the interval. Negate by 1 to get the
    % cursor position.
    newOver = bin_data - 1;
  
    % If the magnitude is too large, use the last overflow cursor position.
    % This gives us the position to which the cursor moved.
    if isinf(newOver)
        newOver = ntx.LastOver;
    end
    if dlg.extraMSBBitsSelected
        newOver = newOver + dlg.BAILGuardBits;
        ntx.wasExtraMSBBitsAdded = true;
    end
else
    switch dlg.BAILMethod
      case 1
        % Maximum Overflow
        % Move overflow cursor to be <= specified percent/count
        % Use count uniformly, so we convert percent to count if given
        
        if dlg.BAILUnits==1 % Percent
                            % We want to choose a setting that is <= specified
            dCnt = dlg.BAILPercent/100 * ntx.DataCount;
        else
            dCnt = dlg.BAILCount;
        end
        
        % Sum the bins starting from the "top" (high index),
        % which represent bins with largest bin centers.
        bcnt = fliplr(ntx.BinCounts);
        bctr = fliplr(ntx.BinEdges);
        
        % If unsigned data format, we treat negative values as overflow in
        % the MSB bin.  We subtract off the negative counts from bins,
        % and add the total neg count to the first (flipped) bcnt bin.
        %
        % Special care of small negative values is needed
        % If .SmallNegAreOverflow=true, we count negatives in the (0,-0.5)
        % interval as overflow
        if ~ntx.IsSigned && (ntx.DataNegCnt > 0)
            negVals = ntx.NegBinCounts;
            if ~ntx.SmallNegAreOverflow
                % Small neg are treated as Underflow, not overflow
                % Remove their count so we don't add them to the Overflow
                %   accumulation in bcnt.  BinCenters has exponents, not
                %   values, so -1 means 2^-1 which is 0.5.  For the
                %   negative numbers considered here, this means negative
                %   values with magnitude < 0.5.
                negVals(ntx.BinEdges < -1) = 0;
            end
            
            % Move the appropriate subset of negative values out of the
            % individual bins, and into the very first bin
            %
            % We flipped ntx.BinCounts, so be sure to flip ntx.NegBinCounts
            % as well in order to subtract the right neg counts!
            bcnt = bcnt - fliplr(negVals);
            bcnt(1) = bcnt(1) + sum(negVals);
        end
        % First see if we have any overflows
        cs = cumsum(bcnt);
        idx = find(dCnt >= cs,1,'last');
        
        if isempty(idx)
            newOver = bctr(1);
            % Add one bit for the signedness to prevent overflows
            newOver = newOver+ntx.IsSigned;
        else
            % No entries were <= desired count
            % MSB goes to left of highest non-zero bin
            newOver = bctr(idx);
        end
        if dlg.extraMSBBitsSelected
            newOver = newOver + dlg.BAILGuardBits;
            ntx.wasExtraMSBBitsAdded = true;
        end
        
        case 2 % Largest Magnitude mode
            % Determine graphical position of threshold that would be used,
            % had the user set it interactively.
          newOver = getBinsForData(ntx, dlg.BAILSpecifyMagnitude);
          % Add one bit for the signedness.
          newOver = newOver+ntx.IsSigned;
          if dlg.extraMSBBitsSelected
              newOver = newOver + dlg.BAILGuardBits;
              ntx.wasExtraMSBBitsAdded = true;
          end
            
        case 3 % Specify IL bits
            % Directly specify bit weight as a power of 2. Since the radix
            % point starts at -1 on the x-axis, translate the number of
            % bits to the actual x-axis position. Th length between the
            % radix point and the overflow cursor should always be
            % dlg.BAILSpecifyBits long.
            newOver = dlg.BAILSpecifyBits+ntx.RadixPt;
      otherwise
        % Internal message to help debugging. Not intended to be user-visible.
        error(message('fixed:NumericTypeScope:invalidBAILMethod',dlg.BAILMethod));
    end
end

if nargout>0
    % Default value to state that the IL cursor moved.
    isILUpdated = false;
end

% Highest we can go is to the overflow cursor
% Move more than this bin, to include the bin in the total
% overflow count.
if ~skipCrossTest
     newOver = max(ntx.LastUnder,newOver);
end

if ~isequal(newOver,ntx.LastOver) % careful for empty comparisons!
    ntx.LastOver = newOver;
    if nargout > 0
        isILUpdated = true;
    end
    % Recompute x-axis, axis size, etc
    updateXTickLabels(ntx);
end
% Defer call to updateThresholds() until both Int and Frac automation
% functions have executed.  Otherwise, it could change values unexpectedly.

