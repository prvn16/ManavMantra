function dlgstruct = getDialogSchema(this, ~)
%GETDIALOGSCHEMA Get the dialog information.
%   OUT = GETDIALOGSCHEMA(ARGS) Define the dialog layout of the advanced settings UI

%   Copyright 2010-2016 The MathWorks, Inc.

fpt = fxptui.FixedPointTool.getExistingInstance;
me = fxptui.getexplorer;

settings_grp = this.getSettingsPanel;

tab1.Name = fxptui.message('lblSystemSettings');
tab1.Tag = 'system_settings_tab';
tab1.Items = {settings_grp};

if ~isempty(fpt) || ~isempty(me)
    shortcut_grp = this.getShortcutPanel;
    
    tab2.Name = fxptui.message('lblShortcuts');
    tab2.Tag = 'Shortcut_tab';
    tab2.Items = {shortcut_grp};
end

tab_cont.Type = 'tab';
tab_cont.Name = '';
tab_cont.Tag = 'shortcut_editor_tabs';
tab_cont.Tabs = {tab1};
if ~isempty(fpt) || ~isempty(me)
    tab_cont.Tabs = [tab_cont.Tabs {tab2}];
end
tab_cont.TabChangedCallback = 'fxptui.BAETreeNode.refreshTree';

dlgstruct.Items = {tab_cont};
dlgstruct.DialogTitle = '';
dlgstruct.DialogTag = 'Batch_Action_Editor_Dialog';
dlgstruct.EmbeddedButtonSet = {'Apply','Help'};
dlgstruct.PreApplyMethod   = 'setPropertyValues';
dlgstruct.PreApplyArgsDT = {'handle'};
dlgstruct.PreApplyArgs = {'%dialog'};
dlgstruct.PostApplyMethod = 'saveShortcutSettings';
dlgstruct.PostApplyArgs = {'%dialog', ''};
dlgstruct.PostApplyArgsDT = {'handle', 'string'};
dlgstruct.HelpMethod = 'helpview';
dlgstruct.HelpArgs = {[docroot '/toolbox/simulink/csh/blocks/fxptui.BAETreeNode.Batch_Action_Editor_Dialog.map'],'shortcut_help_button'};

% [EOF]
