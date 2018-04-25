function SimulateIdealized(clientData)
    % Simulates the idealized behavior of the model
    
    % Copyright 2016-2018 The MathWorks, Inc.
    
    % ClientData is a structure containing the command
    
    fpt = fxptui.FixedPointTool.getExistingInstance;
    runName = clientData.runName;
    command = clientData.action;
    if ~isempty(fpt)
		% re-populate the referenced models if they were previously closed
		success = fpt.loadReferencedModels;
        if ~success
            return; 
        end
        % g1696210 - FPT should throw an error when the model is
        % locked and should not hang
        [success, dlgType] = fxptui.verifyModelState(fpt.getModel);
        if ~success
            fxptui.showdialog(dlgType);
            return;
        end
    
        shortcutManager = fpt.getShortcutManager;
        if strcmpi(command, 'start')
            fpt.applyIdealizedSettings;
            shortcutManager.setLastUsedIdealizedShortcut(shortcutManager.getIdealizedBehaviorShortcut);
            modelName = fpt.getModel;
            fxptui.Web.Callbacks.changeRunNameAndRestoreDirty(modelName, runName);
            dataLayer = fxptds.DataLayerInterface.getInstance();
            dataLayer.removeEmbeddedRunName(modelName, runName);
        end
        
        if isProceedSimulateIdealized(fpt.getModel, runName, command)
            fxptui.Web.Callbacks.Simulate(command);
        end
    end
end

function isProceedSimulateIdealized = isProceedSimulateIdealized(topMdlName, runName, command)
    global SimulateIdealizedSubscription;
    
    dataLayer = fxptds.DataLayerInterface.getInstance();
    isProceedSimulateIdealized = ~dataLayer.hasExecutedAction(topMdlName, runName, SimulinkFixedPoint.DataTypingServices.EngineActions.Apply);
    
    if ~isProceedSimulateIdealized
        % results require attention and checked accepted
        SimulateIdealizedSubscription = message.subscribe('/fpt/dialog/question/ignoreApplySimWarning',  @(btn)handleSimulateIdealizedAttention(btn, command));
        isProceedSimulateIdealized = false;
        appData = SimulinkFixedPoint.getApplicationData(topMdlName);
        proposalSettings = appData.settingToStruct();
        fxptui.showdialog('ignoreApplySimWarning', proposalSettings.isWLSelectionPolicy);
        return;
    end
    
    clear global SimulateIdealizedSubscription;
end

function handleSimulateIdealizedAttention(btn, command)
    
    global SimulateIdealizedSubscription;
    message.unsubscribe(SimulateIdealizedSubscription);
    clear global SimulateIdealizedSubscription;
    
    BTN_IGNORE_AND_SIMULATE = fxptui.message('btnIgnoreandSimulate');

    if strcmp(btn.buttonText, BTN_IGNORE_AND_SIMULATE)
        fxptui.Web.Callbacks.Simulate(command);
    end

end
% LocalWords:  FPT fpt btn Ignoreand
