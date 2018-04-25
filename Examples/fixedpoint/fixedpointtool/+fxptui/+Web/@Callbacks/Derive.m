function Derive(clientData)
% DERIVE Performs range analysis on the input scope which can be either the
% SUD or the model.

% Copyright 2015-2018 The MathWorks, Inc.

% ClientData is a structure containing a "scope" nested structure

fptInstance = fxptui.FixedPointTool.getExistingInstance;
scope = clientData.scope;
runName = clientData.runName;

if isempty(fptInstance)
    return
end

shortcutManager = fptInstance.getShortcutManager;
b = fxptui.checkInstall;
if ~b
    fxptui.showdialog('nofixptlicensederived');
    return;
end

% re-populate the referenced models if they were previously closed
success = fptInstance.loadReferencedModels;
if ~success
    return; 
end

topMdlName = fptInstance.getModel;
% g1696210 - FPT should throw an error when the model is
% locked and should not hang
[success, dlgType] = fxptui.verifyModelState(topMdlName);
if ~success
    fxptui.showdialog(dlgType);
    return;
end
if scope.SUD
    system =  fptInstance.getSystemForConversion;
else
    system = topMdlName;
end
if isempty(system)
    fxptui.showdialog('invalidSUD');
    return;
end
accelModeHandler = fxptui.Web.AccelModeHandler(topMdlName);

sysObj = get_param(system, 'Object');

fptInstance.applyIdealizedSettings;
fxptui.Web.Callbacks.changeRunNameAndRestoreDirty(topMdlName, runName);
shortcutManager.setLastUsedIdealizedShortcut(shortcutManager.getIdealizedBehaviorShortcut);

selectedRunName = get_param(topMdlName, 'FPTRunName');

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

% Disable code view
fptInstance.enableCodeView(false);
accelModeHandler.switchToNormalMode;

try
    % This flag is used to decide if the pause & stop buttons need to be
    % enabled/disabled in the Start & Stop EngineCallbacks that gets
    % triggered when analysis is performed.
    SimulinkFixedPoint.Autoscaler.collectModelDerivedRange(sysObj, selectedRunName);
catch fpt_exception
    % showdialog can throw an error in testing mode. catch this error, restore
    % the UI and then rethrow the error.
    fptInstance.restoreSystemSettings;
    
    accelModeHandler.restoreSimulationMode;
    
    try
        fxptui.showdialog('staticrangefailed',fpt_exception);
        fptInstance.reEnableUI('');
    catch fpt_exception
        fptInstance.reEnableUI('');
        rethrow(fpt_exception);
    end
    return;
end

try
    SimulinkFixedPoint.Autoscaler.collectModelCompiledDesignRange(sysObj, selectedRunName);
catch fpt_exception
    % showdialog can throw an error in testing mode. catch this error, restore
    % the UI and then rethrow the error.
    fptInstance.restoreSystemSettings;
    
    accelModeHandler.restoreSimulationMode;
    
    try
        fxptui.showdialog('compileddesignminmaxfailed',fpt_exception);
        fptInstance.reEnableUI('');
    catch fpt_exception
        fptInstance.reEnableUI('');
        rethrow(fpt_exception);
    end
    return;
end

% merge results from model references instances
try
    SimulinkFixedPoint.ApplicationData.mergeResultsInReferenceModels(system, selectedRunName);
catch e
    fptInstance.restoreSystemSettings;
    accelModeHandler.restoreSimulationMode;
    
    fptInstance.reEnableUI('');
    rethrow(e);
end

% if treenode is not top node, perform the merge from sub-model to block
sHandler = fxptds.SimulinkDataArrayHandler;
systemID = sHandler.getUniqueIdentifier(struct('Path',system));
try
    curRootName = systemID.getHighestLevelParent;
    if ~strcmp(topMdlName, curRootName)
        SimulinkFixedPoint.ApplicationData.updateResultsInModelsBlocks(topMdlName, selectedRunName);
    end
catch e
    fptInstance.restoreSystemSettings;
    accelModeHandler.restoreSimulationMode;
    fptInstance.reEnableUI('');
    rethrow(e);
end

% Clean up shortcut settings here
fptInstance.restoreSystemSettings;
accelModeHandler.restoreSimulationMode;

% re-enable code view
fptInstance.enableCodeView(true);

% We need to enable codeview if MLFb results are present
fptInstance.getStartupController.publishEnableCodeView;

fptInstance.updateData('append', selectedRunName);
end

% [EOF]

% LocalWords:  nofixptlicensederived FPT perf Autoscaling staticrangefailed
% LocalWords:  compileddesignminmaxfailed
