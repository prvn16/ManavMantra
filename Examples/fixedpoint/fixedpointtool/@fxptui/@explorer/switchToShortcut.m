function switchToShortcut(h, key)
%SWITCHTOBATCHACTION Modify the system parameters based on the settings
%defined in the shortcut.

%   Copyright 2010-2015 The MathWorks, Inc.

% Flip all nodes in the tree to 'UseLocalSettings' before applying the
% batch action.
batchActionMap = getSettingsMapForShortcut(h,key);
hDlg = h.imme.getDialogHandle;
if hDlg.hasUnappliedChanges
    hDlg.apply;
end
try
    [refMdls, ~] = find_mdlrefs(h.getTopNode.getDAObject.getFullName);
catch mdl_not_found_exception % Model not on path.
    fxptui.showdialog('modelnotfound',mdl_not_found_exception);
    return;
end

if ~isempty(batchActionMap) 
    if batchActionMap.isKey('GlobalModelSettings')
        globalSettingsMap = batchActionMap.getDataByKey('GlobalModelSettings');
        for m = 1:globalSettingsMap.getCount
            prop = globalSettingsMap.getKeyByIndex(m);
            switch prop
                case {'CaptureDTO','CaptureInstrumentation','ModifyDefaultRun'}
                  h.(prop) = globalSettingsMap.getDataByKey(prop);
                  if strcmp(prop,'ModifyDefaultRun')
                      if globalSettingsMap.isKey('RunName')
                            h.getTopNode.getDAObject.FPTRunName = globalSettingsMap.getDataByKey('RunName');
                      end
                  end
            end
        end
    end
    changeToLocalSettings(h, h.getFPTRoot);
    if batchActionMap.isKey('SystemSettingMap')
        settingMap = batchActionMap.getDataByKey('SystemSettingMap');
        for i = 1:settingMap.getCount
            blkSID = settingMap.getKeyByIndex(i);
            try
                blkObj = get_param(Simulink.ID.getHandle(blkSID),'Object');
                if ~isempty(refMdls)
                    modelName = Simulink.ID.getModel(blkSID);
                    if sum(ismember(refMdls, modelName)) == 0
                        % this model is not part of the model ref hierarchy, do
                        % not apply these settings.
                        continue;
                    end
                end
                if isa(blkObj,'Simulink.ModelReference')
                    if ~settingMap.isKey(blkObj.ModelName)
                        continue;
                    end
                end
                
                blkSIDMap = settingMap.getDataByKey(blkSID);
                b = h.isFactorySetting(key);
                if blkSIDMap.isKey('DataTypeOverride') && h.CaptureDTO
                    set_param(blkObj.getFullName,'DataTypeOverride',blkSIDMap.getDataByKey('DataTypeOverride'));
                    if b
                        for p = 1:numel(refMdls)-1
                            set_param(refMdls{p},'DataTypeOverride',blkSIDMap.getDataByKey('DataTypeOverride'));
                        end
                    end
                    
                end
                if blkSIDMap.isKey('DataTypeOverrideAppliesTo') && h.CaptureDTO
                    set_param(blkObj.getFullName,'DataTypeOverrideAppliesTo',blkSIDMap.getDataByKey('DataTypeOverrideAppliesTo'));
                    if b
                        for p = 1:numel(refMdls)-1
                            set_param(refMdls{p},'DataTypeOverrideAppliesTo',blkSIDMap.getDataByKey('DataTypeOverrideAppliesTo'));
                        end
                    end
                end
                if blkSIDMap.isKey('MinMaxOverflowLogging') && h.CaptureInstrumentation
                    set_param(blkObj.getFullName,'MinMaxOverflowLogging',blkSIDMap.getDataByKey('MinMaxOverflowLogging'));
                    if b
                        for p = 1:numel(refMdls)-1
                            set_param(refMdls{p},'MinMaxOverflowLogging',blkSIDMap.getDataByKey('MinMaxOverflowLogging'));
                        end
                    end
                end
                if fxptui.isMATLABFunctionBlockConversionEnabled() && blkSIDMap.isKey('MLFBVariant')
                   coder.internal.MLFcnBlock.FPTSupport.overrideConvertedMATLABFunctionBlocks(modelName,blkSIDMap.getDataByKey('MLFBVariant'));
                end
            catch e
                % Blk no longer exists
                %continue;
            end
        end
    end
    % Apply changes to dialog
    hDlg = h.imme.getDialogHandle;
    if ~isempty(h.imme.getDialogHandle)
        if hDlg.hasUnappliedChanges
            hDlg.apply;
        end
        hDlg.refresh;
    end
    h.getFPTRoot.fireHierarchyChanged;
end

%---------------------------------------------------------------------
function changeToLocalSettings(me, treeNode)

try
    sys = treeNode.getDAObject.getFullName;
    if me.CaptureDTO
        set_param(sys,'DataTypeOverride','UseLocalSettings');
    end
    if me.CaptureInstrumentation
        set_param(sys,'MinMaxOverflowLogging','UseLocalSettings');
    end
catch e
    % The parameter does not exist for the Object.
end
children = treeNode.getHierarchicalChildren;
for i = 1:length(children)
    changeToLocalSettings(me,children(i));
end
% [EOF]
