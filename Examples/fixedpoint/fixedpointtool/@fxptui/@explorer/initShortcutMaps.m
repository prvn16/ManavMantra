function initShortcutMaps(h)
% INITSHORTCUTMAPS Initialize the factory and custom shortcut maps
% for a model.

%   Copyright 2010 The MathWorks, Inc.

bdroot = h.getFPTRoot.getDAObject;

initFactoryShortcutMap(h);
h.ButtonActionMap = Simulink.sdi.Map(double(1.0),?handle);
BatchActionButtons = h.getDefaultShortcutButtons;
h.ButtonActionMap.insert(bdroot.Handle,BatchActionButtons);
               
h.CustomBatchNameSettingsMap = Simulink.sdi.Map(double(1.0),?handle);
               
% [EOF]
