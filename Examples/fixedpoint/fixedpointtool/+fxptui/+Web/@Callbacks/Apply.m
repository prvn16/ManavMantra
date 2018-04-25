function Apply
% APPLY apply proposals on the selected system for conversion.

%   Copyright 2015-2018 The MathWorks, Inc.

fpt = fxptui.FixedPointTool.getExistingInstance;
if ~isempty(fpt)
    topMdlName = fpt.getModel;
    % g1696210 - FPT should throw an error when the model is 
    % locked and should not hang
    [success, dlgType] = fxptui.verifyModelState(topMdlName);
    if ~success
        fxptui.showdialog(dlgType);
        return;
    end
    appData = SimulinkFixedPoint.getApplicationData(topMdlName);

    % determine if proceed by checking all submodels included
    if ~isProceedScaleApply(topMdlName, appData)
        return;
    end

    scaleApply();
end

end

%--------------------------------------------------------------------------
function isProceedScaleApply = isProceedScaleApply(topMdlName, appData)
isProceedScaleApply = false;

global scaleApplySubscription;

datasets = fxptds.getAllDatasetsForModel(topMdlName);

for i = 1:numel(datasets)
    results = fxptui.ResultsCheckerUtility.getResults(datasets(i), appData.ScaleUsing);
    % iterate through results of each dataset
    for j = 1:numel(results)
        if results{j}.hasApplicableProposals
            isProceedScaleApply = true;
            if  results{j}.needsAttention
                % results require attention and checked accepted
                scaleApplySubscription = message.subscribe('/fpt/dialog/question/scaleApplyAttention',  @(btn)handleScaleApplyAttention(btn));
                isProceedScaleApply = false;
                fxptui.showdialog('scaleapplyattention');
                return;
            end
        end
    end
end

if ~isProceedScaleApply
    fxptui.showdialog('notacceptchecked');
end

clear global scaleApplySubscription;

end

%--------------------------------------------------------------------------
function scaleApply

fpt = fxptui.FixedPointTool.getExistingInstance;
topMdlName = fpt.getModel;
sud = fpt.getSystemForConversion;
if isempty(sud)
    fxptui.showdialog('invalidSUD');
    return;
end
appData = SimulinkFixedPoint.getApplicationData(topMdlName);

topModelScaleSetting = appData.settingToStruct();
applySuccess = true; % Determine whether apply succeeded for the Code View

proposalSettings = topModelScaleSetting;

% Disable code view
fpt.enableCodeView(false);

mlfbVariantHandler = fxptui.MLFBVariantHandler;
    try
        sudObj = get_param(sud,'Object');
        % Attach a listener on the model containing the SUD to react to
        % variant creation
        mlfbVariantHandler.attachMLFBVariantCreationListener(sudObj);
		engineContext = SimulinkFixedPoint.DataTypingServices.EngineContext(...
		topMdlName, ...
		sud, ...
		proposalSettings, ...
		SimulinkFixedPoint.DataTypingServices.EngineActions.Apply);
        engineInterface = SimulinkFixedPoint.DataTypingServices.EngineInterface.getInterface();
        engineInterface.run(engineContext);
        SimulinkFixedPoint.ApplicationData.updateResultsInModelsBlocks(topMdlName, topModelScaleSetting.scaleUsingRunName);
        fpt.processMLFBVariants(mlfbVariantHandler.getVariantSubsystems);
        fpt.updateData('append',topModelScaleSetting.scaleUsingRunName);
    catch fpt_exception
        mlfbVariantHandler.removeMLFBVariantCreationListener;
        % Re-enable code view
        fpt.enableCodeView(true);
        try
            fxptui.showdialog('scaleapplyfailed', fpt_exception.message);
            applySuccess = false;
        catch fpt_exception
            rethrow(fpt_exception);
        end
    end
    fpt.getExternalViewer.typesApplied(applySuccess);
    % Re-enable code view
    fpt.enableCodeView(true);
    mlfbVariantHandler.removeMLFBVariantCreationListener;
    
end

%--------------------------------------------------------------------------
function handleScaleApplyAttention(btn)

global scaleApplySubscription;
message.unsubscribe(scaleApplySubscription);
clear global scaleApplySubscription;

BTN_IGNORE_AND_APPLY = fxptui.message('btnIgnoreAlertAndApply');

% Proceed to apply if choose Yes; otherwise cancel apply if
% choose Cancel (isProceedScaleApply remains false)
if strcmp(btn.buttonText, BTN_IGNORE_AND_APPLY)
    scaleApply();
end

end

% [EOF]

% LocalWords:  fpt scaleapplyattention notacceptchecked scaleapplyfailed btn
