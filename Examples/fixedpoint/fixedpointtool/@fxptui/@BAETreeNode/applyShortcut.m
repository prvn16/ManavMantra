function applyShortcut(this, hDlg)
%APPLYSHORTCUT Apply Shortcut Settings to the model

%   Copyright 2016 The MathWorks, Inc.

fpt = fxptui.FixedPointTool.getExistingInstance;

if ~isempty(fpt)
    if hDlg.hasUnappliedChanges
        hDlg.apply;
    end
    shortcutlist = fpt.getShortcutManager.getShortcutNames;
    idx = hDlg.getWidgetValue('modelsettings_shortcut');
    shortcut = shortcutlist{idx+1};
    fpt.getShortcutManager.applyShortcut(shortcut);
    this.refreshTree;
    hDlg.refresh;
    
end

end
