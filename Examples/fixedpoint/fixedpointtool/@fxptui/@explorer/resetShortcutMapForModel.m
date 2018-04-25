function resetShortcutMapForModel(h)
% RESETSHORTCUTMAPFORMODEL Refreshes the shortcut maps for the model.
%   OUT = RESETBATCHACTIONMAPFORMODEL(ARGS) <long description>

%   Copyright 2011 The MathWorks, Inc.


bd = h.getFPTRoot.getDAObject;
% Initialize the factory shortcuts for this model.
initFactoryShortcutMap(h);
if ~isempty(h.ButtonActionMap) && ~h.ButtonActionMap.isKey(bd.Handle)
    BatchActionButtons = h.getDefaultShortcutButtons;
    h.ButtonActionMap.insert(bd.Handle,BatchActionButtons);
end
% [EOF]
