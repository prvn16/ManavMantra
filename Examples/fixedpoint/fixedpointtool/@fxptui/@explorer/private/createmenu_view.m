function m = createmenu_view(h)
%CREATEMENU_VIEW

%   Copyright 2006-2014 The MathWorks, Inc.

am = DAStudio.ActionManager;
m = am.createPopupMenu(h);

% action = h.getaction('VIEW_ADVANCED_DLG');
% m.addMenuItem(action);


action = h.getaction('VIEWMANAGER_LOCK');
m.addMenuItem(action);
m.addSeparator;

action = h.getaction('VIEW_FPAPNL');
m.addMenuItem(action);

action = h.getaction('VIEW_SHORTCUTPNL');
m.addMenuItem(action);

action = h.getaction('VIEW_SYSSETTINGSPNL');
m.addMenuItem(action);
m.addSeparator;

action = h.getaction('VIEW_SHOWDYNDLGS');
m.addMenuItem(action);
m.addSeparator;

action = h.getaction('VIEW_INCREASEFONT');
m.addMenuItem(action);
action = h.getaction('VIEW_DECREASEFONT');
m.addMenuItem(action);

% [EOF]
