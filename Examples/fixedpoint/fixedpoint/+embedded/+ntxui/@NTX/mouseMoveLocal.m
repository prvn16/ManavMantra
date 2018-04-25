function mouseMoveLocal(ntx)
% Give feedback to user while mouse is in motion.
% No button-down click was made, so no dragging occurs.

%   Copyright 2010 The MathWorks, Inc.

% Let DialogPanel handle mouse move events first
%
if mouseMove(ntx.dp)
    return % EARLY RETURN
end

% No other systems handled the mouse move
% See if NTX has specific actions to take
%
if ntx.ShowHistogram
    % Only check if histogram is visible
    
    % Cursor pos, in histogram axis reference frame
    hax = ntx.hHistAxis;
    pt_hist = get(hax,'CurrentPoint'); % data units
    pt_x = pt_hist(1,1);
    pt_y = pt_hist(1,2);

    % Test if within bounds of histogram axis
    xlim = get(hax,'XLim');
    ylim = get(hax,'YLim');
    inAxisXBounds = (pt_x >= xlim(1)) && (pt_x <= xlim(2));
    inAxisYBounds = (pt_y >= ylim(1)) && (pt_y <= ylim(2));
    mouseInHistAxes = inAxisXBounds && inAxisYBounds;
    
    xUnder = ntx.LastUnder;
    xOver = ntx.LastOver;
    hit = false;
    
    hfig = ntx.hFig;
    
    % Check for transition into or out of histogram axis
    %
    if mouseInHistAxes
        % Mouse is inside axes
        if ~ntx.MouseInsideAxes
            % We are transitioning from outside to inside axes,
            % and will engage the x-axis lock.
            %
            % However, unless at least one threshold is in interactive
            % mode, there is no reason to lock the axis.
            %
            % Determine if either cursor is interactive:
            dlg = ntx.hBitAllocationDialog;
            anyInteractive = (dlg.BAFLMethod==1) || (dlg.BAILMethod==1);
            if anyInteractive
                % Transition outside -> inside
                ntx.MouseInsideAxes = true;
                
                holdXAxisLimits(ntx,true); % lock x-axis
                setYAxisLimits(ntx);
                updateDTXTextAndLinesYPos(ntx);
                
                % update thresholds in case they're in default state
                updateThresholds(ntx);
            end
        end
    else
        % Mouse is outside axes
        if ntx.MouseInsideAxes
            % Transition inside -> outside
            ntx.MouseInsideAxes = false;
            holdXAxisLimits(ntx,false); % unlock x-axis
            
            % update thresholds in case they're in default state
            updateThresholds(ntx);
        end
    end
    
    % The only items in the axes that cause the mouse to change are the DTX
    % threshold lines.  If DTX is not visible, do not compute checks.
    % Check vertical threshold lines
    %  - cursor is within a small horiz window around either the
    %    Underflow or Overflow cursor
    %  - cursor is within the vertical extent of the axis
    gap = ntx.BarGapCenter;
    if inAxisYBounds
        % Set x-axis distance threshold used for detecting a "mouse hit" on
        % a given threshold cursor.  We set a half-width metric, xThresh,
        % for cursor hit detection, set in data units.
        %
        % When width of displayed bins are > 2% of width,
        %   use .45 bin width as halfwidth
        % Otherwise, bins are too narrow and cursors are hard to hit
        % In this case,
        %   use
        %
        % Note that some bins may appear "offscreen" due to x-axis locking
        
        % Our target halfwidth metric is 2% of the x-axis
        targetFrac = 0.02;
        
        % visible span of x-axis
        visXSpan = xlim(2)-xlim(1);
        if visXSpan > 0
            % Meet our target hit range
            % Scale fraction by visible span to get data units
            xThresh = targetFrac * visXSpan;
            
            % If the mouse is between the cursors, confirm that we
            % do not exceed half the intercursor distance, otherwise
            % visual confusion can occur for mouse hit:
            if (pt_x+gap > xUnder) && (pt_x+gap < xOver)
                % Find intercursor distance in data units
                icDist = xOver-xUnder;
                if xThresh > 0.9*icDist/2
                    % Leave a small gap
                    xThresh = 0.9*icDist/2;
                end
            end
        else
            % No need to do much, with only 0 or 1 bins
            % Set to 1/2 bin width
            xThresh = 0.5;
        end
        
        % Determine if overflow or underflow cursors are in an
        % "interactive" mode for graphical cursor input
        % For MSB, can't interact if strategy is "WL+FL"
        %    (disables user interaction of IL)
        % For LSB, can't interact if strategy is "WL+IL"
        %    (disables user interaction of FL)
        dlg = ntx.hBitAllocationDialog;
        interactMSB = (dlg.BAStrategy~=2) && (dlg.BAILMethod == 1);
        interactLSB = (dlg.BAStrategy~=1) && (dlg.BAFLMethod == 1);
        
        if interactLSB && (abs(pt_x+gap-xUnder) < xThresh)
            % Hovering over Underflow line, or both cursors stacked
            hit = true;
            setptr(hfig,'lrdrag');
            
            % When both cursors are overlayed, make the "last one
            % moved" have priority.  This feels right.  It also
            % prevents a nasty situation where if both cursors are
            % moved, say, to the far right, and the right cursor has
            % priority, both cursors become hopelessly stuck.
            if (xUnder==xOver)
                ntx.WhichLineDragged = ntx.WhichLineDraggedLast;
            else
                ntx.WhichLineDragged = 1; % 1=under
            end
        elseif interactMSB && (abs(pt_x+gap-xOver) < xThresh)
            % Hovering over Overflow line
            hit = true;
            setptr(hfig,'lrdrag');
            ntx.WhichLineDragged = 2; % 2=over
        end
    end
    
    % Check horizontal wordsize line
    % We need to be within x-bounds first
    if ~hit && ...
            (pt_x+gap >= xUnder) && (pt_x+gap <= xOver)
        % Establishing a vertical threshold for grabbing the horizontal
        % "word size" line is a bit less exact than for xThresh.
        % We set this to ~2% of the total vertical axis height.
        yThresh = (ylim(2)-ylim(1))*0.02;
        if abs(pt_y - ntx.yWordSpan) < yThresh
            if ntx.EnableWordSizeLineDrag
                hit = true;
                setptr(hfig,'uddrag');
                ntx.WhichLineDragged = 3; % 3=wordsize
            end
            
        elseif (pt_y > ntx.yWordSpan) && (pt_y <= ylim(2))
            % pointer is in wordlength (WL) region
            % this signals user that the WL region can be dragged
            
            % First determine if locked drag of cursors is allowed
            % If it isn't, don't even allow "hand" pointer to show up
            %
            dlg = ntx.hBitAllocationDialog;
            bothInteractive = (dlg.BAFLMethod==1) && (dlg.BAILMethod==1);
            if bothInteractive
                % If we're ready to allow locked drag of cursors,
                % set things up:
                hit = true;
                setptr(hfig,'hand');
                ntx.WhichLineDragged = 4; % 4=WL region
                ntx.DragWordLengthRegion = pt_x; % cache for motion
            end
        end
    end
    
    if ~hit && (ntx.WhichLineDragged > 0)
        % No mouse down on a cursor, just roaming with mouse
        % Last time, we were over a cursor
        % This time, we are no longer over a cursor
        % No mouse click, so we reset the pointer back to normal
        setptr(hfig,'arrow');
        ntx.WhichLineDragged = 0; % 0=neither
    end
    
    if hit && any(ntx.WhichLineDragged==[1 2])
        % Store last underthresh or overthresh cursor used
        ntx.WhichLineDraggedLast = ntx.WhichLineDragged;
    end
end
