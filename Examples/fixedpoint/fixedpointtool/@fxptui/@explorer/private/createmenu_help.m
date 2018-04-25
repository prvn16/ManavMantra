function m = createmenu_help(h)
%CREATMENU_HELP   

%   Author(s): G. Taillefer
%   Copyright 2006-2012 The MathWorks, Inc.


am = DAStudio.ActionManager;
m = am.createPopupMenu(h);

action = h.getaction('HELP_FXPTTOOL');
m.addMenuItem(action);
m.addSeparator;

% Create the Fixed-Point Designer specific actions/menus if present. Don't
% check out license
if builtin('license','test','Fixed_Point_Toolbox') && ~isempty(ver('fixedpoint'))
    
    m.addSeparator;

    action = h.getaction('HELP_SLFXPT');
    m.addMenuItem(action);
    m.addSeparator;

    action = h.getaction('HELP_SLFXPTDEMOS');
    m.addMenuItem(action);
    m.addSeparator;

    action = h.getaction('HELP_ABOUTSLFXPT');
    m.addMenuItem(action);

end

% [EOF]