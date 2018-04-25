function restoreSystemSettings(this)
% RESTORESYSTEMSETTINGS Retsores the DTO/MMO/Run name settings on the model
% to what was captured at launch time.

% Copyright 2016-2017 The MathWorks, Inc.

try
    [refMdls, ~] = find_mdlrefs(this.getModel);
catch  % Model not on path.
     return;
end
shortcutManager = this.getShortcutManager;

origDirty(1:length(refMdls)) = {''};
for i = 1:length(refMdls)
    origDirty{i} = get_param(refMdls{i}, 'dirty');
end
shortcutManager.applyCleanupShortcut;

for i = 1:numel(refMdls)
    if strcmp(origDirty{i}, 'off')
        set_param(refMdls{i}, 'dirty','off')
    end
end


delete(this.RestoreSettingsListener);
this.RestoreSettingsListener = [];
end
