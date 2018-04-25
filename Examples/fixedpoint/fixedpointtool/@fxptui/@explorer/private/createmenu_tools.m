function m = createmenu_tools(h)
%CREATMENU_TOOLS   

%   Copyright 2006-2015 The MathWorks, Inc.

am = DAStudio.ActionManager;
m = am.createPopupMenu(h);

action = h.getaction('LAUNCHFPA');
m.addMenuItem(action);

if fxptui.isMATLABFunctionBlockConversionEnabled()
    action = h.getaction('OPEN_CODE_VIEW');
    m.addMenuItem(action);
end

m.addSeparator;

action = h.getaction('TOOLS_PROMPT_DLG_REPLACE');
m.addMenuItem(action);

% [EOF]
