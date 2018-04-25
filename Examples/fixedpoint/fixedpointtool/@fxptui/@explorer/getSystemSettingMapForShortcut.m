function sysSettingMap = getSystemSettingMapForShortcut(me,blkSID,batchName)
% Get the setting map for a model/subsystem for a given shortcut (a.k.a
% batch action). If it doesn't exist, create one and return the map.

%   Copyright 2011-2012 MathWorks, Inc.

bd = me.getTopNode.getDAObject;

blksBatchSettingMap = getSettingsMapForShortcut(me, batchName);
if ~isempty(blksBatchSettingMap)
    % If a map to store the treeNode settings exists, retrieve it. Else,
    % create a new map.
    if blksBatchSettingMap.isKey('SystemSettingMap')    %blkHndlStr)
        settingMap = blksBatchSettingMap.getDataByKey('SystemSettingMap'); %blkHndlStr);
        if settingMap.isKey(blkSID)
            sysSettingMap = settingMap.getDataByKey(blkSID);
        else
            sysSettingMap = Simulink.sdi.Map(char('a'),?handle);
            settingMap.insert(blkSID,sysSettingMap);
        end
    else
        settingMap = Simulink.sdi.Map(char('a'),?handle);
        sysSettingMap = Simulink.sdi.Map(char('a'),?handle);
        settingMap.insert(blkSID,sysSettingMap);
        blksBatchSettingMap.insert('SystemSettingMap',settingMap);
    end
else
    % Create a BatchNameSettingMap if it doesn't exist.
    blksBatchSettingMap = Simulink.sdi.Map(char('a'), ?handle);
    
    settingMap = Simulink.sdi.Map(char('a'),?handle);
    % Create a Map to store the settings (DTO, MMO) on a treeNode.
    sysSettingMap = Simulink.sdi.Map(char('a'),?handle);
    settingMap.insert(blkSID,sysSettingMap);
    blksBatchSettingMap.insert('SystemSettingMap',settingMap);
        
    % Store the BatchNameSettingMap.
    if me.CustomBatchNameSettingsMap.isKey(bd.Handle)
        customSettingMap = me.CustomBatchNameSettingsMap.getDataByKey(bd.Handle);
        customSettingMap.insert(batchName, blksBatchSettingMap);
    else
        customSettingMap = Simulink.sdi.Map(char('a'), ?handle);
        customSettingMap.insert(batchName, blksBatchSettingMap);
    end
    me.CustomBatchNameSettingsMap.insert(bd.Handle, customSettingMap);
end
blksBatchSettingMap.insert('TopModelName',me.getTopNode.getDAObject.getFullName);

%---------------------------------------------------------------------------
% [EOF]
