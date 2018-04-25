function batchActionMap = getSettingsMapForShortcut(h,batchactionName)
% GETSETTINGSMAPFORSHORTCUT Get the settings map for a given shortcut for
% the model root in FPT

%   Copyright 2011 The MathWorks, Inc.

bd = h.getFPTRoot.getDAObject;
batchActionMap = [];

if h.FactoryBatchNameSettingsMap.isKey(batchactionName)
    batchActionMap = h.FactoryBatchNameSettingsMap.getDataByKey(batchactionName);
elseif h.CustomBatchNameSettingsMap.isKey(bd.Handle)
    customBatchAction = h.CustomBatchNameSettingsMap.getDataByKey(bd.Handle);
    if customBatchAction.isKey(batchactionName)
        batchActionMap = customBatchAction.getDataByKey(batchactionName);
    end
end

% [EOF]
