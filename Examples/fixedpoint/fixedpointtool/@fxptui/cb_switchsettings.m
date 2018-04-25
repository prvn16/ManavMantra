function cb_switchsettings(~, index)
%CB_SWITCHSETTINGS <short description>
%   OUT = CB_SWITCHSETTINGS(ARGS) <long description>

%   Copyright 2010-2014 The MathWorks, Inc.


me = fxptui.getexplorer;
if isempty(me); return; end

success = loadReferencedModels(me);
if ~success; return; end;

shortcutBtns = me.getShortcutsWithButtons;

shortcutName = shortcutBtns{index};
me.switchToShortcut(shortcutName);

% [EOF]
