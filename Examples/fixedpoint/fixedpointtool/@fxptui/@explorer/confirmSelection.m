function confirmSelection(me)
% CONFIRMSELECTION Use the current SUD as the intended target for
% conversion and re-enable the UI

% Copyright 2015 The MathWorks, Inc.

me.isSUDVerified = true;
dlg = me.getDialog;
updateWorkflowActions(me)
if isa(dlg,'DAStudio.Dialog')
    dlg.restoreFromSchema;
end
