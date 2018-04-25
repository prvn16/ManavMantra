function updateUnderflowTextAndXPos(ntx)
% Update underflow text next to underflow threshold cursor

%   Copyright 2010 The MathWorks, Inc.

[binCnt,binPct] = getTotalUnderflows(ntx);
htUnder = ntx.htUnder;

if binCnt==0 % or binPct==0 ... same outcome
    % If there is no underflow, suppress the text
    if ~isempty(get(ntx.htUnder,'String'))
        set(htUnder,'String','');
        
        % Minimal update of display
        setYAxisLimits(ntx);
        updateXAxisTextPos(ntx);
        updateDTXTextAndLinesYPos(ntx);
    end
else
    % Check to see if we are changing from no underflow to underflow
    % This indicates a rescaling in Y may be needed
    updateY = isempty(get(htUnder,'String'));
    
    if ntx.HistVerticalUnits==1
        % Bin Percentage
        str = sprintf('%.1f%%\n%s',binPct,getString(message('fixed:NumericTypeScope:UI_Axes_below_precision')));
    else
        % Bin Count
        if binCnt==1
            str = sprintf('1\n%s',getString(message('fixed:NumericTypeScope:UI_Axes_below_precision')));
        else
            str = sprintf('%d\n%s', binCnt,getString(message('fixed:NumericTypeScope:UI_Axes_below_precision')));
        end
    end
    set(htUnder,'Units','char');
    psave = get(htUnder,'Position');
    set(htUnder, ...
        'Units','data', ...
        'String',str); % set early to get extent
    
    ext = get(htUnder,'Extent');
    strWidth = ext(3); % string width in x-axis data units
    pos = get(htUnder,'Position'); % current text position
    
    % Determine distances from underflow cursor to min x-axis limit
    xlim = get(ntx.hHistAxis,'XLim');
    xthresh = ntx.LastUnder;
    distToLeft = min(ntx.RadixPt,ntx.LastOver) - xthresh;
    distToRight = xthresh - xlim(1);
    
    if (strWidth < distToRight) || (strWidth > distToLeft)
        % Move text to RIGHT of under-thresh (preferred)
        pos(1) = xthresh-ntx.BarGapCenter;
        horz = 'left';
        xtAdj = +2.0;  % gutter space
        
        % an opaque background could show through to axis
        % a white background will "cut through" radix line
        if xthresh > ntx.RadixPt
            backgr = get(ntx.hHistAxis,'Color');
        else
            backgr = 'none';
        end
    else
        % Move text to LEFT of under-thresh cursor
        pos(1) = xthresh-ntx.BarGapCenter;
        horz = 'right';
        xtAdj = -0.5; % gutter space
        backgr = 'none';
    end
    set(htUnder, ...
        'Position',pos, ...
        'BackgroundColor',backgr, ...
        'HorizontalAlignment',horz);
    
    % fix wander, add gutter space
    set(htUnder,'Units','char');
    pos = get(htUnder,'Position');
    pos(2) = psave(2); % fix wander bug
    pos(1) = pos(1) + xtAdj;
    set(htUnder,'Position',pos);
    
    if updateY
        % Minimal update of display
        setYAxisLimits(ntx);
        updateXAxisTextPos(ntx);
        updateDTXTextAndLinesYPos(ntx);
    end
end
