function customBatchActionMap = getCustomShortcutMapForModel(h)
% GETCUSTOMSHORTCUTMAPFORMODEL Get the custom shortcut map for the root
% model in FPT.

%   Copyright 2011 The MathWorks, Inc.

bd = h.getFPTRoot.getDAObject;
if h.CustomBatchNameSettingsMap.isKey(bd.Handle)
    customBatchActionMap = h.CustomBatchNameSettingsMap.getDataByKey(bd.Handle);
else
    customBatchActionMap = Simulink.sdi.Map(char('a'), ?handle);
    h.CustomBatchNameSettingsMap.insert(bd.Handle,customBatchActionMap)
end
% [EOF]
