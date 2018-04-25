function cb_selectRunForPropose
%CB_SELECTRUNFORPROPOSE <short description>
%   OUT = CB_SELECTRUNFORPROPOSE(ARGS) <long description>

%   Copyright 2011-2014 The MathWorks, Inc.

b = fxptui.checkInstall;
if ~b
    fxptui.showdialog('nofixptlicensepropose');
    return;
end

me = fxptui.getexplorer;
if isempty(me); return; end
treenode = me.ConversionNode;
if isempty(treenode)
    return;
end

[runNames,~] = treenode.getRunsForProposal;
if length(runNames) > 1
    dlg = DAStudio.Dialog(treenode,'propose_run_selection_dialog','DLG_STANDALONE'); %#ok
else
    % If there is an existing run number associated with the run name,
    % then update the application data with that information.
    fxptui.cb_scalepropose;
end

% [EOF]
