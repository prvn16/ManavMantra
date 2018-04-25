function setShortcutButtonListForModel(h, BatchActionButtons)
% SETSHORTCUTBUTTONLISTFORMODEL Set the list of shortcut buttons into the
% map for the model. These buttons will show up in the shortcut panel of
% the dialog.

%   Copyright 2011 The MathWorks, Inc.

h.ButtonActionMap.insert(h.getFPTRoot.getDAObject.Handle,BatchActionButtons);
% [EOF]
