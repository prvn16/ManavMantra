function m = createmenu_scale(h)
%CREATEMENU_DATA

%   Author(s): G. Taillefer
%   Copyright 2006-2015 The MathWorks, Inc.

am = DAStudio.ActionManager;
m = am.createPopupMenu(h);

action = h.getaction('SCALE_PROPOSEDT');
m.addMenuItem(action);

action = h.getaction('SCALE_APPLYDT');
m.addMenuItem(action);

% [EOF]
