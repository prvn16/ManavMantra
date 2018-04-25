function cb_highlightdtgroup
%CB_HIGHLIGHTDTGROUP highlights all blocks that are in the same DTGroup

%   Copyright 2007 The MathWorks, Inc.

me = fxptui.getexplorer;
if slfeature('FPTWeb')
    fpt = fxptui.FixedPointTool.getExistingInstance;
    if ~isempty(fpt)
        selection = fpt.getSelectedResult;
    end
else
    if isempty(me); return; end
    selection = me.getSelectedListNodes;
end
if isempty(selection) 
    fxptui.showdialog('generalnoselection');
    return;
end
if ~selection.hasDTGroup
    return;
end

fxptds.AbstractActions.selectAndInvoke('hiliteDTGroup', selection);


% [EOF]
