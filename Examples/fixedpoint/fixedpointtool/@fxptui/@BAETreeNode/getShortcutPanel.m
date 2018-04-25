function shortcut_panel = getShortcutPanel(this)
% GETSHORTCUTPANEL Defines the layout for the shortcut editor tab

% Copyright 2015-2016 The MathWorks, Inc.

r = 1;
isenabled = true;
BAExplorer = fxptui.BAExplorer.getBAExplorer;
me = fxptui.getexplorer;
fpt = fxptui.FixedPointTool.getExistingInstance;

batch_name.Type = 'combobox';
batch_name.Editable = true;
persistent shortcut_name;
if isempty(shortcut_name)
    shortcut_name = fxptui.message('lblShortcutName');
end
batch_name.Name = shortcut_name;
batch_name.Tag = 'batch_name_edit';
if ~isempty(BAExplorer)
    [list, value] = getShortcutList(BAExplorer);
else
    list = {};
    value = '';
end
batch_name.Value = value;
batch_name.NameLocation = 2;
batch_name.Entries = list;
if ~isempty(BAExplorer)
    batch_name.Source = BAExplorer;
end
batch_name.MatlabMethod = 'loadShortcut';
batch_name.MatlabArgs = {'%source','%dialog'};
batch_name.RowSpan = [r r];
batch_name.ColSpan = [1 1];
batch_name.Mode = 1;
batch_name.DialogRefresh = 1;
batch_name.Enabled = isenabled;
isFactoryShortcut = false;
if ~isempty(fpt)
    isFactoryShortcut = fpt.getShortcutManager.isFactoryShortcut(batch_name.Value);
elseif ~isempty(me)
    isFactoryShortcut = me.isFactorySetting(batch_name.Value);
end

txt.Type = 'text';
txt.Name = ' ';
txt.RowSpan = [r r];
txt.ColSpan = [2 2];

shortcut_btn_pnl.Type = 'panel';
shortcut_btn_pnl.Items = {batch_name,txt};
shortcut_btn_pnl.LayoutGrid = [1 2];
shortcut_btn_pnl.RowSpan = [r r];r=r+1;
shortcut_btn_pnl.ColSpan = [1 2];
shortcut_btn_pnl.ColStretch = [0 1];

%====================================================
% OPTIONS TO DISABLE CONTROLS
%===================================================
m = 1;
% Disable MMO control
log_chk.Type = 'checkbox';
log_chk.Tag = 'capture_instrumentation';
log_chk.RowSpan = [m m];m=m+1;
log_chk.ColSpan = [1 1];
if ~isempty(BAExplorer)
    log_chk.Source = BAExplorer;
    log_chk.ObjectProperty = 'CaptureInstrumentation';
end
persistent logchk_txt logchk_ttip_txt;
if isempty(logchk_txt)
    logchk_txt = fxptui.message('lblModifyMMO');
end
if isempty(logchk_ttip_txt)
    logchk_ttip_txt = fxptui.message('toolTipModifyMMO');
end
log_chk.Name = logchk_txt;
log_chk.ToolTip = logchk_ttip_txt;
log_chk.Enabled = ~isFactoryShortcut && isenabled;
log_chk.Mode = 1;
log_chk.DialogRefresh = 1;

% Disable DTO control
dto_chk.Type = 'checkbox';
dto_chk.Tag = 'capture_dto';
dto_chk.RowSpan = [m m];m=m+1;
dto_chk.ColSpan = [1 1];
if ~isempty(BAExplorer)
    dto_chk.Source = BAExplorer;
    dto_chk.ObjectProperty = 'CaptureDTO';
end
persistent dtochk_txt dtochk_ttip_txt;
if isempty(dtochk_txt)
    dtochk_txt = fxptui.message('lblModifyDTO');
end
if isempty(dtochk_ttip_txt)
    dtochk_ttip_txt = fxptui.message('toolTipModifyDTO');
end
dto_chk.Name = dtochk_txt;
dto_chk.ToolTip = dtochk_ttip_txt;
dto_chk.Enabled = ~isFactoryShortcut && isenabled;
dto_chk.Mode = 1;
dto_chk.DialogRefresh = 1;

% Disable run name control
run_selection.Type = 'checkbox';
persistent runchk_txt runchk_ttip_txt;
if isempty(runchk_txt)
    runchk_txt = fxptui.message('lblModifyRunName');
end
if isempty(runchk_ttip_txt)
    runchk_ttip_txt = fxptui.message('toolTipModifyRunName');
end
run_selection.Name = runchk_txt;
run_selection.ToolTip = runchk_ttip_txt;
run_selection.Tag = 'run_selection';
if ~isempty(BAExplorer)
    run_selection.Source = BAExplorer;
    run_selection.ObjectProperty = 'ModifyDefaultRun';
