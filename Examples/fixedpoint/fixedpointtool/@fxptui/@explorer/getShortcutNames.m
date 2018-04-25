function list = getShortcutNames(h)
% GETSHORTCUTNAMES Get the Shortcut names for the root model in the
% explorer. 

%   Copyright 2010 The MathWorks, Inc.


factory_names = {};
custom_names = {};

for i = 1: h.FactoryBatchNameSettingsMap.getCount
   factory_names{i} = h.FactoryBatchNameSettingsMap.getKeyByIndex(i);
end

if h.CustomBatchNameSettingsMap.isKey(h.getFPTRoot.getDAObject.Handle)
    customShortcutSettings = h.CustomBatchNameSettingsMap.getDataByKey(h.getFPTRoot.getDAObject.Handle);
    for i = 1: customShortcutSettings.getCount
        custom_names{i} = customShortcutSettings.getKeyByIndex(i);
    end
end
list = [factory_names custom_names];


% [EOF]
