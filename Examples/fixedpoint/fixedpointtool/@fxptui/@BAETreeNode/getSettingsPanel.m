function settings_panel = getSettingsPanel(this)
%GETSETTINGSPANEL Get the widgets for controlling the model parameters

% Copyright 2015-2016 The MathWorks, Inc.

m = 1;

baexplorer = fxptui.BAExplorer.getBAExplorer;
rootNode = baexplorer.getRoot;
modelName = rootNode.daobject.getFullName;

%===========================
% Subsystem Settings group
%===========================
r = 1;

inHotRestartMode = isequal(get_param(modelName,'InteractiveSimInterfaceExecutionStatus'),2);

% Subsystem Settings - Selected system under design panel
subsystem_label.Type = 'text';
% make the variable persistent to improve performance.
persistent subsystem_label_txt;
if isempty(subsystem_label_txt)
    subsystem_label_txt = sprintf('%s:',fxptui.message('lblSelectedSubsystem'));
end
subsystem_label.Tag = 'selected_subsystem_label';
subsystem_label.Name = subsystem_label_txt;
subsystem_label.Value = subsystem_label_txt;
subsystem_label.RowSpan = [1 1];
subsystem_label.ColSpan = [1 1];

selectedSubsystem = this.getDisplayLabel;
selected_subsystem.Type = 'text';
selected_subsystem.Tag = 'selected_subsystem';
selected_subsystem.Name = selectedSubsystem;
selected_subsystem.RowSpan = [1 1];
selected_subsystem.ColSpan = [2 2];

selectedsubsystem_pnl.Type = 'panel';
selectedsubsystem_pnl.Items = {subsystem_label, selected_subsystem};
selectedsubsystem_pnl.RowSpan = [r r];r=r+1;
selectedsubsystem_pnl.ColSpan = [1 2];
selectedsubsystem_pnl.LayoutGrid = [1 2];
selectedsubsystem_pnl.ColStretch = [0 1];

% Subsystem MMO Settings
[listselection, list] = this.getMMOSetting;
cbo_log.Value = listselection;
cbo_log.Type = 'combobox';
cbo_log.Tag = 'cbo_log';
% make the variable persistent to improve performance.
persistent log_txt;
if isempty(log_txt)
    log_txt = sprintf('%s:',fxptui.message('labelLoggingMode'));
end
cbo_log.Name = log_txt;
cbo_log.NameLocation = 2;
cbo_log.Entries = list;
cbo_log.Enabled = this.isDominantSystemForSetting('MinMaxOverflowLogging') && ~inHotRestartMode;
cbo_log.RowSpan = [r r];
cbo_log.ColSpan = [1 1];

txt.Type = 'text';
txt.Name = ' ';
txt.RowSpan = [r r];
txt.ColSpan = [2 3];

log_pnl.Type = 'panel';
log_pnl.Items = {cbo_log, txt};
log_pnl.RowSpan = [r r];r=r+1;
log_pnl.ColSpan = [1 3];
log_pnl.LayoutGrid = [1 3];
log_pnl.ColStretch = [0 0 1];

[listselection, list] = this.getDTOSetting;
cbo_dt.Value = listselection;
cbo_dt.Type = 'combobox';
cbo_dt.Tag = 'cbo_dt';
% make the variable persistent to improve performance.
persistent dto_txt;
if isempty(dto_txt)
    dto_txt = sprintf('%s:',fxptui.message('labelDataTypeOverride'));
end
cbo_dt.Name = dto_txt;
cbo_dt.NameLocation = 2;
cbo_dt.Entries = list;
cbo_dt.Enabled = this.isDominantSystemForSetting('DataTypeOverride') && ~inHotRestartMode;
cbo_dt.RowSpan = [r r];
cbo_dt.ColSpan = [1 1];
cbo_dt.MatlabMethod = 'fxptui.SubsystemNode.updateDTOAppliesToControl';
cbo_dt.MatlabArgs  = {'%dialog'};

[listselection, list] = this.getDTOAppliesToSetting;
cbo_dt_appliesto.Value = listselection;
cbo_dt_appliesto.Type = 'combobox';
cbo_dt_appliesto.Tag = 'cbo_dt_appliesto';
% make the variable persistent to improve performance.
persistent dto_txt_appliesto;
if isempty(dto_txt_appliesto)
    dto_txt_appliesto = sprintf('%s:',fxptui.message('labelDataTypeOverrideAppliesTo'));
end
cbo_dt_appliesto.Name = dto_txt_appliesto;
cbo_dt_appliesto.NameLocation = 2;
cbo_dt_appliesto.Entries = list;
appliesToDisablingSettings =   { fxptui.message('labelUseLocalSettings'), ...
    fxptui.message('labelForceOff')}';
cbo_dt_appliesto.Visible = this.isDominantSystemForSetting('DataTypeOverride') && ~ismember(cbo_dt.Value, appliesToDisablingSettings);
cbo_dt_appliesto.Enabled = cbo_dt.Enabled && ~inHotRestartMode;
cbo_dt_appliesto.RowSpan = [r r];
cbo_dt_appliesto.ColSpan = [2 2];

txt1.Type = 'text';
txt1.Name = '';
txt1.RowSpan = [r r];
txt1.ColSpan = [3 3];

dto_pnl.Type = 'panel';
dto_pnl.Items = {cbo_dt, cbo_dt_appliesto, txt1};
dto_pnl.LayoutGrid = [1 3];
dto_pnl.RowSpan = [r r];r=r+1;
dto_pnl.ColSpan = [1 3];
dto_pnl.ColStretch = [0 0 1];

txt2.Type = 'text';
txt2.Name = '';
txt2.RowSpan = [r r];r=r+1;
txt2.ColSpan = [1 3];

% Subsystem Settings group
subsystem_settings.Type = 'group';
persistent subsystem_settings_txt;
if isempty(subsystem_settings_txt)
    subsystem_settings_txt = fxptui.message('lblSubsystemSettings');
end
subsystem_settings.Name = subsystem_settings_txt;
subsystem_settings.Tag = 'subsystem_settings_group';
subsystem_settings.Items = {selectedsubsystem_pnl, log_pnl, dto_pnl, txt2};
subsystem_settings.LayoutGrid = [r-1 3];
subsystem_settings.RowSpan = [m m];m=m+1;
subsystem_settings.ColSpan = [1 1];
subsystem_settings.ColStretch = [0 0 1];
subsystem_settings.RowStretch = [zeros(1, r-2), 1];

% Model Settings group
items = {subsystem_settings};
if slfeature('FPTWeb')
    model_settings = this.getPanel_modelSettings;
    model_settings.RowSpan = [m m];m=m+1;
    model_settings.ColSpan = [1 1];
    items = [items {model_settings}];
end

% Empty test panel
txt3.Type = 'text';
txt3.Name = ' ';
txt3.RowSpan = [m m];m=m+1;
txt3.ColSpan = [1 2];

items = [items {txt3}];

%===========================
% System Settings Panel
%===========================

settings_panel.Type = 'panel';
settings_panel.Tag = 'settings_grp';
settings_panel.Items = items;
settings_panel.LayoutGrid  = [m-1 1];
settings_panel.RowStretch = [zeros(1, m-2), 1];

% LocalWords:  lbl Settigs modelsettings btn grp FPT