end
run_selection.RowSpan = [m m];m=m+1;
run_selection.ColSpan = [1 1];
run_selection.Mode = 1;
run_selection.DialogRefresh = 1;
run_selection.Enabled = ~isFactoryShortcut && isenabled;

% Run name editbox
run_name.Type = 'edit';
persistent runname_txt runname_ttip_txt;
if isempty(runname_txt)
    runname_txt = fxptui.message('lblRunName');
end
if isempty(runname_ttip_txt)
    runname_ttip_txt = fxptui.message('toolTipRunName');
end
run_name.Name = runname_txt;
run_name.ToolTip = runname_ttip_txt;
run_name.Tag = 'run_name_edit';
run_name.RowSpan = [m m];
run_name.ColSpan = [1 1];
if ~isempty(BAExplorer)
    run_name.Source = BAExplorer;
    run_name.ObjectProperty = 'BAERunName';
    run_name.Visible = BAExplorer.ModifyDefaultRun;
end
run_name.Mode = 1;
run_name.Enabled = run_selection.Enabled && ~strcmpi(batch_name.Value,fxptui.message('lblCreateNew'));

txt.Type = 'text';
txt.Name = ' ';
txt.RowSpan = [m m];
txt.ColSpan = [2 2];

shortcut_pnl.Type = 'panel';
shortcut_pnl.Items = {log_chk,dto_chk,run_selection,run_name,txt};
shortcut_pnl.RowSpan = [r r];r=r+1;
shortcut_pnl.ColSpan = [1 2];
shortcut_pnl.LayoutGrid = [4 2];
shortcut_pnl.ColStretch = [0 1];

%========================
% CAPTURE BUTTON WIDGET
%=======================
m = 1;
capture_btn.Type = 'pushbutton';
capture_btn.Tag = 'capture_settings_bae';
capture_btn.MatlabMethod = 'captureSystemSettings';
capture_btn.MatlabArgs = {'%source'};
persistent sshot_ttip_txt sshot_txt;
if isempty(sshot_ttip_txt)
    sshot_ttip_txt = fxptui.message('toolTipCapture');
end
capture_btn.ToolTip = sshot_ttip_txt;
capture_btn.FilePath = fullfile(matlabroot, 'toolbox', 'fixedpoint', 'fixedpointtool', 'resources','Capture.png');
capture_btn.RowSpan = [m m];
capture_btn.ColSpan = [1 1];

capture_btn_txt.Type = 'text';
capture_btn_txt.Tag = 'capture_settings_txt_bae';
if isempty(sshot_txt)
    sshot_txt = fxptui.message('lblCapture');
end
capture_btn_txt.Name = sshot_txt;
capture_btn_txt.ToolTip = sshot_ttip_txt;
capture_btn_txt.RowSpan = [m m];
capture_btn_txt.ColSpan = [2 2];

capture_pnl.Type = 'panel';
capture_pnl.Items = {capture_btn, capture_btn_txt};
capture_pnl.LayoutGrid = [1 2];
capture_pnl.RowSpan = [r r];r=r+1;
capture_pnl.ColSpan = [1 2];
capture_pnl.ColStretch = [0 1];
capture_pnl.Enabled = ~isFactoryShortcut && isenabled;

%===========================
% SELECTED SYSTEM SETTINGS
%===========================
m = 1;
[listselection, list] = this.getmmo;
cbo_log.Value = listselection;
cbo_log.Type = 'combobox';
cbo_log.Tag = 'cbo_log_save_mode';
% make the variable persistent to improve performance.
persistent log_txt;
if isempty(log_txt)
    log_txt = sprintf('%s:',fxptui.message('labelLoggingMode'));
end
cbo_log.Name = log_txt;
cbo_log.NameLocation = 2;
cbo_log.Entries = list;
if isempty(BAExplorer)
    cbo_log.Enabled = this.isdominantsystem('MinMaxOverflowLogging');
else
    cbo_log.Enabled = BAExplorer.CaptureInstrumentation && this.isdominantsystem('MinMaxOverflowLogging') ...
        && ~isFactoryShortcut && isenabled;
end
cbo_log.RowSpan = [m m];
cbo_log.ColSpan = [1 1];

txt.Type = 'text';
txt.Name = ' ';
txt.RowSpan = [m m];
txt.ColSpan = [2 2];

log_pnl.Type = 'panel';
log_pnl.Items = {cbo_log, txt};
log_pnl.RowSpan = [m m];m=m+1;
log_pnl.ColSpan = [1 2];
log_pnl.LayoutGrid = [1 2];
log_pnl.ColStretch = [0 1];% 0 1];

