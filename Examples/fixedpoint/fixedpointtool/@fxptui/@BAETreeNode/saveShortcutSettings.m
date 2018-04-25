function [ok, errmsg] = saveShortcutSettings(this, hDlg, batchName)  %#ok<INUSL>
% SAVESHORTCUTSETTINGS Capture the settings for a shortcut from the editor
% window

%   Copyright 2010-2016 The MathWorks, Inc.

ok = true;
errmsg = '';

activeTab = hDlg.getActiveTab('shortcut_editor_tabs');

if activeTab == 1
    fpt = fxptui.FixedPointTool.getExistingInstance;
    if ~isempty(fpt)
        me = fpt.getShortcutManager;
    else
        me = fxptui.getexplorer;
    end
    baexplorer = fxptui.BAExplorer.getBAExplorer;
    
    addCustomShortcut = false;
    
    % get the name of the batch setting to be saved.
    if isempty(batchName)
        batchName = hDlg.getWidgetValue('batch_name_edit');    
    end
    
    if strcmpi(batchName,fxptui.message('lblCreateNew'))
        fxptui.showdialog('emptyshortcutname');
        return;
    end
    
    if ~isempty(fpt)
        shortcutList = me.getShortcutNames;
        if ~ismember(batchName,shortcutList)
            addCustomShortcut = true;
        end
    end
    
    if isa(baexplorer.getRoot, 'fxptui.BAERoot')
        children = baexplorer.getRoot.Children;
        for idx = 1:length(children)
            saveSystemSettings(children(idx), me, batchName);
            saveGlobalSettings(children(idx), me, batchName);
        end
    else
        saveSystemSettings(baexplorer.getRoot, me, batchName);
        saveGlobalSettings(baexplorer.getRoot, me, batchName);
    end
    
    if addCustomShortcut
        fpt.getShortcutManager.updateCustomShortcuts(batchName, 'add');
    end
    
    hDlg.refresh;
    
    mdl = baexplorer.getTopNode.daobject.getFullName;
    set_param(mdl,'Dirty','on');
end
%-----------------------------------------------------------------------
function saveSystemSettings(treeNode,me, batchName)
% Capture the blk settings
baexplorer = fxptui.BAExplorer.getBAExplorer;
topNode = baexplorer.getTopNode;

blkSID = Simulink.ID.getSID(treeNode.daobject);
settingMap = me.getSystemSettingMapForShortcut(blkSID,batchName);

