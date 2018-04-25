function createmenu(h)
%CREATEMENU   

%   Author(s): G. Taillefer
%   Copyright 2006-2013 MathWorks, Inc.

am = DAStudio.ActionManager;

m = createmenu_file(h);
am.addSubMenu(h, m, fxptui.message('menuFile'));

m = createmenu_collectdata(h);
am.addSubMenu(h, m, fxptui.message('menuDataCollection'));

m = createmenu_scale(h);
am.addSubMenu(h, m, fxptui.message('menuAutoscaling'));

m = createmenu_result(h);
am.addSubMenu(h, m, fxptui.message('menuResults'));

m = createmenu_runs(h);
am.addSubMenu(h, m, fxptui.message('menuRun'));

m = createmenu_view(h);
am.addSubMenu(h, m, fxptui.message('menuView'));

m = createmenu_tools(h);
am.addSubMenu(h, m, fxptui.message('menuTools'));

m = createmenu_help(h);
am.addSubMenu(h, m, fxptui.message('menuHelp'));

% [EOF]
