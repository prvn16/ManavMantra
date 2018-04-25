function cleanup(h)
% Clean up the explorer object. The results have already been deleted in
% the ModelClose callback and the root has also been unpopulated.

% Copyright 2006-2016 The MathWorks, Inc.

% In the case the FPT is deleted via a call to delete(), and the model is
% not closed, clear the results and unpopulate the root. If the model is
% closed first, the ModelClose callback takes care of cleaning up the
% explorer.

% save preferences
preferenceFile = fullfile(prefdir, 'fixedpointtoolprefs.mat');
LockColumnView = h.LockColumnView; %#ok<NASGU>
if exist(preferenceFile, 'file')
    save(preferenceFile, 'LockColumnView', '-append');
else
    save(preferenceFile, 'LockColumnView', '-v7.3');
end

% This is to handle cases where the model is closed while
% question dialogs are still up. The HG question dialogs do not
% block Simulink, and a user is free to change the model or
% close it if they please. In this case, we want to make sure
% the dialogs are closed and any code that is waiting on the
% value returned by the question dialog completes execution
% before the FPT is destroyed, otherwise it will crash MATLAB.
h.closeWarningDlgs;
h.ResultInfoController.cleanup();

if ~isempty(h.StartupObj)
    delete(h.StartupObj);
    h.StartupObj = [];
end
if ~isempty(h.BAExplorer)
    h.BAExplorer = [];
end

dlg = h.getautoscaledialog;
%make sure we're deleting an object and not an empty handle
if(isa(dlg, 'DAStudio.Dialog'))
    delete(dlg);
end

% Delete the diagnostic viewer if it exists
fpt_diagViewer = DAStudio.DiagViewer.findInstance('FPTDiagnostics');
if ~isempty(fpt_diagViewer)
    fpt_diagViewer.Visible = false;
    delete(fpt_diagViewer);
end

% Close any other DAStudio dialogs that are open
toolRoot = DAStudio.ToolRoot;
dlgs = toolRoot.getOpenDialogs;
for i = 1:length(dlgs)
    if strcmpi(dlgs(i).dialogTag,'FPT_Diff_Plot_Selector_Dialog') || ...
            strcmpi(dlgs(i).DialogTag,'Run_Selection_Proposal_Dialog') || ...
            strcmpi(dlgs(i).DialogTag,'Run_Selection_Apply_Dialog')
        delete(dlgs(i));
    end
end

allChildren = h.getFPTRoot.getModelNodes;
for idx = 1:length(allChildren)
    h.getFPTRoot.removeChild(allChildren(idx));
end

root = h.getFPTRoot;
root.unpopulate;
            
% Clear the root node map
while h.RootNode.getCount > 0
    % Always delete the first index since the map size keeps shrinking on
    % delete
    h.RootNode.deleteDataByIndex(1);
end

% Clean up listeners
delete(h.SDIListeners);
delete(h.SDIGUIListener);
delete(h.DatasetListener);
delete(h.listeners);

h.SDIListeners = [];
h.SDIGUIListener = [];
h.listeners = [];
h.DatasetListener = [];

delete(h.ExternalViewer);

if ~isempty(h.GoalSpecifier)
    h.GoalSpecifier = [];
end

delete(h.imme);
delete(h);

%-------------------------------------------------------------------------
