function initControllers(this, clientData)
    % INITCONTROLLERS Initializes the channels for communication with the
    % client.
    
    % Copyright 2015-2017 The MathWorks, Inc.
    
    this.ModelHierarchy = fxptui.ModelHierarchy(this.Model);
    this.ModelHierarchy.captureHierarchy;
    
    if ~isempty(this.TreeController)
        this.deleteControllers
    end
    
    this.SimStartPublishChannel = sprintf('%s/%s','/fpt/simulate/engineSimulationStart', clientData.mainTreeUniqueID);
    this.SimFailPublishChannel = sprintf('%s/%s','/fpt/simulate/engineCompFailed', clientData.mainTreeUniqueID);
    this.TreeController = fxptui.Web.TreeController(clientData.mainTreeUniqueID, true, this.ModelHierarchy);
    this.DataController = fxptui.Web.DataController(clientData.mainTreeUniqueID);
    this.isReadyPostCallback = true;
    this.StartupController = fxptui.Web.StartupController(clientData.startupTreeUniqueID, this.ModelHierarchy);
    this.Listener = addlistener(this.StartupController,'SUDChangedEvent',@this.updateSUD);
    this.StartupController.updateSelectedSystem(this.InitialSelectedSystem);
    this.WorkflowController = fxptui.Web.WorkflowController(clientData.mainTreeUniqueID);
    this.ResultInfoController = fxptui.Web.ResultInfoController(clientData.mainTreeUniqueID);
    this.setModel(this.Model);
    this.publishInitialData(clientData);
    this.attachPostSaveCallback;
    if this.CaptureOriginalSettings
        this.captureCurrentSystemSettings;
        this.CaptureOriginalSettings = false;
    end
end
