function simPanel = getSimPanel(~)
% GETSIMPANEL Gets the widgets on the simulation panel

%   Copyright 2006-2014 The MathWorks, Inc.

    r = 1;
    me = fxptui.getexplorer;
    simPanel = [];
    if isempty(me); return; end
    isStartEnabled = false;
    inHotRestartMode = false;
    isDerivedEnabled = false;
    if(isempty(me))
        isStartEnabled = false;
    else
        inHotRestartMode = isequal(get_param(me.getFPTRoot.getHighestLevelParent,'InteractiveSimInterfaceExecutionStatus'),2);
        action = me.getaction('START');
        if ~isempty(action)
            isStartEnabled = strcmp('on', action.enabled);
        end
        derived_action = me.getaction('DERIVE');
        if inHotRestartMode
            derived_action.Enabled = 'off';
        end
        if ~isempty(derived_action)
            isDerivedEnabled = strcmp('on', derived_action.enabled);
        end
    end

    %Edit box for specifying Run name
    edit_run_name.Type = 'edit';
    edit_run_name.Tag = 'run_name_edit';
    if ~isempty(me)
        edit_run_name.Source = me.getFPTRoot.getDAObject;
    end
    edit_run_name.ObjectProperty = 'FPTRunName';
    persistent runname_txt runname_tooltip;
    if isempty(runname_txt)
        runname_txt = fxptui.message('labelStoreRunText');
        runname_tooltip = fxptui.message('tooltipStoreRun');
    end
    edit_run_name.Name = runname_txt;
    edit_run_name.ToolTip = runname_tooltip;
    edit_run_name.RowSpan = [r r];
    edit_run_name.ColSpan = [1 2];
    edit_run_name.Enabled = isStartEnabled && ~inHotRestartMode;
    
    pnl_run_name.Type = 'panel';
    pnl_run_name.LayoutGrid  = [r 3];r=r+1;
    pnl_run_name.ColStretch = [0 0 1];
    pnl_run_name.RowStretch = [zeros(1,r-2) 1];
    pnl_run_name.Items = {edit_run_name}; 
    
    button_run.Type = 'pushbutton';
    button_run.Tag = 'button_run';
    button_run.Enabled = isStartEnabled;
    button_run.MatlabMethod = 'fxptui.cb_simulation(''start'');';
    % make the variable persistent to improve performance.
    persistent run_ttip;
    if isempty(run_ttip)
        run_ttip = fxptui.message('tooltipStart');
    end
    button_run.ToolTip = run_ttip; 
    button_run.FilePath = fullfile(matlabroot, 'toolbox', 'fixedpoint', 'fixedpointtool', 'resources', 'start.png');
    button_run.RowSpan = [r r];
    button_run.ColSpan = [1 1];
    
    txt_run.Type = 'text';
    txt_run.Tag = 'txt_run';
    % make the variable persistent to improve performance.
    persistent run_txt;
    if isempty(run_txt)
        run_txt = fxptui.message('tooltipStart');
    end
    txt_run.Name = run_txt;
    txt_run.RowSpan = [r r];r=r+1;
    txt_run.ColSpan = [2 3];
    
    if ~isempty(me)
        bd = me.getFPTRoot.getDAObject;
        if strcmpi(bd.MinMaxOverflowArchiveMode,'overwrite')
            cbo_arch.Value = 0;
        else
            cbo_arch.Value = 1;
        end
    else
        cbo_arch.Value = 0;
    end
    cbo_arch.Type = 'checkbox';
    cbo_arch.Tag = 'cbo_arch';
    cbo_arch.Name = fxptui.message('labelMergeOverwrite');
    cbo_arch.Enabled = isStartEnabled && ~inHotRestartMode;
    cbo_arch.ToolTip = fxptui.message('tooltipMergeOverwrite');
    cbo_arch.RowSpan = [r r];r=r+1;
    cbo_arch.ColSpan = [2 2];
    
    pnl_run.Type = 'panel';
    pnl_run.LayoutGrid  = [2 3];
    pnl_run.ColStretch = [0 0 1];
    pnl_run.RowStretch = [0 1];
    pnl_run.Items = {button_run, txt_run, cbo_arch};
    
    pnl_sim.Type = 'panel';
    pnl_sim.Items = {pnl_run_name, pnl_run}; 
    pnl_sim.LayoutGrid = [2 1];
    pnl_sim.RowStretch = [0 1];
    
    
    collect_derived.Type = 'pushbutton';
    collect_derived.Tag = 'collect_derived';
    collect_derived.Enabled = isStartEnabled && ~inHotRestartMode;
    collect_derived.MatlabMethod = 'fxptui.cb_rangeanalysis;';
    collect_derived.ToolTip = fxptui.message('tooltipDerive');
    collect_derived.FilePath = fullfile(matlabroot, 'toolbox', 'fixedpoint', 'fixedpointtool', 'resources', 'derived.png');
    collect_derived.RowSpan = [r r];
    collect_derived.ColSpan = [1 1];
    
    txt_derived.Type = 'text';
    txt_derived.Tag = 'txt_derived';
    % make the variable persistent to improve performance.
    persistent derive_txt;
    if isempty(derive_txt)
        derive_txt = fxptui.message('labelDeriveRange');
    end
    txt_derived.Name = derive_txt;
    txt_derived.RowSpan = [r r];
    txt_derived.ColSpan = [2 2];
    txt_derived.Enabled = isDerivedEnabled;
    
    listselection = me.DeriveChoice;
    list = {fxptui.message('labelDeriveSUD'),fxptui.message('labelDeriveModel')};
    derive_opt.Value = listselection;
    derive_opt.Type = 'combobox';
    derive_opt.Tag = 'derive_option';
    % make the variable persistent to improve performance.
    derive_opt.Entries = list;
    derive_opt.Enabled = isDerivedEnabled;
    derive_opt.RowSpan = [r r];
    derive_opt.ColSpan = [3 3];
    
    dummy_txt.Type = 'text';
    dummy_txt.Name = '';
    dummy_txt.RowSpan = [r r];
    dummy_txt.ColSpan = [4 4];
    
    pnl_derived.Type = 'panel';
    pnl_derived.Items = {collect_derived, txt_derived, derive_opt, dummy_txt};
    pnl_derived.LayoutGrid  = [1 4];
    pnl_derived.ColStretch = [0 0 0 1];
    
    
    % make the variable persistent to improve performance.
    persistent sim_setting_txt;
    if isempty(sim_setting_txt)
        sim_setting_txt = fxptui.message('labelSimulationSettings');
    end
    simPanel.Name = sim_setting_txt;
    simPanel.Type = 'group';
    simPanel.Tag = 'dcollection_settings_grp';
    simPanel.Items = {pnl_sim, pnl_derived};
    if ~isempty(me)
        simPanel.Items = [simPanel.Items]; %, {cbo_hilite}];
    end
    simPanel.LayoutGrid = [2 1];
    simPanel.RowStretch = [0 1];
    simPanel.Enabled = isStartEnabled;
    
end

