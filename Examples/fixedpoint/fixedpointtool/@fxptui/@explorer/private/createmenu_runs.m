function m = createmenu_runs(h)
%CREATEMENU_RUNS Creates the Run menu.

%   Copyright 2010 The MathWorks, Inc.

am = DAStudio.ActionManager;
m = am.createPopupMenu(h);

action = h.getaction('RESULTS_CLEARSELRUN');
m.addMenuItem(action);

action = h.getaction('RESULTS_CLEARALLRUN');
m.addMenuItem(action);

%------------------------------------------------------------------------
% [EOF]
    
