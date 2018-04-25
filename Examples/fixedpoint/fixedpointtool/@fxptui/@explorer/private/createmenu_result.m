function m = createmenu_result(h)
%CREATEMENU_RESULT Creates the Result menu

%   Copyright 2006-2014 The MathWorks, Inc.

am = DAStudio.ActionManager;
m = am.createPopupMenu(h);

action = h.getaction('VIEW_RUNCOMPARE');
m.addMenuItem(action);

action = h.getaction('VIEW_DIFFINFIGURE');
m.addMenuItem(action);

action = h.getaction('VIEW_TSINFIGURE');
m.addMenuItem(action);

action = h.getaction('VIEW_HISTINFIGURE');
m.addMenuItem(action);
m.addSeparator;

action = h.getaction('HILITE_BLOCK');
m.addMenuItem(action);

action = h.getaction('HILITE_DTGROUP');
m.addMenuItem(action);

action = h.getaction('HILITE_CLEAR');
m.addMenuItem(action);

action = h.getaction('VIEW_RESULT_ISSUE_HIGHLIGHT');
m.addMenuItem(action);
m.addSeparator;


% [EOF]
