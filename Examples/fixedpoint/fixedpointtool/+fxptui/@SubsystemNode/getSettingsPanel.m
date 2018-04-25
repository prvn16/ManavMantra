function settingsPanel = getSettingsPanel(this)
%GETSETTINGSPANEL Get the widgets for controlling the model parameters

% Copyright 2010-2014 The MathWorks, Inc.

    r = 1;
    me = fxptui.getexplorer;
    
    isStartEnabled = false;
    inHotRestartMode = false;

    if ~isempty(me)
        inHotRestartMode = isequal(get_param(me.getFPTRoot.getHighestLevelParent,'InteractiveSimInterfaceExecutionStatus'),2);
        action = me.getaction('START');
        if ~isempty(action)
            isStartEnabled = strcmp('on', action.enabled);
        end
    end
    
    [listselection, list] = this.getMMO;
    cbo_log.Value = listselection;
    cbo_log.Type = 'combobox';
    cbo_log.Tag = 'cbo_log';
    % make the variable persistent to improve performance.
    persistent log_txt;
    if isempty(log_txt)
        log_txt = fxptui.message('labelLoggingMode');
    end
    cbo_log.Name = log_txt; 
    cbo_log.NameLocation = 2;
    cbo_log.Entries = list;
    cbo_log.Enabled = this.isDominantSystem('MinMaxOverflowLogging') && isStartEnabled && ~inHotRestartMode;
    cbo_log.RowSpan = [r r];
    cbo_log.ColSpan = [1 1];
    
    txt.Type = 'text';
    txt.Name = ' ';
    txt.RowSpan = [r r];r=r+1;
    txt.ColSpan = [2 3];
    
    log_pnl.Type = 'panel';
    log_pnl.Items = {cbo_log, txt};
    log_pnl.RowSpan = [1 1];
    log_pnl.ColSpan = [1 3];
    log_pnl.LayoutGrid = [1 3];
    log_pnl.ColStretch = [ 0 0 1];
    
    [listselection, list] = this.getDTO;
    cbo_dt.Value = listselection;
    cbo_dt.Type = 'combobox';
    cbo_dt.Tag = 'cbo_dt';
    % make the variable persistent to improve performance.
    persistent dto_txt;
    if isempty(dto_txt)
        dto_txt = fxptui.message('labelDataTypeOverride');
    end
    cbo_dt.Name = dto_txt;
    cbo_dt.NameLocation = 2;
    cbo_dt.Entries = list;
    cbo_dt.Enabled = this.isDominantSystem('DataTypeOverride') && isStartEnabled && ~inHotRestartMode;
    cbo_dt.RowSpan = [r r];
    cbo_dt.ColSpan = [1 1];
    cbo_dt.MatlabMethod = 'fxptui.SubsystemNode.updateDTOAppliesToControl';
    cbo_dt.MatlabArgs  = {'%dialog'};
    
    [listselection, list] = this.getDTOAppliesTo;
    cbo_dt_appliesto.Value = listselection;
    cbo_dt_appliesto.Type = 'combobox';
    cbo_dt_appliesto.Tag = 'cbo_dt_appliesto';
    % make the variable persistent to improve performance.
    persistent dto_txt_appliesto;
    if isempty(dto_txt_appliesto)
        dto_txt_appliesto = fxptui.message('labelDataTypeOverrideAppliesTo');
    end
    cbo_dt_appliesto.Name = dto_txt_appliesto;
    cbo_dt_appliesto.NameLocation = 2;
    cbo_dt_appliesto.Entries = list;
    appliesToDisablingSettings =   { fxptui.message('labelUseLocalSettings'), ...
                        fxptui.message('labelForceOff')}';
    cbo_dt_appliesto.Visible = this.isDominantSystem('DataTypeOverride') && ~ismember(cbo_dt.Value, appliesToDisablingSettings);
    cbo_dt_appliesto.Enabled = cbo_dt.Enabled && isStartEnabled && ~inHotRestartMode; 
    cbo_dt_appliesto.RowSpan = [r r];
    cbo_dt_appliesto.ColSpan = [2 2];
    
    txt1.Type = 'text';
    txt1.Name = '';
    txt1.RowSpan = [r r];
    txt1.ColSpan = [3 3];
    
    dto_pnl.Type = 'panel';
    dto_pnl.Items = {cbo_dt, cbo_dt_appliesto, txt1};
    dto_pnl.LayoutGrid = [1 3];
    dto_pnl.ColStretch = [0 0 1];
    dto_pnl.RowSpan = [r r];
    
    % make the variable persistent to improve performance.
    persistent sys_setting_txt;
    if isempty(sys_setting_txt)
        sys_setting_txt = fxptui.message('labelSystemSettings');
    end
    settingsPanel.Name = sys_setting_txt;
    settingsPanel.Type = 'group';
    settingsPanel.Items = {log_pnl,dto_pnl};
    settingsPanel.LayoutGrid = [r 3];
    settingsPanel.RowStretch = [zeros(r-1) 1];
    settingsPanel.Tag = 'settings_grp';
    settingsPanel.ColStretch = [0 0 1];
    settingsPanel.Enabled = isStartEnabled;
    if ~isempty(me) 
        settingsPanel.Visible = me.ShowSystemSettingsPanel;
    end
end


