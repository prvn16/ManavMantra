function shortcutButtons = getShortcutButtons(h)
%GETSHORTCUTBUTTONS Get the shortcutButtons.
%   OUT = GETSHORTCUTBUTTONS(ARGS) <long description>

%   Copyright 2011 The MathWorks, Inc.


bdroot = h.getFPTRoot.getDAObject;
if h.ButtonActionMap.isKey(bdroot.Handle)
    shortcutButtons = h.ButtonActionMap.getDataByKey(bdroot.Handle);
else
    shortcutButtons = h.getDefaultShortcutButtons;
end

% [EOF]
