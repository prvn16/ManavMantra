function pnl_propose = getSimplifiedProposalPanel(this, isenabled, isApplyEnabled)
% GETPROPOSEDTPANEL Get the widgets for the data type proposal panel.

% Copyright 2013-2015 The MathWorks, Inc.
   
    % get the group containing the proposal options
    scl_settings = getSimplifiedProposeOptionPanel(this, isenabled);
    prop_option_grp.Type = 'panel';
    %prop_option_grp.Name  = 'Automatic data typing for selected system';
    %prop_option_grp.Name = fxptui.message('labelAutoscaleSettings');
    prop_option_grp.Tag = 'propose_settings_group';
    prop_option_grp.Items = {scl_settings};
    r = 1;
    prop_option_grp.RowSpan = [r r]; r=r+1;
    prop_option_grp.ColSpan = [1 2];
    prop_option_grp.LayoutGrid = [1 2];
    prop_option_grp.Visible = true; %button_collapse.Visible;
    
    % Propose Button 
    button_proposeDT.Type = 'pushbutton';
    button_proposeDT.Tag = 'button_proposeDT';
    button_proposeDT.Enabled = isenabled;
    button_proposeDT.Alignment = 1;
    button_proposeDT.MatlabMethod = 'fxptui.cb_selectRunForPropose;';
    button_proposeDT.FilePath = fullfile(matlabroot, 'toolbox', 'fixedpoint', 'fixedpointtool', 'resources', 'scaleproposeDT.png');
    button_proposeDT.ToolTip = fxptui.message('tooltipSCALEPROPOSEDTPrompt');
    button_proposeDT.RowSpan = [r r];%[r-1 r-1]; %change this to last row - lastRowId 
    button_proposeDT.ColSpan = [1 1]; % column 1
    

    txt_propose.Type = 'text';
    txt_propose.Tag = 'txt_proposebutton';
    % make the variable persistent to improve performance.
    txt_propose.Name = fxptui.message('labelSCALEPROPOSEDTPrompt');
    txt_propose.ToolTip = fxptui.message('tooltipSCALEPROPOSEDTPrompt');
    txt_propose.RowSpan = [r r];
    txt_propose.ColSpan = [2 2];
    txt_propose.Enabled = isenabled;
    
    pnl_tglPropose.Type = 'panel';
    pnl_tglPropose.RowSpan = [r r]; r=r+1;
    pnl_tglPropose.ColSpan = [1 2];
    pnl_tglPropose.LayoutGrid  = [1 2];
    pnl_tglPropose.ColStretch = [0 1];
    pnl_tglPropose.Items = {button_proposeDT, txt_propose}; %, button_expand, button_collapse};

    
    button_apply.Type = 'pushbutton';
    button_apply.Tag = 'button_apply';
    button_apply.Enabled = isenabled;
    button_apply.MatlabMethod = 'fxptui.cb_selectRunForApply;';
    button_apply.ToolTip = fxptui.message('tooltipSCALEAPPLYDTPrompt');
    button_apply.FilePath = fullfile(matlabroot, 'toolbox', 'fixedpoint', 'fixedpointtool', 'resources', 'scaleapplyDT.png');
    button_apply.RowSpan = [r r];
    button_apply.ColSpan = [1 1];
    
    txt_apply.Type = 'text';
    txt_apply.Tag = 'txt_apply';
    % make the variable persistent to improve performance.
    txt_apply.Name = fxptui.message('labelSCALEAPPLYDTPrompt');
    txt_apply.ToolTip = fxptui.message('tooltipSCALEAPPLYDTPrompt');
    txt_apply.RowSpan = [r r];
    txt_apply.ColSpan = [2 2];
    txt_apply.Enabled = isApplyEnabled;
   
    pnl_apply.Type = 'panel';
    pnl_apply.RowSpan = [r r];r=r+1;
    pnl_apply.ColSpan = [1 1];
    pnl_apply.LayoutGrid  = [1 2];
    pnl_apply.ColStretch = [0 1];
    pnl_apply.Items = {button_apply, txt_apply};
       
    pnl_propose.Type = 'group';
    pnl_propose.Name = fxptui.message('labelAutoscaling');
    pnl_propose.RowSpan = [r-1 r];
    pnl_propose.ColSpan = [1 2];
    pnl_propose.LayoutGrid  = [1 2];
    pnl_propose.ColStretch = [0 1];
    pnl_propose.Enabled = isenabled;
    pnl_propose.Tag = 'datatype_settings_grp';
    pnl_propose.Items = {pnl_tglPropose, prop_option_grp, pnl_apply};
    
end
