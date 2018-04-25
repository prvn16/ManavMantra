function loadShortcut(h, hDlg)
% LOADSHORTCUT Loads the settings defined in a shortcut in the shortcut
% editor.

%   Copyright 2010-2016 The MathWorks, Inc.

fpt = fxptui.FixedPointTool.getExistingInstance;
val = hDlg.getWidgetValue('batch_name_edit');
h.BAEName = val;

if ~isempty(fpt)
    me = fpt.getShortcutManager;
    b = me.isFactoryShortcut(val);
else
    me = fxptui.getexplorer;
    b = me.isFactorySetting(val);
end

list = me.getShortcutNames;
% Load the saved configuration if the Batch Name was defined previously.
if ismember(val,list)
    refreshModelTree(h);
    % Flip all nodes in the tree to 'UseLocalSettings' before applying the
    % batch action.
    batchActionMap = me.getSettingsMapForShortcut(val);
    
    if ~isempty(batchActionMap)
        if batchActionMap.isKey('GlobalModelSettings')
            mdlSettingsMap = batchActionMap.getDataByKey('GlobalModelSettings');
            % Apply the global settings defined for the model with a given
            % shortcut.
            for m = 1:mdlSettingsMap.getCount
                prop = mdlSettingsMap.getKeyByIndex(m);
                switch prop
                    case {'CaptureDTO','CaptureInstrumentation','ModifyDefaultRun'}
                        h.(prop) = mdlSettingsMap.getDataByKey(prop);
                        if strcmp(prop,'ModifyDefaultRun')
                            if mdlSettingsMap.isKey('RunName')
                                h.BAERunName = mdlSettingsMap.getDataByKey('RunName');
                            end
                        end
                end
            end
        end
        changeToLocalSettings(h, h.getRoot);
        if batchActionMap.isKey('SystemSettingMap')
            settingMap = batchActionMap.getDataByKey('SystemSettingMap');
            try
                [refMdls, ~] = find_mdlrefs(h.getTopNode.daobject.getFullName);
            catch mdl_not_found_exception % Model not on path.
                fxptui.showdialog('modelnotfound',mdl_not_found_exception);
                return;
            end
            for i = 1:settingMap.getCount
                blkSID = settingMap.getKeyByIndex(i);
                blkSettingMap = settingMap.getDataByKey(blkSID);
                % Find the node in the tree that has a block handle equal
                % to the stored block handle
                try
                    blkHndl = Simulink.ID.getHandle(blkSID);
                    blkObj = get_param(blkHndl,'Object');
                    if isa(h.getRoot, 'fxptui.BAERoot')
                        node = find(h.getRoot.Child,'daobject',blkObj);
                    else
                        node = find(h.getRoot,'daobject',blkObj);
                    end
                    % If the model that the model block is pointing to is
                    % not part of the hierarchy, then don't apply the
                    % settings.
                    if isa(blkObj,'Simulink.ModelReference')
                        if ~settingMap.isKey(blkObj.ModelName)
                            continue;
                        end
                    end
                    if ~isempty(refMdls)
                        modelName = Simulink.ID.getModel(blkSID);
                        if sum(ismember(refMdls, modelName)) == 0
                            % this model is not part of the model ref hierarchy, do
                            % not apply these settings.
                            continue;
                        end
                    end
                    if ~isempty(node) && isa(node.daobject,'DAStudio.Object')
                        % Apply captured settings for that node.
                        for m = 1:blkSettingMap.getCount
                            prop = blkSettingMap.getKeyByIndex(m);
                            switch prop
                                case {'DataTypeOverride','MinMaxOverflowLogging','DataTypeOverrideAppliesTo'}
                                    %                                     node.(prop) = blkSettingMap.getDataByKey(prop);
                                    updateProperties(node, prop, blkSettingMap.getDataByKey(prop));
                                    if b
                                        for k = 1:length(refMdls)-1
                                            submodelNode = find(h.getRoot.Child,'daobject',get_param(refMdls{k},'Object'));
                                            updateProperties(submodelNode, prop, blkSettingMap.getDataByKey(prop));
                                        end
                                    end
                            end
                        end
                    end
                catch e %#ok
                    % Could not convert the handle to the object, consume
                    % error.
                end
            end
        end
    end
    h.getDialog.refresh;
    h.getRoot.firehierarchychanged;
    % Disable the apply button to get rid of the pesky apply/ignore dialog.
    h.getDialog.enableApplyButton(false);
end

%---------------------------------------------------------------------
function changeToLocalSettings(h, treeNode)

try
    % Turn off the property listener before setting
    % the properties. Not doing so would trigger
    % another capture which is unnecessary and can
    % potentially remove some of the captured
    % settings.
    %changePropertyListenerState(treeNode, 'Off');
    if h.CaptureDTO
        treeNode.DataTypeOverride = 'UseLocalSettings';
    end
    if h.CaptureInstrumentation
        treeNode.MinMaxOverflowLogging = 'UseLocalSettings';
    end
    % Enable property listeners again.
    %changePropertyListenerState(treeNode,'On');
catch e %#ok
    % The parameter does not exist for the Object.
end
children = treeNode.getHierarchicalChildren;
for i = 1:length(children)
    changeToLocalSettings(h, children(i));
end
%---------------------------------------------------------------------


% [EOF]