for m = {'DataTypeOverride','MinMaxOverflowLogging'}
    param = m{:};
    switch param
        case 'DataTypeOverride'
            % Remove existing data if CaptureDTO is turned off.
            if ~baexplorer.CaptureDTO
                if settingMap.isKey(param)
                    settingMap.deleteDataByKey(param);
                end
                continue;
            end
        case 'MinMaxOverflowLogging'
            % Remove existing data if CaptureInstrumentation is turned off.
            if ~baexplorer.CaptureInstrumentation
                if settingMap.isKey(param)
                    settingMap.deleteDataByKey(param);
                end
                continue;
            end
    end
    % Save only dominant settings on the system
    if treeNode.isdominantsystem(param) && ~strcmpi(treeNode.(param),'UseLocalSettings')
        settingMap.insert(param,treeNode.(param));
        % Save both the daobject and the SID only for systems that have active settings.
        settingMap.insert('DAObject',treeNode.daobject);
        if isa(treeNode.daobject,'Simulink.ModelReference') ||...
                ~isequal(bdroot(treeNode.daobject.getFullName),bdroot(topNode.daobject.getFullName))
            node_parent_model = bdroot(treeNode.daobject.getFullName);
            if ~isequal(node_parent_model,topNode.daobject.getFullName)
                topCh = topNode.getChildren;
                topModelTracePath = '';
                for i = 1:length(topCh)
                    if isa(topCh(i).daobject, 'Simulink.ModelReference')
                        if isequal(topCh(i).daobject.ModelName,node_parent_model)
                            topModelTracePath = {Simulink.ID.getSID(topCh(i).daobject)};
                            break;
                        end
                    end
                end
                if isempty(topModelTracePath)
                    children = baexplorer.getRoot.getChildren;
                    modelName = node_parent_model;
                    while ~isequal(modelName, topNode.daobject.getFullName)
                        breakOuterLoop = false;
                        for i = length(children):-1:1
                            child = children(i);
                            if isequal(modelName, child.daobject.getFullName)
                                continue;
                            end
                            ch = child.getChildren;
                            for np = 1:length(ch)
                                if isa(ch(np).daobject,'Simulink.ModelReference')
                                    if isequal(ch(np).daobject.ModelName, modelName)
                                        if isempty(topModelTracePath)
                                            topModelTracePath = {Simulink.ID.getSID(ch(np).daobject)};
                                        else
                                            topModelTracePath = [topModelTracePath, {Simulink.ID.getSID(ch(np).daobject)}]; %#ok<AGROW>
                                        end
                                        modelName = bdroot(ch(np).daobject.getFullName);
                                        breakOuterLoop = true;
                                        break;
                                    end
                                end
                            end
                            if breakOuterLoop
                                break;
                            end
                        end
                    end
                end
                settingMap.insert('TopModelTracePath',topModelTracePath);
            end
        end
        settingMap.insert('SID',blkSID);
        
        if strcmpi(param,'DataTypeOverride') && ~strcmpi(treeNode.(param),'UseLocalSettings')
            settingMap.insert('DataTypeOverrideAppliesTo',treeNode.DataTypeOverrideAppliesTo)
        end
        % Remove existing data if the new value is UseLocalSettings
    elseif strcmpi(treeNode.(param),'UseLocalSettings')
        if settingMap.isKey(param)
            settingMap.deleteDataByKey(param);
        end
        % If the settingMap does not contain any data of interest, then
        % remove the DAObject and SID data as well.
        if ~settingMap.isKey('DataTypeOverride') && ~settingMap.isKey('MinMaxOverflowLogging')...
                && ~settingMap.isKey('DataTypeOverrideAppliesTo')
            if settingMap.isKey('DAObject')
                settingMap.deleteDataByKey('DAObject');
                settingMap.deleteDataByKey('SID');
                if settingMap.isKey('TopModelTracePath')
                    settingMap.deleteDataByKey('TopModelTracePath');
                end
            end
        end
    end
end
children = treeNode.getHierarchicalChildren;
% Go through the entire tree and save active settings for all the nodes.
for i = 1:length(children)
    child = children(i);
    saveSystemSettings(child, me, batchName);
end

%---------------------------------------------------------------------------------------------
function saveGlobalSettings(treeNode,me,batchName)
% Save the global data for the model. These parameters don't change per
% subsystem. Capture this data only once.

baexplr = fxptui.BAExplorer.getBAExplorer;
mdlSettingMap = me.getGlobalSettingMapForShortcut(batchName);

for m = {'DAObject','CaptureDTO','CaptureInstrumentation','ModifyDefaultRun'}
    param = m{:};
    switch param
        case 'DAObject'
            mdlSettingMap.insert(param, treeNode.daobject);
            mdlSettingMap.insert('SID',Simulink.ID.getSID(treeNode.daobject));
        otherwise
            mdlSettingMap.insert(param,baexplr.(param))
            if strcmpi(param,'ModifyDefaultRun') && baexplr.(param)
                mdlSettingMap.insert('RunName',baexplr.BAERunName); %% Need to update
            elseif strcmpi(param,'ModifyDefaultRun') && ~baexplr.(param)
                if mdlSettingMap.isKey('RunName')
                    mdlSettingMap.deleteDataByKey('RunName');
                end
            end
    end
end

%--------------------------------------------------------------------------
% [EOF]
