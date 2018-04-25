function Propose
% PROPOSE Callback to get new fixed-point types from the proposal engine.

%  Copyright 2015-2018 The MathWorks, Inc.

fpt = fxptui.FixedPointTool.getExistingInstance;

if ~isempty(fpt)

    topMdl = fpt.getModel;
    % g1696210 - FPT should throw an error when the model is 
    % locked and should not hang
    [success, dlgType] = fxptui.verifyModelState(topMdl);    
    if ~success
        fxptui.showdialog(dlgType);
        return;
    end
    sud = fpt.getSystemForConversion;
    if isempty(sud)
        fxptui.showdialog('invalidSUD');
        return;
    end
    
    appData = SimulinkFixedPoint.getApplicationData(topMdl);
    
    if isDoScaling(sud, appData)
        proposeDT();
    end

end

end

%--------------------------------------------------------------------------
function b = isDoScaling(sud, aData)
b = true;

datasets = fxptds.getAllDatasetsForModel(sud);
results= fxptui.ResultsCheckerUtility.getResults(datasets, aData.ScaleUsing);
if isempty(results)
    return;
end

isUsingSimMinMax = aData.AutoscalerProposalSettings.isUsingSimMinMax;
isUsingDerivedMinMax = aData.AutoscalerProposalSettings.isUsingDerivedMinMax;

% If the user is attempting to scale against fixed point data, ask if that
% is really what they want to do. The normal workflow calls for scaling
% against floating point data.
if isUsingSimMinMax || isUsingDerivedMinMax
    numSimDT = 0;
    numDrvDT = 0;
    numFixdt = 0;

    for r = 1:numel(results)
        if results{r}.hasCompiledDT
            if isUsingSimMinMax
                numSimDT = numSimDT + 1;
            end
            if isUsingDerivedMinMax
                numDrvDT = numDrvDT + 1;
            end
            if(results{r}.hasFixedDT)
                numFixdt = numFixdt + 1;
            end
        end
    end

    b = ~isScaleFixDT(numSimDT, numDrvDT, numFixdt);

end

end

%--------------------------------------------------------------------------
function isScaleFixDT = isScaleFixDT(numSimDT, numDrvDT, numFixdt)

isScaleFixDT = false;
global scaleFixDTSubscription;

% Warn if attempting to propose scaling using fixed point data.
% It would be reasonable for a floating point model to contain
% some small used of fixed-point/integer.  To limit "false positive"
% warnings, the arbitrary threshold of 4% is used.
% If more than 4% of the data types logging min/max are fixed-point
% or integer then warn.
if numFixdt > ( 0.04 * numSimDT ) || numFixdt > ( 0.04 * numDrvDT )
    scaleFixDTSubscription = message.subscribe('/fpt/dialog/question/scalingFixDT',  @(btn)handleScaleFixDT(btn));
    isScaleFixDT = true;
    fxptui.showdialog('scalingfixdt');
    return;
end

clear global scaleFixDTSubscription;

end

%--------------------------------------------------------------------------
function proposeDT()

fpt = fxptui.FixedPointTool.getExistingInstance;
% FPT restores the model settings (DTO) after every collection action. In
% order for the timestamp of the last range collection run to be considered
% valid in the codeview and for it to propose types for the MLFB, reapply
% the idealized shortcut before the proposal process kicks in.  
fpt.getExternalViewer.applyIdealizedShortcutBeforePropose;

mdl = fpt.getModel;

sud = fpt.getSystemForConversion;
sudObj = get_param(sud,'Object');

appData = SimulinkFixedPoint.getApplicationData(mdl);

datasets = fxptds.getAllDatasetsForModel(mdl);

accelModeHandler = fxptui.Web.AccelModeHandler(mdl);

fpt_diagViewer = DAStudio.DiagViewer.findInstance('FPTDiagnostics');
if ~isempty(fpt_diagViewer)
    fpt_diagViewer.flushMsgs;
    fpt_diagViewer.Visible = false;
    delete(fpt_diagViewer);
end

topModelScaleSetting = appData.settingToStruct();

proposalSettings = topModelScaleSetting;

% Disable code view
fpt.enableCodeView(false);

accelModeHandler.switchToNormalMode;

try
	engineContext = SimulinkFixedPoint.DataTypingServices.EngineContext(...
    mdl, ...
    sud, ...
    proposalSettings, ...
    SimulinkFixedPoint.DataTypingServices.EngineActions.ConditionalProposal);
    engineInterface = SimulinkFixedPoint.DataTypingServices.EngineInterface.getInterface();
    engineInterface.run(engineContext);
    SimulinkFixedPoint.ApplicationData.updateResultsInModelsBlocks(mdl, topModelScaleSetting.scaleUsingRunName);
    fpt.updateData('append',topModelScaleSetting.scaleUsingRunName);
catch fpt_exception
    % showdialog can throw an error in testing mode. catch this error, restore
    % the UI and then rethrow the error.
    % Restore the settings that was applied earlier.
    fpt.getExternalViewer.restoreModelSettings;
    % Re-enable code view
    fpt.enableCodeView(true);
    
    accelModeHandler.restoreSimulationMode;
    try
        fxptui.showdialog('scaleproposefailed',fpt_exception);
    catch fpt_exception
        rethrow(fpt_exception);
    end 
    return;
end
results= fxptui.ResultsCheckerUtility.getResults(datasets, appData.ScaleUsing);
if hasmarkedred(results)
    fxptui.showdialog('scaleproposeattention');
end
fpt.getExternalViewer.typesProposed(sudObj);
% Restore the settings that was applied earlier.
fpt.getExternalViewer.restoreModelSettings;
accelModeHandler.restoreSimulationMode;

% Re-enable code view
fpt.enableCodeView(true);
end

%--------------------------------------------------------------------------
function b = hasmarkedred(results)
b = false;

if(isempty(results)); return; end
for i = 1:numel(results)
    alerts = results{i}.getAlert;
    if strcmp('red', alerts)
        b = true;
        return;
    end
end

end

%--------------------------------------------------------------------------
function handleScaleFixDT(btn)

global scaleFixDTSubscription;
message.unsubscribe(scaleFixDTSubscription);
clear global scaleFixDTSubscription;

BTN_YES = fxptui.message('labelYes');

if  strcmp(btn.buttonText, BTN_YES)
    proposeDT();
end

end

% [EOF]

% LocalWords:  fpt scalingfixdt scaleproposefailed scaleproposeattention
