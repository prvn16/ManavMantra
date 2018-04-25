function SEPanel = getShortcutEditorPanel(~)
% GETSHORTCUTEDITORPANEL Get the widgets for the shortcut editor panel.

%   Copyright 2013-2015 The MathWorks, Inc.

r = 1;
me = fxptui.getexplorer;
isenabled = false;
inHotRestartMode = false;

if ~isempty(me)
    inHotRestartMode = isequal(get_param(me.getFPTRoot.getHighestLevelParent,'InteractiveSimInterfaceExecutionStatus'),2);
    action = me.getaction('START');
    isenabled = false;
    if ~isempty(action)
        isenabled = isequal('on', action.Enabled);
    end
end

if ~isempty(me)
    btn_pnl = {};
    buttonList = me.getShortcutsWithButtons;
    
    for i = 1:length(buttonList)
        button{i}.Type = 'pushbutton'; %#ok<*AGROW>
        button{i}.Tag = ['button_switch_', num2str(i)];
        button{i}.Enabled = isenabled && ~inHotRestartMode;
        button{i}.MatlabMethod = 'fxptui.cb_switchsettings';
        button{i}.MatlabArgs = {'%dialog', i};
        button{i}.ToolTip = '';
        button{i}.FilePath = fullfile(matlabroot, 'toolbox', 'fixedpoint', 'fixedpointtool', 'resources','shortcut.png');
        button{i}.ColSpan = [1 1];
        txt_button{i}.ColSpan = [2 2];
        
        txt_button{i}.Type = 'text';
        txt_button{i}.Tag = ['txt_button_switch_',num2str(i)];
        bae_name = buttonList{i};
        switch bae_name
            case fxptui.message('lblDblOverride')
                txt_button{i}.Name = fxptui.message('lblDblOverride');
                button{i}.ToolTip = fxptui.message('toolTipDblOverride');
                
                txt_button{i}.ToolTip =  button{i}.ToolTip;
                
                row_span = [r r];r=r+1;
                pnl_col_span = [1 2];
            case fxptui.message('lblSglOverride')
                txt_button{i}.Name = fxptui.message('lblSglOverride');
                button{i}.ToolTip = fxptui.message('toolTipSglOverride');
                txt_button{i}.ToolTip = fxptui.message('toolTipSglOverride');
                row_span = [r r];r = r+1;
                pnl_col_span = [1 2];
            case fxptui.message('lblDTOMMOOff')
                txt_button{i}.Name = fxptui.message('lblDTOMMOOff');
                button{i}.ToolTip = fxptui.message('toolTipDTOMMOOff');
                txt_button{i}.ToolTip = fxptui.message('toolTipDTOMMOOff');
                row_span = [r r];r = r+1;
                pnl_col_span = [1 2];
            case fxptui.message('lblMMOOff')
                txt_button{i}.Name = fxptui.message('lblMMOOff');
                button{i}.ToolTip = fxptui.message('toolTipMMOOff');
                txt_button{i}.ToolTip = fxptui.message('toolTipMMOOff');
                row_span = [r r];r = r+1;
                pnl_col_span = [1 2];
            case fxptui.message('lblFxptOverride')
                
                txt_button{i}.Name = fxptui.message('lblFxptOverride');
                button{i}.ToolTip = fxptui.message('toolTipFxptOverride');
                row_span = [r r];r=r+1;
                pnl_col_span = [1 2];
                button{i}.ColSpan = [1 1];
                txt_button{i}.ColSpan = [2 2];
                
                txt_button{i}.ToolTip = button{i}.ToolTip;
            otherwise
                txt_button{i}.Name = sprintf('%s',bae_name);
                button{i}.ToolTip = fxptui.message('toolTipCustomShortcut',bae_name);
                txt_button{i}.ToolTip = fxptui.message('toolTipCustomShortcut',bae_name);
                row_span = [r r];r = r+1;
                pnl_col_span = [1 2];
        end
        button{i}.RowSpan = row_span;
        txt_button{i}.RowSpan = row_span;
        
        btn_pnl{i}.Type = 'panel';
        btn_pnl{i}.Items = [button(i), txt_button(i)];
        btn_pnl{i}.LayoutGrid = pnl_col_span;
        btn_pnl{i}.RowSpan = row_span;
        btn_pnl{i}.ColSpan = pnl_col_span;
        btn_pnl{i}.ColStretch = [zeros(1,pnl_col_span(end)-1),1];
    end
end

lnk_editor.Type = 'hyperlink';
lnk_editor.Name = fxptui.message('lblshortcuteditorlnk');
lnk_editor.Tag = 'configure_batch_settings';
lnk_editor.RowSpan = [r r];r=r+1;
lnk_editor.ColSpan = [1 1];
lnk_editor.MatlabMethod = 'fxptui.cb_createBatchExplorer';
lnk_editor.Enabled = isenabled;
lnk_editor.ToolTip = fxptui.message('tooltipShortcutEditor');


SEPanel.Type = 'group';
if ~isempty(me)
    SEPanel.Items = [btn_pnl,  {lnk_editor}];
    
else
    SEPanel.Items = {lnk_editor};
end
SEPanel.Name = fxptui.message('lblshorcutgrp');

SEPanel.LayoutGrid = [r-1 3];
SEPanel.ColStretch = [0 0 1];

SEPanel.Tag = 'shortcut_settings_grp';
SEPanel.RowStretch = [zeros(1,r-2) 1];
SEPanel.Enabled = isenabled;
if ~isempty(me)
    SEPanel.Visible = me.ShowShortcutPanel;
end
end
