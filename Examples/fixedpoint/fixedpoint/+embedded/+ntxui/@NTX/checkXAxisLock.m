function checkXAxisLock(ntx)
% Confirms that mouse is still in histogram axis
% If not, removes x-axis lock
%
% Prevents axis from getting stuck in x-axis lock when mouse quickly moved
% outside axes

%   Copyright 2010 The MathWorks, Inc.

if ntx.MouseInsideAxes
    % Only check if histogram is visible and DTX is on
    %  .MouseInsideAxes cannot be true if histogram was not on at some
    %  point, as well as the DTX, so this test suffices
    
    % Get mouse position, which is always updated, in screen ref frame
    globalPtr = get(0,'PointerLocation');
    figpos = get(ntx.hFig,'Position');
    pt_xp = globalPtr(1)-figpos(1); % pixels, in fig ref frame
    pt_yp = globalPtr(2)-figpos(2);
    
    % Convert pixels coords to approx data coords
    xlim = get(ntx.hHistAxis,'XLim');
    ylim = get(ntx.hHistAxis,'YLim');
    axpos = get(ntx.hHistAxis,'Position'); % pixel units
    ax0 = axpos(1);
    ay0 = axpos(2);
    adx = axpos(3);
    ady = axpos(4);
    pt_x = xlim(2) - (pt_xp-ax0)/adx * (xlim(2)-xlim(1)); % x-axis reversed
    pt_y = ylim(1) + (pt_yp-ay0)/ady * (ylim(2)-ylim(1)); % data units
    
    % Test if within bounds of histogram axis
    inAxisXBounds = (pt_x >= xlim(1)) && (pt_x <= xlim(2));
    inAxisYBounds = (pt_y >= ylim(1)) && (pt_y <= ylim(2));
    if ~inAxisXBounds || ~inAxisYBounds
        % Mouse no longer inside axis
        ntx.MouseInsideAxes = false;
        holdXAxisLimits(ntx,false); % unlock x-axis
    end
end
