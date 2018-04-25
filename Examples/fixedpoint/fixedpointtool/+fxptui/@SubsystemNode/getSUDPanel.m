function grp_sud_panel = getSUDPanel(~)
% GETSUDPANEL Widgets to show and change the system selected for conversion

% Copyright 2014-2015 The MathWorks, Inc.


me = fxptui.getexplorer;
grp_sud_panel = [];
if ~isempty(me)
    inHotRestartMode = isequal(get_param(me.getFPTRoot.getHighestLevelParent,'InteractiveSimInterfaceExecutionStatus'),2);
    action = me.getaction('START');
    isenabled = false;
    if ~isempty(action)
        isenabled = isequal('on', action.Enabled)|| ~me.isSystemUnderConversionDefined && ~inHotRestartMode;
    end
    
    currentSUD = me.GoalSpecifier.getSystemForConversion;
    if isempty(currentSUD)
        sudname = me.getFPTRoot.getHighestLevelParent;
    else
        sudname = strrep(currentSUD.getFullName,char(10),'');
    end
    
    sud_name.Type = 'text';
    sud_name.Tag = 'sud_spec_sysname';
    sud_name.Name = sudname;
    if me.isSystemUnderConversionDefined
        sud_name.BackgroundColor = [0 179 0];
    end
    sud_name.RowSpan = [1 1];
    sud_name.ColSpan = [1 1];
    
    %change SUD settings:
    lnk_show.Type = 'hyperlink';
    lnk_show.Name = fxptui.message('linkChangeSUD');
    lnk_show.Tag = 'change_sud';
    lnk_show.ForegroundColor = [0 0 1];
    lnk_show.RowSpan = [2 2];
    lnk_show.ColSpan = [1 1];
    lnk_show.MatlabMethod = 'fxptui.showSUDSelector';
    lnk_show.Visible = true;
    lnk_show.ToolTip = fxptui.message('tooltipChangeSUD');
    
    confirm_txt.Type = 'text';
    confirm_txt.Tag = 'confirm_txt';
    confirm_txt.Name = fxptui.message('lblSUDInfo');
    confirm_txt.RowSpan = [1 1];
    confirm_txt.ColSpan = [1 4];
    
    sud_txt.Type = 'text';
    sud_txt.Tag = 'sud_spec_sysname';
    sud_txt.Name = sudname;
    sud_txt.RowSpan = [2 2];
    sud_txt.ColSpan = [1 1];
    % sud_txt.Bold = true;
    
    dummy_txt1.Type = 'text';
    dummy_txt1.Name = '';
    dummy_txt1.RowSpan = [3 3];
    dummy_txt1.ColSpan = [1 1];
    
    confirm_btn.Type = 'pushbutton';
    confirm_btn.Name = fxptui.message('btnContinue');
    confirm_btn.Tag = 'confirm_button';
    me = fxptui.getexplorer;
    if ~isempty(me)
        confirm_btn.MatlabMethod = 'confirmSelection';
        confirm_btn.MatlabArgs = {me};
    end
    confirm_btn.RowSpan = [3 3];
    confirm_btn.ColSpan = [2 2];
    confirm_btn.ToolTip = fxptui.message('tooltipConfirmSUD');

    change_btn.Type = 'pushbutton';
    change_btn.Name =  fxptui.message('linkChangeSUD');
    change_btn.Tag = 'change_button';
    change_btn.MatlabMethod = 'fxptui.showSUDSelector';
    change_btn.RowSpan = [3 3];
    change_btn.ColSpan = [3 3];
    change_btn.ToolTip = fxptui.message('tooltipChangeSUD');

    dummy_txt2.Type = 'text';
    dummy_txt2.Name = '';
    dummy_txt2.RowSpan = [3 3];
    dummy_txt2.ColSpan = [4 4];
    
    confirm_panel.Type = 'panel';
    confirm_panel.LayoutGrid  = [1 4];
    confirm_panel.RowSpan = [3 3];
    confirm_panel.ColSpan = [1 4];
    confirm_panel.ColStretch = [0 0 0 1];
    confirm_panel.Items = {dummy_txt1, confirm_btn, change_btn, dummy_txt2};
    
    
    sud_panel.Type = 'panel';
    sud_panel.LayoutGrid  = [3 4];
    sud_panel.RowStretch = [0 0 1];
    sud_panel.ColStretch = [0 0 0 1];
    if me.isSystemUnderConversionDefined
        sud_panel.Items = {sud_name,lnk_show};
        sud_panel.LayoutGrid  = [2 1];
        sud_panel.RowStretch = [0 1];
        sud_panel.ColStretch = 1;
    else
        sud_panel.Items = {confirm_txt,sud_txt, confirm_panel};
        sud_panel.LayoutGrid  = [3 4];
        sud_panel.RowStretch = [0 0 1];
        sud_panel.ColStretch = [0 0 0 1];
        sud_panel.BackgroundColor = [255 255 204];
    end
    
    grp_sud_panel.Name = fxptui.message('labelSUDGroup');
    grp_sud_panel.Type = 'group';
    grp_sud_panel.Tag = 'sud_grp';
    grp_sud_panel.Items = {sud_panel};
    grp_sud_panel.Enabled = isenabled;
    grp_sud_panel.LayoutGrid = [1 1];
end
