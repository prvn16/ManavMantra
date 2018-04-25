function updateXTickLabels(ntx,forceYUpdate)
% Update "2^N" style tick labels, and add x-tick marks

%   Copyright 2010 The MathWorks, Inc.

% Flag indicating an unconditional update of y-axis position
% of tick labels.  Need to do this when changing x-axis ticks,
% which we know to do automatically here.  But the flag is needed
% when resizing, which doesn't cause new ticks but demands an update to the
% tick y-positions.  This info must be provided to as a flag.
if nargin<2, forceYUpdate=false; end

hax = ntx.hHistAxis;

% Update x-tick labels
if ntx.XAxisAutoscaling
    % When autoscaling, the span of x-axis should accommodate both the
    % histogram bins, and the current under/over threshold positions.  We don't
    % want to lose the cursors when rescaling.
    %
    % xmin and xmax need to be integer values representing exponents of 2^N,
    % and can be pos or neg.
    
    % Constrain the min/max a bit here
    % We don't want to extend the axis, by adding +/- 1 to the values here
    % as we usually do below for 'xlim', when the reason for bumping up
    % against the existing limits is purely due to the threshold cursors.
    % If the histogram data bumps it, that's fine.  But not the cursor.
    % The reason is that bumping up against the limit effectively extends
    % the x-axis limits by +/-1.  We want the histogram to extend the axis,
    % but we do NOT want the cursors to do that.  So we need to determine
    % "why" we are bumping up against the limit, then make a decision to
    % bump back by -/+1, if it's due to the cursors.
    
    % Proposed new min/max
    bc = ntx.BinEdges;
    xmin = min(ntx.LastUnder,bc(1));
    xmax = max(ntx.LastOver,bc(end));
    
    % Min or max bumping the limit?  Is it due to the cursor?
    % If so, we bump it back by one:
    % xxx
    %{
    if (xmin<=ntx.XAxisDisplayMin) && (ntx.LastUnder<bc(1))
        xmin = xmin+1; 
    end
    if (xmax>=ntx.XAxisDisplayMax) && (ntx.LastOver>bc(end))
        xmax = xmax-1;
    end
    %}
    
    % Clip to integer values
    xmax = ceil(xmax);
    xmin = floor(xmin);
else
    xmin = ntx.XAxisDisplayMin;
    xmax = ntx.XAxisDisplayMax;
end
if xmax==xmin
    % When there's only 1 tick to show, the display won't look pretty.
    % Add width, centered around the original single tick
    xmin = xmin-1;
    xmax = xmax+1;
end

% Only create new ticks if a change is occurring to x-axis
if forceYUpdate || ...
        ~isequal(ntx.XAxisDisplayMin,xmin) || ...
        ~isequal(ntx.XAxisDisplayMax,xmax)
    % Record new min/max limits for x-axis, before creating new ticks
    ntx.XAxisDisplayMin = xmin;
    ntx.XAxisDisplayMax = xmax;
    
    % Establish new graphical x-axis display limits
    % Do this before calls to create...()/update...(), which use the axis
    % extent to base x-pos
    set(hax,'XLim',[xmin-1 xmax+1]);
    
    % Construct x-tick label positions, and update the x-axis
    % NOTE: tick y-pos are bogus until we call update...()
    createXAxisTicks(ntx);
    
    % Must update text position to fill in y-pos of ticks
    updateXAxisTextPos(ntx);
end

