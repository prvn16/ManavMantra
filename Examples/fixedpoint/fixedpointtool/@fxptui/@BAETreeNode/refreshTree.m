function refreshTree(~,~, ~)
% REFRESHTREE Refresh the tree labels when the tab is changed

% Copyright 2015 The MathWorks, Inc.

baexplorer = fxptui.BAExplorer.getBAExplorer;
baexplorer.getRoot.firehierarchychanged;
dlg = baexplorer.getDialog;
if ~isempty(dlg)
    dlg.refresh;
end