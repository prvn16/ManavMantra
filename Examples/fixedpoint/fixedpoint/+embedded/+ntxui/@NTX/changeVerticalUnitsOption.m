function changeVerticalUnitsOption(ntx,hThisMenu)
% Change vertical display units option
%  1 = Percentage
%  2 = Bin count

%   Copyright 2010 The MathWorks, Inc.

if embedded.ntxui.isHGHandleOfType(hThisMenu,'uimenu')
    % Get selected value from user-data of context menu
    ntx.HistVerticalUnits = get(hThisMenu,'UserData');
else % The value is passed in via a change to the main menu.
    ntx.HistVerticalUnits  = hThisMenu;
end

% Update the overflow mode on the bit allocation panel.
setBAILUnits(ntx.hBitAllocationDialog,ntx.HistVerticalUnits);
initHistDisplay(ntx); % force a change to y-axis label and its units
updateBar(ntx); % skip data updates and force hist bar update
updateVisual(ntx); % Force visual updates.

