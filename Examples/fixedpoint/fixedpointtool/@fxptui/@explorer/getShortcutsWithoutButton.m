function baeWithoutBtn = getShortcutsWithoutButton(h)
% GETSHORTCUTSWITHOUTBUTTON Gets the shortcut names that do not have
% buttons on the main panel of the tool.

%   Copyright 2010 The MathWorks, Inc.


BAENames = h.getShortcutNames;
BAEWithButtons = h.getShortcutsWithButtons;
baeWithoutBtn = setdiff(BAENames, BAEWithButtons);

% [EOF]
