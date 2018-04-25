function cb_togglepanelvis(panel)
%CB_TOGGLEPANELVIS Toggles the visibility of panels in the main dialog.

%   Copyright 2011 The MathWorks, Inc.

me = fxptui.getexplorer;
switch panel
  case 'systemsettings'
    me.ShowSystemSettingsPanel = ~me.ShowSystemSettingsPanel;
  case 'shortcuts'
    me.ShowShortcutPanel = ~me.ShowShortcutPanel;
  case 'fpa'
    me.ShowFPAPanel = ~me.ShowFPAPanel;
end

if isa(me.getDialog,'DAStudio.Dialog')
    me.getDialog.refresh;
end

% [EOF]
