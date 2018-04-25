function applyEmbeddedSettings(this)
% APPLYEMBEDDEDSETTINGS Changes the DTO/MMO/Run name settings on the model
% to the shortcut selected for verification

% Copyright 2016-2017 The MathWorks, Inc.

try
    [refMdls, ~] = find_mdlrefs(this.Model);
catch mdl_not_found_exception %#ok<NASGU> % Model not on path.
    return;
end
shortcutManager = this.getShortcutManager;

origDirty(1:length(refMdls)) = {''};
for i = 1:length(refMdls)
    origDirty{i} = get_param(refMdls{i}, 'dirty');
end

shortcutManager.applyVerificationShortcut;
for i = 1:numel(refMdls)
    if strcmp(origDirty{i}, 'off')
        set_param(refMdls{i}, 'dirty','off')
    end
end
this.turnOnInstrumentationAndRestoreDirty;

this.RestoreSettingsListener = addlistener(this, 'SimulationDataCompleteEvent', @(s,e)this.restoreSystemSettings);

end
