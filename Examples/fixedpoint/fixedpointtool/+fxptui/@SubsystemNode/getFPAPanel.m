function fpaPanel = getFPAPanel(~)
% GETFPAPANEL Get the widgets for showing FPA

% Copyright 2011-2014 The MathWorks, Inc.

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
    
    button_launchfpa.Type = 'pushbutton';
    button_launchfpa.Tag = 'button_launchfpa';
    button_launchfpa.Enabled = isStartEnabled && ~inHotRestartMode;
    persistent btn_ttip;
    if isempty(btn_ttip)
        btn_ttip = fxptui.message('toolTipLAUNCHFPA');
    end
    button_launchfpa.ToolTip =  btn_ttip;
    button_launchfpa.MatlabMethod = 'fxptui.cb_launchfpa;';
    button_launchfpa.FilePath = fullfile(matlabroot, 'toolbox', 'fixedpoint', 'fixedpointtool', 'resources', 'fpca.png');
    button_launchfpa.RowSpan = [r r];
    button_launchfpa.ColSpan = [1 1];
    
    txt_launchfpa.Type = 'text';
    txt_launchfpa.Tag = 'txt_launchfpa';
    % make the variable persistent to improve performance.
    persistent fpa_name;
    if isempty(fpa_name)
        fpa_name = fxptui.message('actionLAUNCHFPA');
    end
    txt_launchfpa.Name = fpa_name;
    txt_launchfpa.RowSpan = [r r];
    txt_launchfpa.ColSpan = [2 3];
    txt_launchfpa.Enabled = isStartEnabled;
    
    pnl_launchfpa.Type = 'panel';
    pnl_launchfpa.RowSpan = [1 1];
    pnl_launchfpa.ColSpan = [1 3];
    pnl_launchfpa.LayoutGrid  = [1 3];
    pnl_launchfpa.ColStretch = [0 0 1];
    pnl_launchfpa.Items = {button_launchfpa, txt_launchfpa};
    
    fpaPanel.Type = 'group';
    fpaPanel.Tag = 'fpa_grp';
    fpaPanel.Name = fxptui.message('lblGrpFPA');
    fpaPanel.Items = {pnl_launchfpa};
    fpaPanel.LayoutGrid = [1 1];
    fpaPanel.Enabled = isStartEnabled;
    if ~isempty(me)
        fpaPanel.Visible = me.ShowFPAPanel;
    end
end

