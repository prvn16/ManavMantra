function cb_highlightclientblks
%CB_HIGHLIGHTBLOCK highlights blocks connected to the Signal Object in the model
 
%   Copyright 2015-2017 The MathWorks, Inc.
 
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
 
if(isa(selection, 'fxptds.AbstractSimulinkObjectResult'))
    fxptds.AbstractActions.selectAndInvoke('hiliteClientBlocks', selection);
end
 
% LocalWords:  fxptds
