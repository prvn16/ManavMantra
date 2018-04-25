function initControllers(this, clientData)
    % INITCONTROLLERS Initializes the channels for communication with the
    % client.
    
    % Copyright 2017 The MathWorks, Inc.
    
    this.AppUniqueID = clientData.uniqueID;
    if ~isempty(this.WizardController)
        this.deleteControllers;
    end
    this.WizardController = FuncApproxUI.Web.WizardController(this.getAppUniqueId, this.MsgServiceInterface);    
    this.AppReady = true;
end
