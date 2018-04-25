function captureSystemSettings(h)
%CAPTURESYSTEMSETTINGS Captures the current system settings on the model.

%   Copyright 2010-2012 The MathWorks, Inc.


baexplr = fxptui.BAExplorer.getBAExplorer;
baexplr.refreshModelTree;
root = baexplr.getRoot;
if isa(root, 'fxptui.BAERoot')
    nodes = root.children;
else
    nodes = root;
end

hDlg = baexplr.getDialog;

for i=1:length(nodes)
    srcRoot = nodes(i);
    capturesettings(h, srcRoot, hDlg);
    srcRoot.firepropertychange;
    % refresh the tree icons
    srcRoot.firehierarchychanged;
end
if isa(hDlg,'DAStudio.Dialog');
    hDlg.enableApplyButton(true);
end;

%--------------------------------------------------
function capturesettings(h, treeNode, hDlg)

% capture settings for all non-root nodes
if ~isa(treeNode, 'fxptui.BAERoot')
    try
        sys = treeNode.TreeNode;
        if hDlg.getWidgetValue('capture_dto')
            treeNode.DataTypeOverride = sys.getsettingval('DataTypeOverride');
            treeNode.DataTypeOverrideAppliesTo = sys.getsettingval('DataTypeOverrideAppliesTo');
        end
        if hDlg.getWidgetValue('capture_instrumentation')
            treeNode.MinMaxOverflowLogging = sys.getsettingval('MinMaxOverflowLogging');
        end
    catch e %#ok
        %Ignore error
    end
end

hDlg.refresh; 

children = treeNode.getHierarchicalChildren;
for i = 1:length(children)
    capturesettings(h,children(i), hDlg);
end

%-----------------------------------------------------------
% [EOF]

% LocalWords:  fxptui BAE dto
