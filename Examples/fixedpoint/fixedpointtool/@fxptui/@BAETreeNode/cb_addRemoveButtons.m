function cb_addRemoveButtons(h, hDlg, action)
%CB_ADDREMOVEBUTTONS <short description>
%   OUT = CB_ADDREMOVEBUTTONS(ARGS) <long description>

%   Copyright 2010-2016 The MathWorks, Inc.

fpt = fxptui.FixedPointTool.getExistingInstance;
% if isempty(me); return; end
if ~isempty(fpt)
    me = fpt.getShortcutManager;
    bd = get_param(fpt.getModel,'Object');
    batchActionButtons = me.getShortcutNames;
else
    me = fxptui.getexplorer;
    bd = me.getTopNode.getDAObject;
    batchActionButtons = getShortcutsWithButtons(me);
end

customBatchNameSettingsMap = me.getCustomShortcutMapForModel;

switch (action)
    
    case 'doAddToButtonList'
        hval = hDlg.getWidgetValue('bae_buttons_table1');%hDlg.getSelectedTableRow('bae_buttons_table1');
        if isempty(hval); return; end
        baeNames = me.getShortcutsWithoutButton;
        baeName = baeNames{hval+1};
        for i = 1:length(batchActionButtons)
            if strcmp(baeName, batchActionButtons{i})
                return;
            end
        end
        
        batchActionButtons{end+1} = baeName;
        me.setShortcutButtonListForModel(batchActionButtons);
        
        hDlg.refresh;
        if isa(me.getDialog,'DAStudio.Dialog')
            me.getDialog.refresh;
        end
        cb_addRemoveButtons(h, hDlg,'doEnableDisableButtons');
        bd.Dirty = true;
        
    case 'doRemoveBAE'
        hval = hDlg.getWidgetValue('bae_buttons_table1');%hDlg.getSelectedTableRow('bae_buttons_table1');
        if isempty(hval); return; end
        if ~isempty(fpt)
            baeNames = me.getShortcutNames;
            baeName = baeNames{hval+1};
            isFactoryShortcut = me.isFactoryShortcut(baeName);
            batchActionBtns = me.getShortcutOptions;
        else
            baeNames = me.getShortcutsWithoutButton;
            baeName = baeNames{hval+1};
            isFactoryShortcut = me.isFactorySetting(baeName);
            batchActionBtns = me.BatchActionButtons;
        end
        if ~isFactoryShortcut
            BTN_YES = fxptui.message('labelYes');
            if isempty(fpt)
                BTN_TEST = me.PropertyBag.get('BTN_TEST');
                btn = fxptui.showdialog('deleteBAE', baeName, BTN_TEST);
            else
                btn = fxptui.showdialog('deleteBAE', baeName);
            end
            switch btn
                case BTN_YES
                    if customBatchNameSettingsMap.isKey(baeName)
                        customBatchNameSettingsMap.deleteDataByKey(baeName);
                        % Delete the batch actions from the table list also.
                        for i = 1:length(batchActionBtns)
                            if strcmp(baeName,batchActionButtons{i})
                                batchActionButtons(i) = [];
                                me.setShortcutButtonListForModel(batchActionButtons);
                                break;
                            end
                        end
                        if ~isempty(fpt)
                            fpt.getShortcutManager.updateCustomShortcuts(baeName, 'delete');
                        end
                    end
                otherwise
                    % Do nothing.
            end
            
            hDlg.refresh;
            cb_addRemoveButtons(h, hDlg,'doEnableDisableButtons');
        else
            fxptui.showdialog('deleteFactoryBAE');
        end
        bd.Dirty = true;
        
    case 'doUpButtonList'
        hval = hDlg.getSelectedTableRow('bae_buttons_table2');
        if isempty(hval); return; end
        if hval > 0
            baeName1 = batchActionButtons{hval+1}; % 0 index widget
            baeName2 = batchActionButtons{hval}; % name in the row above selection.
            batchActionButtons{hval} = baeName1;
            batchActionButtons{hval+1} = baeName2;
            me.setShortcutButtonListForModel(batchActionButtons);
            hDlg.selectTableRow('bae_buttons_table2', hval-1);
            hDlg.refresh;
            if isa(me.getDialog,'DAStudio.Dialog')
                me.getDialog.refresh;
            end
            cb_addRemoveButtons(h, hDlg,'doEnableDisableButtons');
        end
        bd.Dirty = true;
        
    case 'doDownButtonList'
        hval = hDlg.getSelectedTableRow('bae_buttons_table2');
        if isempty(hval); return; end
        if hval >= 0
            baeName1 = batchActionButtons{hval+1}; % 0 index widget
            baeName2 = batchActionButtons{hval+2}; % name in the row below selection.
            batchActionButtons{hval+2} = baeName1;
            batchActionButtons{hval+1} = baeName2;
            me.setShortcutButtonListForModel(batchActionButtons);
            hDlg.selectTableRow('bae_buttons_table2', hval+1);
            hDlg.refresh;
            if isa(me.getDialog,'DAStudio.Dialog')
                me.getDialog.refresh;
            end
            cb_addRemoveButtons(h, hDlg,'doEnableDisableButtons');
        end
        bd.Dirty = true;
        
    case 'doRemoveFromButtonList'
        hval = hDlg.getSelectedTableRow('bae_buttons_table2');
        if isempty(hval); return; end
        batchActionButtons(hval+1) = [];
        me.setShortcutButtonListForModel(batchActionButtons);
        hDlg.refresh;
        if isa(me.getDialog,'DAStudio.Dialog')
            me.getDialog.refresh;
        end
        cb_addRemoveButtons(h, hDlg,'doEnableDisableButtons');
        bd.Dirty = true;
        
    case 'doEnableDisableButtons'
        % Enable disable up/down buttons
        buttonList = batchActionButtons;
        rows1 = hDlg.getSelectedTableRow('bae_buttons_table2');
        %rows2 = hDlg.getWidgetValue('bae_buttons_table1');%hDlg.getSelectedTableRow('bae_buttons_table1');
        % Enable disable up/down buttons
        % Use same logic which we used for up and down move.
        tempRows = int32(rows1) - 1;
        hDlg.setEnabled('bae_up_button', isempty(find(tempRows < 0, 1)));
        hDlg.setEnabled('bae_button_remove', (rows1 > -1));
        tempRows = rows1 + 1;
        hDlg.setEnabled('bae_down_button', isempty(find(tempRows > (length(buttonList) - 1), 1)));
    otherwise
        [msg, id] = fxptui.message('unknownaction');
        error(id, msg);
end

% [EOF]
