function batchActionButtons = getShortcutsWithButtons(h)
% GETSHORTCUTSWITHBUTTONS Get the shortcut names that have dedicated
% buttons on the main panel of the FPT dialog

%   Copyright 2011 The MathWorks, Inc.

batchActionButtons = {};
if ~isempty(h.ButtonActionMap) && h.ButtonActionMap.isKey(h.getFPTRoot.getDAObject.Handle)
    batchActionButtons = h.ButtonActionMap.getDataByKey(h.getFPTRoot.getDAObject.Handle);
end
% [EOF]
