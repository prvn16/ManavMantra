function model_settings = getPanel_modelSettings(~)
%GETPANEL_MODELSETTINGS Get the Model Settings panel.

%   Copyright 2016 The MathWorks, Inc.

fpt = fxptui.FixedPointTool.getExistingInstance;

%===========================
% Model Settings Group
%===========================

% Model Settings - DTO Settings text
m = 1;
modelsettings_dtotxt.Type = 'text';
% make the variable persistent to improve performance.
persistent dtosettings_txt;
if isempty(dtosettings_txt)
    dtosettings_txt = sprintf('%s',fxptui.message('lblModelDTOSettings'));
end
modelsettings_dtotxt.Name = dtosettings_txt;
modelsettings_dtotxt.Tag = 'modelsettings_dtotxt';
modelsettings_dtotxt.RowSpan = [1 1];
modelsettings_dtotxt.ColSpan = [1 1];

modelsettings_dtotxt_pnl.Type = 'panel';
modelsettings_dtotxt_pnl.Items = {modelsettings_dtotxt};
modelsettings_dtotxt_pnl.RowSpan = [m m];m=m+1;
modelsettings_dtotxt_pnl.ColSpan = [1 1];
modelsettings_dtotxt_pnl.LayoutGrid = [1 1];

% Model Settings - Apply Shortcut Setting Panel

if ~isempty(fpt)
    shortcutlist = fpt.getShortcutManager.getShortcutNames;
else
    shortcutlist = {};
end

modelsettings_shortcut.Type = 'combobox';
modelsettings_shortcut.Tag = 'modelsettings_shortcut';
% make the variable persistent to improve performance.
persistent modelsettings_shortcut_txt;
if isempty(modelsettings_shortcut_txt)
    modelsettings_shortcut_txt = sprintf('%s:',fxptui.message('lblModelSettingsShortcut'));
end
modelsettings_shortcut.Name = modelsettings_shortcut_txt;
modelsettings_shortcut.Entries = shortcutlist;
modelsettings_shortcut.RowSpan = [1 1];
modelsettings_shortcut.ColSpan = [1 1];

txt3.Type = 'text';
txt3.Name = ' ';
txt3.RowSpan = [1 1];
txt3.ColSpan = [2 2];

modelsettings_apply.Type = 'pushbutton';
persistent modelsettings_apply_txt;
if isempty(modelsettings_apply_txt)
    modelsettings_apply_txt = sprintf('%s',fxptui.message('lblModelSettingsApply'));
end
modelsettings_apply.Name = modelsettings_apply_txt;
modelsettings_apply.Tag = 'modelsettings_apply_btn';
modelsettings_apply.MatlabMethod = 'applyShortcut';
modelsettings_apply.MatlabArgs  = {'%source', '%dialog'};
modelsettings_apply.RowSpan = [2 2];
modelsettings_apply.ColSpan = [2 2];

txt4.Type = 'text';
txt4.Name = ' ';
txt4.RowSpan = [2 2];
txt4.ColSpan = [3 3];

modelsettings_shortcut_pnl.Type = 'panel';
modelsettings_shortcut_pnl.Items = {modelsettings_shortcut, txt3, modelsettings_apply, txt4};
modelsettings_shortcut_pnl.RowSpan = [m m];m=m+1;
modelsettings_shortcut_pnl.ColSpan = [1 3];
modelsettings_shortcut_pnl.LayoutGrid = [2 3];
modelsettings_shortcut_pnl.ColStretch = [0 0 1];
modelsettings_shortcut_pnl.RowStretch = [0 1];

% Model Settings group
model_settings.Type = 'group';
persistent model_settings_txt;
if isempty(model_settings_txt)
    model_settings_txt = fxptui.message('lblModelSettings');
end

model_settings.Name = model_settings_txt;
model_settings.Items = {modelsettings_dtotxt_pnl, modelsettings_shortcut_pnl};
model_settings.Tag = 'model_settings_group';
model_settings.LayoutGrid = [m-1 2];

end

% LocalWords:  lbl Settigs modelsettings dtotxt btn
