function updateThresholds(ntx,xq)
% Update graphics to initialize display, during a line drag, etc
%
% xq is the x-coord in exponent units (N, not 2^N) of the threshold line,
% without an offset.  Argument passed only if it changed
%
% If xq arg omitted, updates to text, colors, etc, are still performed

%   Copyright 2010-2012 The MathWorks, Inc.

% Take action based on which line is being dragged
if nargin < 2
    % Update BOTH graphical lines using LastOver and LastUnder
    % resulting from locked drag, etc
    updateInteractiveMagLinesAndReadouts(ntx,ntx.LastOver,ntx.LastUnder);
else
    switch ntx.WhichLineDragged
        case 1 % Underflow line
            if validUnderflowXDrag(ntx,xq)
                % We will convert the underflow threshold position to the
                % actual fraction length value and then update the cursor
                % position based on the fraction length.
                updateInteractiveMagLinesAndReadouts(ntx,ntx.LastOver,xq);
                setUnderflowLineDragged(ntx.hBitAllocationDialog, true);
                setOverflowLineDragged(ntx.hBitAllocationDialog, false);
            end
        case 2 % Overflow line
            if validOverflowXDrag(ntx,xq)
                updateInteractiveMagLinesAndReadouts(ntx,xq,ntx.LastUnder);
                setOverflowLineDragged(ntx.hBitAllocationDialog, true);
                setUnderflowLineDragged(ntx.hBitAllocationDialog, false);
            end
      otherwise
        % Internal message to help debugging. Not intended to be user-visible.
        error(message('fixed:NumericTypeScope:invalidIndex'));
    end
end
% Update the numerictype in response to changes in thresholds. The visual
% updates will be made when update on the visual is invoked.
updateNumericTypesAndSigns(ntx);
