function cb_selectRunForApply
%CB_SELECTRUNFORAPPLY Select the run contain proposals to apply them to the
%model.

%   Copyright 2011-2014 The MathWorks, Inc.

b = fxptui.checkInstall;
if ~b
    fxptui.showdialog('nofixptlicenseapply');
    return; 
end

me = fxptui.getexplorer;
if isempty(me); return; end
treenode = me.ConversionNode; 

if isempty(treenode)
    return;
end

[runNames,~] = treenode.getRunsWithProposals;
if isempty(runNames)
    % No run containing proposals.
    fxptui.showdialog('noproposeddt');
    return;
end
if length(runNames) > 1
    dlg = DAStudio.Dialog(treenode,'apply_run_selection_dialog','DLG_STANDALONE'); %#ok<NASGU>
else
    fxptui.cb_scaleapply;
end

% [EOF]
