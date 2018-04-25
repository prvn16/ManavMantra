function [list, value] = getShortcutList(h)
% GETSHORTCUTLIST   Get the list of defined shortcuts for the root model.

%   Copyright 2010-2016 The MathWorks, Inc.

fpt = fxptui.FixedPointTool.getExistingInstance;
me = fxptui.getexplorer;
if ~isempty(fpt)
    baeNames = fpt.getShortcutManager.getShortcutNames;
else
    baeNames = me.getShortcutNames;
end

list = [{fxptui.message('lblCreateNew')},baeNames];

if isempty(h.BAEName)
    value = list{1};
    h.BAEName = value;
else
    value = h.BAEName;
end

%[EOF]
