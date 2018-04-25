function panel_buttonactionsettings = getpanel_buttonactionsettings(h)
%GETPANEL_BUTTONACTIONETTINGS Get the panel_buttonactionettings.
%   OUT = GETPANEL_BUTTONACTIONETTINGS(ARGS) <long description>

%   Copyright 2010-2016 The MathWorks, Inc.


r = 1;
me = fxptui.getexplorer;
bae_pnl1 = getpanel_list1(h, me);
bae_pnl1.RowSpan = [r r];
bae_pnl1.ColSpan = [1 1];

bae_pnl2 = getpanel_table1(h, me);
bae_pnl2.RowSpan = [r r];r=r+1;
bae_pnl2.ColSpan = [2 2];

panel_buttonactionsettings.Type = 'panel';
panel_buttonactionsettings.Items = {bae_pnl1, bae_pnl2};
panel_buttonactionsettings.LayoutGrid = [r-1 2];
panel_buttonactionsettings.ColStretch = [0 1];

%------------------------------------------------------
function bae_pnl1 = getpanel_list1(h, me) %#ok
r = 1;
fpt = fxptui.FixedPointTool.getExistingInstance;
entries = {};
if ~isempty(fpt)
    entries = fpt.getShortcutManager.getShortcutNames;
elseif ~isempty(me)
    %    bae_table1.Source = me;
    entries = me.getShortcutsWithoutButton;
end

bae_table1.Type = 'listbox';
bae_table1.Tag  = 'bae_buttons_table1';
persistent bae_tbl1_txt;
if isempty(bae_tbl1_txt)
    bae_tbl1_txt = fxptui.message('lblManageList1');
end
bae_table1.Name = bae_tbl1_txt;
bae_table1.NameLocation = 2;
bae_table1.Graphical = true;
bae_table1.Entries = entries;
bae_table1.RowSpan = [r r];
bae_table1.ColSpan = [1 1];
bae_table1.AutoTranslateStrings = 0;
bae_table1.MultiSelect = false;
bae_table1.ListKeyPressCallback = @onListKeyPress;

%% Add to columns and delete columns
m = 1;
spacer_top.Type = 'panel';
spacer_top.RowSpan = [m m]; m=m+1;
spacer_top.ColSpan = [1 1];

add_button.Type = 'pushbutton';
add_button.Tag = 'bae_button_add';
persistent add_ttip_txt;
if isempty(add_ttip_txt)
    add_ttip_txt = fxptui.message('tooltipAdd');
end
add_button.ToolTip = add_ttip_txt;
add_button.FilePath = fullfile(matlabroot, 'toolbox', 'shared', 'dastudio', 'resources', 'add_row.gif');
add_button.MatlabMethod = 'cb_addRemoveButtons';
add_button.MatlabArgs = {'%source','%dialog', 'doAddToButtonList'};
add_button.RowSpan = [m m];m = m+1;
add_button.ColSpan = [1 1];
add_button.Enabled = ~isempty([bae_table1.Entries{:}]);

remove_button.Type = 'pushbutton';
remove_button.Tag = 'bae_button_remove';
persistent remove_ttip_txt;
if isempty(remove_ttip_txt)
    remove_ttip_txt = fxptui.message('tooltipRemove');
end
remove_button.ToolTip = remove_ttip_txt;
remove_button.FilePath = fullfile(matlabroot, 'toolbox', 'fixedpoint', 'fixedpointtool', 'resources', 'remove_row.png');
remove_button.MatlabMethod = 'cb_addRemoveButtons';
remove_button.MatlabArgs = {'%source','%dialog', 'doRemoveFromButtonList'};
remove_button.RowSpan = [m m];m=m+1;
remove_button.ColSpan = [1 1];

if ~isempty(fpt)
    btns = fpt.getShortcutManager.getShortcutNames;
else
    btns = me.getShortcutsWithButtons;
end
remove_button.Enabled = ~isempty(btns(:));

spacer_bottom.Type = 'panel';
spacer_bottom.RowSpan = [m m];m=m+1;
spacer_bottom.ColSpan = [1 1];

bae_configure.Type = 'panel';
if ~isempty(fpt)
    bae_configure.Visible = false;
end
bae_configure.Items = {spacer_top, add_button, remove_button, spacer_bottom};
bae_configure.LayoutGrid = [m-1 1];
bae_configure.RowStretch = [1 0 0 1];
bae_configure.RowSpan = [r r];r=r+1;
bae_configure.ColSpan = [2 2];

delete_button1.Type = 'pushbutton';
delete_button1.Tag = 'bae_button_delete';
persistent del_ttip_txt del_txt;
if isempty(del_ttip_txt)
    del_ttip_txt = fxptui.message('tooltipDelete');
end
delete_button1.ToolTip = del_ttip_txt;
if isempty(del_txt)
    del_txt = fxptui.message('lblBtnDelete');
end
%delete_button1.Name = del_txt;
delete_button1.FilePath = fullfile(matlabroot, 'toolbox', 'shared', 'dastudio', 'resources', 'TTE_delete.gif');
delete_button1.MatlabMethod = 'cb_addRemoveButtons';
delete_button1.MatlabArgs = {'%source','%dialog', 'doRemoveBAE'};
delete_button1.RowSpan = [r r];
delete_button1.ColSpan = [1 1];
delete_button1.Enabled = ~isempty([bae_table1.Entries{:}]);

delete_txt.Type = 'text';
delete_txt.Name  = '';
delete_txt.RowSpan = [r r];
delete_txt.ColSpan = [2 2];

