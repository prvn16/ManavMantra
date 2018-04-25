function mouseDragThresholdLine(ntx)
% Movement of a vertical threshold cursor when mouse button is being held,
% Or locked translation of the wordlength region

%   Copyright 2010-2012 The MathWorks, Inc.

pt = get(ntx.hHistAxis,'CurrentPoint');

% Cursor x-coordinate is an exponent (N), not a value (2^N)
% It is quantized to integer values with an offset of -BarGapCenter
pt_x = pt(1,1);

% We got here by getting past mouseDown(), which selects an x-value with a
% BarGapCenter offset => pt_x is BarGapCenter below an integer.
% To get back to an integer exponent, we add BarGapCenter:
xq = round(pt_x - ntx.BarGapCenter);

if ntx.LockThresholds
    % Implement "fixed-distance" thresholds
    % Move one and the other "slaves" to it to maintain a fixed
    % distance (in bits).  Distance may stretch farther apart
    % when, say, the overflow threshold tries to go past the
    % radix line.
    lastUnder = ntx.LastUnder;
    lastOver = ntx.LastOver;
    dlg = ntx.hBitAllocationDialog;
    switch ntx.WhichLineDragged
        case 1   % Dragged underflow thresh
            newUnder = xq;
            newOver = lastOver + (newUnder - lastUnder);
            setUnderflowLineDragged(dlg, true);
            setOverflowLineDragged(dlg, false);
        case 2   % Dragged overflow thresh
            newOver = xq;
            newUnder = lastUnder + (newOver - lastOver);
            setOverflowLineDragged(dlg, true);
            setUnderflowLineDragged(dlg, false);
        case 4   % Dragged wordlength (WL) region
            % Propose new over and under coords
            xOrig = ntx.DragWordLengthRegion;
            dxq = round(pt_x - xOrig);
            if dxq~=0
                xOrig = xOrig + dxq;
                ntx.DragWordLengthRegion = xOrig;
            else
                % Don't make an update until mouse moved sufficiently far
                % Here, that's far enough to make |dxq|>0
                dxq=0;
            end
            newOver = lastOver + dxq;
            newUnder = lastUnder + dxq;
            
      otherwise
        % Internal message to help debugging. Not intended to be user-visible.
        error(message('fixed:NumericTypeScope:unsupportedEnumerationMouseDown',ntx.WhichLineDragged));
    end
    
    % Check that new values are valid
    if validUnderflowXDrag(ntx,newUnder) ...
            && validOverflowXDrag(ntx,newOver)
        % slave the overflow thresh
        
        ntx.LastUnder = newUnder;
        ntx.LastOver = newOver;
        
        % Recompute x-axis, axis size, etc
        updateThresholds(ntx);
    end
else
    % Simple update of one threshold
    updateThresholds(ntx,xq);

    % If BAStrategy is other then IL+FL (which is the one mode that
    % carries out the automation immediately as the changes are
    % made), we must perform threshold updates explicitly now.
    dlg = ntx.hBitAllocationDialog;
    if (dlg.BAWLMethod == 2)%dlg.BAStrategy ~= 3; % IL+FL
        performAutoBA(ntx);
    end
end

% perform histogram visual updates after changes to the numerictype are made.
updateDTXHistReadouts(ntx);
