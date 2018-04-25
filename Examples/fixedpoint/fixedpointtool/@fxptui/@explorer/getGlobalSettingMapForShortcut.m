function mdlSettingMap = getGlobalSettingMapForShortcut(me, batchName)
% GETGLOBALSETTINGMAPFORSHORTCUT Get the global setting map for a given
% shortcut (a.k.a batch action). If it doesn't exist, create one and return
% the map. 

%   Copyright 2011 The MathWorks, Inc.

bd = me.getFPTRoot.getDAObject;

blksBatchSettingMap = getSettingsMapForShortcut(me, batchName);
if ~isempty(blksBatchSettingMap)
    % If a map for the global settings exists, retrieve it. Else, create a
    % new map.
    if blksBatchSettingMap.isKey('GlobalModelSettings')
        mdlSettingMap = blksBatchSettingMap.getDataByKey('GlobalModelSettings');
    else
        mdlSettingMap = Simulink.sdi.Map(char('a'),?handle);
        blksBatchSettingMap.insert('GlobalModelSettings',mdlSettingMap);
    end
else
    % Create a BatchNameSettingMap if it doesn't exist.
    blksBatchSettingMap = Simulink.sdi.Map(char('a'), ?handle);
    
    % Create a Map to store the global settings on the model
    mdlSettingMap = Simulink.sdi.Map(char('a'),?handle);
    blksBatchSettingMap.insert('GlobalModelSettings',mdlSettingMap);

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
% [EOF]