[listselection, list] = this.getdto;
cbo_dt.Value = listselection;
cbo_dt.Type = 'combobox';
cbo_dt.Tag = 'cbo_dt_save_mode';
% make the variable persistent to improve performance.
persistent dto_txt;
if isempty(dto_txt)
    dto_txt = sprintf('%s:',fxptui.message('labelDataTypeOverride'));
end
cbo_dt.Name = dto_txt;
cbo_dt.NameLocation = 2;
cbo_dt.Entries = list;
if isempty(BAExplorer)
    cbo_dt.Enabled = this.isdominantsystem('DataTypeOverride');
else
    cbo_dt.Enabled = BAExplorer.CaptureDTO && this.isdominantsystem('DataTypeOverride') ...
        && ~isFactoryShortcut && isenabled;
end
cbo_dt.RowSpan = [m m];
cbo_dt.ColSpan = [1 1];
cbo_dt.MatlabMethod = 'updateDTOAppliesToControl';
cbo_dt.MatlabArgs  = {'%source','%dialog'};

[listselection, list] = this.getdtoappliesto;
cbo_dt_appliesto.Value = listselection;
cbo_dt_appliesto.Type = 'combobox';
cbo_dt_appliesto.Tag = 'cbo_dt_appliesto_save_mode';
% make the variable persistent to improve performance.
persistent dto_txt_appliesto;
if isempty(dto_txt_appliesto)
    dto_txt_appliesto = sprintf('%s:',fxptui.message('labelDataTypeOverrideAppliesTo'));
end
cbo_dt_appliesto.Name = dto_txt_appliesto;
cbo_dt_appliesto.NameLocation = 2;
cbo_dt_appliesto.Entries = list;
appliesToDisablingSettings =   { fxptui.message('labelUseLocalSettings'), ...
    fxptui.message('labelForceOff'),fxptui.message('labelNotModifyDTO')}';
cbo_dt_appliesto.Visible = this.isdominantsystem('DataTypeOverride') && ~ismember(cbo_dt.Value, appliesToDisablingSettings);
cbo_dt_appliesto.Enabled = cbo_dt.Enabled;
cbo_dt_appliesto.RowSpan = [m m];
cbo_dt_appliesto.ColSpan = [2 2];

dto_pnl.Type = 'panel';
dto_pnl.Items = {cbo_dt, cbo_dt_appliesto};
dto_pnl.ColStretch = [0 1];% 0 1];
dto_pnl.RowSpan = [m m];
dto_pnl.LayoutGrid = [1 2];

settings_grp.Type = 'group';
persistent setting_grp_name;
if isempty(setting_grp_name)
    setting_grp_name = fxptui.message('lblSettingsGrp');
end
settings_grp.Name = setting_grp_name;
settings_grp.Items = {log_pnl,dto_pnl};
settings_grp.LayoutGrid = [2 2];
settings_grp.RowSpan = [r r];r=r+1;
settings_grp.ColSpan = [1 2];
settings_grp.ColStretch = [0 1];

%=================
% Shortcuts group
%=================
bae_grp.Type = 'group';
persistent bae_grp_txt;
if isempty(bae_grp_txt)
    bae_grp_txt = fxptui.message('lblConfigureShortcuts');
end
bae_grp.Name = bae_grp_txt;
bae_grp.Items = {shortcut_btn_pnl,shortcut_pnl,capture_pnl,settings_grp};
bae_grp.LayoutGrid = [r-1 2];
bae_grp.RowSpan = [1 1];
bae_grp.ColSpan = [1 2];
bae_grp.ColStretch = [0 1];

%===========================
% MANAGE SHORTCUTS GROUP
%===========================
m = 1;
button_settings = getpanel_buttonactionsettings(this);
button_settings.RowSpan = [m m];
button_settings.ColSpan = [1 2];
button_settings.ColStretch = [0 1];

grp_settings.Type = 'group';
persistent grp_setting_txt;
if isempty(grp_setting_txt)
    grp_setting_txt = fxptui.message('lblManageShortcuts');
end
grp_settings.Name = grp_setting_txt;
grp_settings.Tag = 'button_settings_group';
grp_settings.Items = {button_settings};
grp_settings.RowSpan = [2 2];
grp_settings.ColSpan = [1 2];
grp_settings.LayoutGrid = [1 2];


shortcut_panel.Type = 'panel';
shortcut_panel.LayoutGrid  = [2 2];
shortcut_panel.ColStretch = [0 1];% 0 0 1];
shortcut_panel.RowStretch = [0 1];
shortcut_panel.Items = {bae_grp, grp_settings};




