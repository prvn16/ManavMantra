function buildAxisContextMenu(ntx)
% Context menu for the 'axis' object (background context menu)
% Fairly extensive, so it gets its own function
%
% It also needs to be called by other context menu builders
% when they are in a disabled state, so this had to be modular.

%   Copyright 2010-2012 The MathWorks, Inc.

dp = ntx.dp;

% Copy numerictype display string to system clipboard
hMainContext = dp.hContextMenu;
copyNumerictypeStr = sprintf('%s numerictype', ...
    getString(message('fixed:NumericTypeScope:UI_CopyStr')));
embedded.ntxui.createContextMenuItem(hMainContext, ...
    copyNumerictypeStr, ...
    @(h,e)copyNumericTypeToClipboard(ntx), 'enable', 'on');

% Build the menus to change the Y-Axis units. Example: Percent, Count.
buildVerticalUnitsMenu(ntx,hMainContext);

% Build fraction text context menu
hp = uimenu('Parent',hMainContext, ...
    'Label',getString(message('fixed:NumericTypeScope:FractionUnitsTitleStr')), ...
    'Enable','on');
hm = [];
hm(1) = embedded.ntxui.createContextMenuItem(hp, ...
    getString(message('fixed:NumericTypeScope:UI_FLStr')), ...
    @(hThis,e)changeDTXFracSpanText(ntx,hThis), 'userdata',1);
hm(2) = embedded.ntxui.createContextMenuItem(hp, ...
    getString(message('fixed:NumericTypeScope:UI_SlopeStr')), ...
    @(hThis,e)changeDTXFracSpanText(ntx,hThis), 'userdata',2);
set(hm(ntx.DTXFracSpanText),'Checked','on');

% Add auto-hide menu, configure checkmark
autoHide = uiservices.logicalToOnOff(dp.AutoHide);
embedded.ntxui.createContextMenuItem(hMainContext, ...
    getString(message('fixed:NumericTypeScope:AutoHidePanelDialogName')), ...
    @(h,e)toggleAutoHide(dp), 'separator','on', 'checked',autoHide);
