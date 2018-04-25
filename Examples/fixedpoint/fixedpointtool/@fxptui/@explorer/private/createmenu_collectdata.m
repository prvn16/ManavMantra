function m = createmenu_collectdata(h)
%CREATMENU_COLLECTDATA  Creates the data collection menu. 

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.

am = DAStudio.ActionManager;
m = am.createPopupMenu(h);

action = h.getaction('START');
m.addMenuItem(action);

action = h.getaction('PAUSE');
m.addMenuItem(action);

action = h.getaction('STOP');
m.addMenuItem(action);

m.addSeparator;
action = h.getaction('DERIVE');
m.addMenuItem(action);

% [EOF]
