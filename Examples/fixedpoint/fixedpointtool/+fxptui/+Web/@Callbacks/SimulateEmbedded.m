function SimulateEmbedded(clientData)
% Simulates the behavior of the model with data types specified on the
% blocks without any DTO.

% Copyright 2016-2018 The MathWorks, Inc.

%ClientData is a structure (from JSON object) that contains the sim action

fpt = fxptui.FixedPointTool.getExistingInstance;
command = clientData.action;
runName = clientData.runName;

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
    
    if strcmpi(command, 'start')
        fpt.applyEmbeddedSettings;
        modelName = fpt.getModel;        
        fxptui.Web.Callbacks.changeRunNameAndRestoreDirty(modelName, runName);
        dataLayer = fxptds.DataLayerInterface.getInstance();
        dataLayer.addEmbeddedRunName(modelName, runName);
    end
    fxptui.Web.Callbacks.Simulate(command);
end
end

% LocalWords:  FPT
