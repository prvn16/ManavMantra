function hmenus = createNTXMenus(this)
%CREATENTXMENUS Adds menus for the NTX UI to the Framework

%   Copyright 2010-2017 The MathWorks, Inc.

hSource = this.Application.DataSource;
if isempty(hSource) || ~hSource.isDataLoaded
    ena = 'off';
else
    ena = 'on';
end
% Create Dialog Panel Menu
mDialogPanelMenu = uimgr.uimenugroup('DialogPanelMenu',1, uiscopes.message('MenuDialogPanel'));
% Add a dummy child menu so that the main menu is rendered in the
% Framework. If a menu group has no children, uimgr does not render
% it. In-order for this strategy to work with Screen Menus on MAC platforms,
% this dummy menu should always exist - we turn off its Visibility and
% HandleVisibility so that a user does not see this dummy menu. See
% (G694382)
mchild = uimgr.uimenu('Dummy Child','<empty sub-menu>');
mchild.setWidgetPropertyDefault(...
    'HandleVisibility','off', ...
    'Visible','off', ...
    'Tag','NTXDummyMenu');
mchild.Enable = ena;
mDialogPanelMenu.add(mchild);
mDialogPanelMenu.Enable = ena;

% Add a callback to the View menu in the Framework in order to add menus
% dynamically.
this.ViewMenuOpeningListener = addlistener(this.Application, ...
    'ViewMenuOpening', @(hco, ev) locCreateDynamicMenus(this));

% Add a Frequency scale menu item
mFreqMenu = uimgr.uimenugroup('VerticalUnits',3,uiscopes.message('MenuVerticalUnits'));
% Add a dummy child menu so that the main menu is rendered in the
% Framework. If a menu group has no children, uimgr does not render
% it. In-order for this strategy to work with Screen Menus on MAC platforms,
% this dummy menu should always exist - we turn off its Visibility and
% HandleVisibility so that a user does not see this dummy menu. See
% (G694382)
mchild = uimgr.uimenu('Dummy Child','<empty sub-menu>');
mchild.setWidgetPropertyDefault(...
    'HandleVisibility','off', ...
    'Visible','off', ...
    'Tag','NTXDummyMenu');
mchild.Enable = ena;
mFreqMenu.add(mchild);
mFreqMenu.Enable = ena;

hmenus =  {mDialogPanelMenu, 'Base/Menus/View';...
    mFreqMenu, 'Base/Menus/View'};

% There are a few things that need to be refactored in the future. 
% 1) The context menus need to be integrated with uimgr (G550936).
% 2) Once the context menus are integrated, dialogmgr can leverage the
%    system and add uimgr.contextmenus.
% 3) In-order to create the children of Dialog Panel & Vertical Units menu
%    groups, we had to add a callback to the View menu owned by the
%    framework. This is not the right design. However there isn't any
%    alternative (G621488). But once this geck is fixed in graphics,
%    this code will need to be revisited.

%-------------------------------------------------------------
function locCreateDynamicMenus(this)
% This is the callback that adds the below menus dynamically to the
% menu group in the Framework. These menus are created every time a user
% clicks on the "View" menu in the Framework. Adding menus dynamically when
% you have both main menus and context menus will ensure that the widgets
% always reflect the correct state of the underlying object.
% Menus added:
% 1) Options to view/hide dialogs within the panel
% 2) Auto-lock & Auto-hide the panel.
% 3) Option to control the vertical units of the Histogram Axis.

% Find the DialogMenu menu group from the View menu item.
hMgr = this.Application.UIMgr;
viewMenu = hMgr.findchild('Menus','View');

% Find all existing children and delete them before adding new menus.
mPanel = viewMenu.findchild('DialogPanelMenu');
% Turn off the visibility of the dummy sub-menu 
dMenu = findall(mPanel.WidgetHandle,'Tag','NTXDummyMenu');
if ~isempty(dMenu)
    set(dMenu,'Visible','off');
end
delete(get(mPanel.WidgetHandle,'Children'));

% Get the main Dialog presenter object
dp = this.NTExplorerObj.dp;

% Build dialog related menus. Example: show/hide dialogs.
buildContextDialogSelection(dp,mPanel.WidgetHandle);

% Build menus for the Dialog Panel. Example: Auto-hide, Lock panel.
buildPanelMenuOptions(dp, mPanel.WidgetHandle);

% Find the Vertical units menu group and delete its children before
% creating new menus.
mVertical = viewMenu.findchild('VerticalUnits');
% Turn off the visibility of the dummy sub-menu 
dMenu = findall(mVertical.WidgetHandle,'Tag','NTXDummyMenu');
if ~isempty(dMenu)
    set(dMenu,'Visible','off');
end
delete(get(mVertical.WidgetHandle,'Children'));

% Build menus for changing Y-Axis units. Example: Frequency/Count
buildVerticalUnitsMenu(this.NTExplorerObj, mVertical.WidgetHandle);

%-------------------------------
% [EOF]
