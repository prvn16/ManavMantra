function deleteShortcutEditor(~)
% DELETESHORTCUTEDITOR Deletes existing advanced settings dialog

% Copyright 2015-2016 The MathWorks, Inc.

bae = fxptui.BAExplorer.getBAExplorer;
if ~isempty(bae)
    delete(bae);
end
end
