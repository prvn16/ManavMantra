function updateOverflowLineColor(ntx)
% Update the overflow line color.

%   Copyright 2010 The MathWorks, Inc.

% Interactive mode not allowed when strategy is "WL+FL" (mode 2)
dlg = ntx.hBitAllocationDialog;
if  (dlg.BAGraphicalMode)
    % When re-entering interactive modes, mark threshold cursor as movable
    set(ntx.hlOver, ...
        'Color',ntx.ColorManualThreshold, ...
        'ZData',[0 0]);
else
    % Mark line as "under system control"
    % When doing this, push it "back" on z-axis so
    % the other cursor, if interactive, can remain "on top"
    set(ntx.hlOver, ...
        'Color',ntx.ColorAutoThreshold, ...
        'ZData', [-1 -1]);
end
