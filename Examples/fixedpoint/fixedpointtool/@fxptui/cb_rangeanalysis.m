function cb_rangeanalysis
%CB_RANGEANALYSIS

%   Copyright 2010-2016 The MathWorks, Inc.

b = fxptui.checkInstall;
if ~b
    fxptui.showdialog('nofixptlicensederived');
    return;
end

me = fxptui.getexplorer;
treenode = initui(me);
if(isempty(treenode)); return; end 

% Put the explorer to sleep.
me.sleep;

topMdlObj = me.getTopNode.getDAObject;
topMdlName = topMdlObj.getFullName;

selectedRunName = me.getTopNode.getDAObject.FPTRunName;

mdlRefTargetType = get_param(topMdlName, 'ModelReferenceTargetType');
targetName = slprivate('perf_logger_target_resolution', mdlRefTargetType, topMdlName, false, false);
PerfTools.Tracer.logSimulinkData('Range Analysis For Autoscaling', ...
                                   topMdlName, ...
                                   targetName, ...
                                   'CB Range Analysis', ...
                                   true);

cleanupObj = onCleanup(@() PerfTools.Tracer.logSimulinkData('Range Analysis For Autoscaling', ...
                                                  topMdlName, ...
                                                  targetName, ...
                                                  'CB Range Analysis', ...
                                                  false));

me.HasCompletedDataCollection = false;
try
    % This flag is used to decide if the pause & stop buttons need to be
    % enabled/disabled in the Start & Stop EngineCallbacks that gets
    % triggered when analysis is performed.
    me.isBeingDerived = true;
    SimulinkFixedPoint.Autoscaler.collectModelDerivedRange(treenode.getDAObject, selectedRunName);
catch fpt_exception
    % showdialog can throw an error in testing mode. catch this error, restore
    % the UI and then rethrow the error.
    try
        fxptui.showdialog('staticrangefailed',fpt_exception);
    catch fpt_exception
        restoreui(me, treenode);
        rethrow(fpt_exception);
    end
    restoreui(me, treenode);
    return;
end

try
    SimulinkFixedPoint.Autoscaler.collectModelCompiledDesignRange(treenode.getDAObject, selectedRunName);
catch fpt_exception
    % showdialog can throw an error in testing mode. catch this error, restore
    % the UI and then rethrow the error.
    try
        fxptui.showdialog('compileddesignminmaxfailed',fpt_exception);
    catch fpt_exception
        restoreui(me, treenode);
        rethrow(fpt_exception);
    end
    restoreui(me, treenode);
    return;
end

% merge results from model references instances
try
    SimulinkFixedPoint.ApplicationData.doPostRangeCollectionTasks(treenode.getDAObject, selectedRunName); 
catch e
    restoreui(me, treenode);
    rethrow(e);
end

% if treenode is not top node, perform the merge from sub-model to block
try
    curRootName = treenode.getHighestLevelParent;
    if ~strcmp(topMdlName, curRootName)
        SimulinkFixedPoint.ApplicationData.updateResultsInModelsBlocks(topMdlName, selectedRunName);
    end
catch e
    restoreui(me, treenode);
    rethrow(e);
end

me.HasCompletedDataCollection = true;
highlightAndRestoreUI(me, treenode, topMdlName, targetName)

%--------------------------------------------------------------------------
function highlightAndRestoreUI(me, treenode, topMdlName, targetName)
PerfTools.Tracer.logSimulinkData('Range Analysis For Autoscaling', ...
                                   topMdlName, ...
                                   targetName, ...
                                   'UI Update', ...
                                   true);
cleanupObj = onCleanup(@() PerfTools.Tracer.logSimulinkData('Range Analysis For Autoscaling', ...
                                                  topMdlName, ...
                                                  targetName, ...
                                                  'UI Update', ...
                                                  false));

fxptui.cb_togglehighlight;
restoreui(me, treenode);

%--------------------------------------------------------------------------
function treenode = initui(me)

%apply changes before running the analysis
if(~isempty(me.imme.getDialogHandle)&& me.imme.getDialogHandle.hasUnappliedChanges)
    me.imme.getDialogHandle.apply;
end

treenode = me.getSystemForDerive;

if isempty(treenode); return; end

success = loadReferencedModels(me);
if ~success; treenode = [];return; end

% If the selected node is an unsupported node for actions in a tree (state,
% mdlref block), then perform the action on the selected nodes' parent.
treenode = getSupportedParentTreeNode(treenode);
if isempty(treenode); return; end

% This flag is used to decide if the pause & stop buttons need to be
% enabled/disabled in the Start & Stop EngineCallbacks that gets
% triggered when analysis is performed.

me.isBeingDerived = true;

allDS = me.getAllDatasets;
for idx = 1:length(allDS)
    ds = allDS{idx};
    runObj = ds.getRun(me.getTopNode.getDAObject.FPTRunName); 
    runObj.deleteInvalidResults();
    runObj.cleanupOnDerivation; 
end


%disable all actions in the ui
me.setallactions('off');
%update selected system's dialog - we just disabled all actions
treenode.firePropertyChanged;

%suppress progressbar in BAT
if(~me.istesting)
    me.progressbar = fxptui.createprogressbar(me,fxptui.message('labelANALYZERANGE'));
end

%--------------------------------------------------------------------------
function restoreui(me, treenode)
% update the list view based on filter selection

% Set the suggested mode before waking FPT. Not doing so will give an
% incorrect suggestion.
vm = me.getViewManager;
if ~isempty(vm)
    if hasSimMinMax(me)
        FPTView = vm.getView(fxptui.message('labelViewDataCollection'));
        vm.SuggestedViewName = 'data_collection';
    else
        FPTView = vm.getView(fxptui.message('labelViewDerivedMinMax'));
        vm.SuggestedViewName = 'derived_view';
    end
end

me.wake;
me.isBeingDerived = false;

me.restoreactionstate;
me.updateactions;

if ~me.LockColumnView && ~isempty(FPTView)
    vm.ActiveView = FPTView;
end

% Refresh any existing grouping or changes to MATLAB hierarchy
treenode.fireHierarchyChanged;

me.refreshDetailsDialog;
% backtrace is changed in the engine initialize callback of the @explorer
% class. This is triggered when the model is compiled.
state = me.userdata.warning.backtrace.state;
warning(state, 'backtrace');
if(~me.istesting && ~isempty(me.progressbar))
    me.progressbar.dispose;
end
beep;


%--------------------------------------------------------------------------
% [EOF]