delete_pnl.Type = 'panel';
delete_pnl.Items = {delete_button1,delete_txt};
delete_pnl.LayoutGrid = [1 2];
delete_pnl.RowSpan = [r r];
delete_pnl.ColSpan = [1 2];
delete_pnl.ColStretch = [0 1];


bae_pnl1.Type = 'panel';
bae_pnl1.Items = {bae_table1, bae_configure, delete_pnl};
bae_pnl1.LayoutGrid = [2 2];
bae_pnl1.RowSpan = [r-1 r];
bae_pnl1.ColSpan = [1 2];

%--------------------------------------------------------
function bae_pnl2 = getpanel_table1(h,me) %#ok

r = 1;
fpt = fxptui.FixedPointTool.getExistingInstance;
% Display Batch Actions that have dedicated buttons
bae_table2.Type = 'table';
bae_table2.Tag = 'bae_buttons_table2';
if ~isempty(me)
    bae_table2.Source = me;
    entries = me.getShortcutsWithButtons;
else
    entries = {};
end
persistent bae_tbl2_txt;
if isempty(bae_tbl2_txt)
    bae_tbl2_txt = fxptui.message('lblManageList2');
end
bae_table2.Name = bae_tbl2_txt;
bae_table2.NameLocation = 2;
bae_table2.Graphical = true;
bae_table2.Grid = false;
bae_table2.ColHeader = {fxptui.message('lblManageList1'),''};
bae_table2.HeaderVisibility = [0 1];
bae_table2.ReadOnlyColumns = 0;
bae_table2.MultiSelect = false;
bae_table2.Editable = true;
bae_table2.Data = entries(:);
bae_table2.Size = size(bae_table2.Data);
bae_table2.CurrentItemChangedCallback = @onTable2CurrentChanged;
bae_table2.RowSpan = [r r];r=r+1;
bae_table2.ColSpan = [1 1];
bae_table2.SelectionBehavior = 'Row';
bae_table2.AutoTranslateStrings = 0;
bae_table2.ColumnCharacterWidth = [15 2];
% Set the enabledness of the remove button based on length of the second
% table.

% pnl_txt.Type = 'text';
% pnl_txt.Name  = '';
% pnl_txt.RowSpan = [r r];
% pnl_txt.ColSpan = [2 2];

m = 1;
% table buttons to reorder
up_button.Type = 'pushbutton';
up_button.Tag = 'bae_up_button';
persistent up_ttip_txt up_txt;
if isempty(up_ttip_txt)
    up_ttip_txt = fxptui.message('tooltipMoveUp');
end
if isempty(up_txt)
    up_txt = fxptui.message('lblBtnUp');
end
up_button.ToolTip = up_ttip_txt;
%up_button.Name = up_txt;
up_button.FilePath = fullfile(matlabroot, 'toolbox', 'shared', 'dastudio', 'resources', 'move_up.gif');
up_button.MatlabMethod = 'cb_addRemoveButtons';
up_button.MatlabArgs = {'%source','%dialog', 'doUpButtonList'};
up_button.RowSpan = [m m];
up_button.ColSpan = [1 1];

down_button.Type = 'pushbutton';
down_button.Tag = 'bae_down_button';
persistent down_ttip_txt down_txt;
if isempty(down_ttip_txt)
    down_ttip_txt = fxptui.message('tooltipMoveDown');
end
if isempty(down_txt)
    down_txt = fxptui.message('lblBtnDown');
end
down_button.ToolTip = down_ttip_txt;
%down_button.Name = down_txt;
down_button.FilePath = fullfile(matlabroot, 'toolbox', 'shared', 'dastudio', 'resources', 'move_down.gif');
down_button.MatlabMethod = 'cb_addRemoveButtons';
down_button.MatlabArgs = {'%source','%dialog', 'doDownButtonList'};
down_button.RowSpan = [m m];
down_button.ColSpan = [2 2];

spacer_btn.Type = 'panel';
spacer_btn.RowSpan = [m m];
spacer_btn.ColSpan = [3 3];

up_dn_pnl.Type = 'panel';
up_dn_pnl.Items = {up_button, down_button, spacer_btn};
up_dn_pnl.LayoutGrid = [1 3];
up_dn_pnl.ColStretch = [0 0 1];
up_dn_pnl.RowSpan = [r r];
up_dn_pnl.ColSpan = [1 1];
%up_dn_pnl.ColStretch = [0 1];

bae_pnl2.Type = 'panel';
if ~isempty(fpt)
    bae_pnl2.Visible = false;
end
bae_pnl2.Items = {bae_table2, up_dn_pnl};%,pnl_txt};
bae_pnl2.LayoutGrid = [2 1];
bae_pnl2.RowSpan = [r-1 r];
bae_pnl2.ColSpan = [1 1];
%----------------------------------------------------------------------

function onTable2CurrentChanged(hDlg, ~, ~)
% Enable disable buttons
baexplr = fxptui.BAExplorer.getBAExplorer;
cb_addRemoveButtons(baexplr.getTopNode, hDlg, 'doEnableDisableButtons');

%-----------------------------------------------------------------------
function onListKeyPress(hDlg, tag, key)
% Process only del key
if strcmp(tag, 'bae_buttons_table1') && strcmp(key, 'Del')
    baexplr = fxptui.BAExplorer.getBAExplorer;
    cb_addRemoveButtons(baexplr.getTopNode,hDlg, 'doRemoveBAE');
end
%----------------------------------------------------------------------

% [EOF]
