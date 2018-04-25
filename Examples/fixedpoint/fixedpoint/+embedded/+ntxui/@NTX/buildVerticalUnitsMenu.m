function buildVerticalUnitsMenu(ntx, hParentMenu)
% BUILDVERTICALUNITSMENU Builds menu items to change the vertical units of
% the Y-Axis in the Histogram plot. This method is used by both
% HistogramVisual.createNTXMenus() and buildAxisContextMenu() methods to
% add these menu items to the main menu and context menu. hParentMenu can
% either be a context menu handle or a handle to a main menu.

%   Copyright 2010-2012 The MathWorks, Inc.

if isgraphics(hParentMenu, 'uicontextmenu') %handle
    % Histogram units (Y-axis)
    strVerticalUnits = getString(message('fixed:NumericTypeScope:VerticalUnitsMenuItem'));
    hParentMenu = uimenu('Parent',hParentMenu, ...
        'Separator','on', ...
        'Label',strVerticalUnits,...
        'Tag','VerticalUnitsMenu');
end

hm = [];

percentStr = getString(message('fixed:NumericTypeScope:UI_PercentStr'));
percentAndParensStr = sprintf('%s (', percentStr);
percentAndSymbolStr = strcat(percentAndParensStr, '%', ')');
hm(1) = embedded.ntxui.createContextMenuItem(hParentMenu, ...
    percentAndSymbolStr, @(hThis,e)changeVerticalUnitsOption(ntx,hThis), ...
    'userdata',1, 'tag','PercentMenu');

countStr   = getString(message('fixed:NumericTypeScope:UI_CountStr'));
hm(2) = embedded.ntxui.createContextMenuItem(hParentMenu, ...
    countStr, @(hThis,e)changeVerticalUnitsOption(ntx,hThis), ...
    'userdata',2,'tag','CountMenu');

set(hm(ntx.HistVerticalUnits),'Checked','on');

% [EOF]
