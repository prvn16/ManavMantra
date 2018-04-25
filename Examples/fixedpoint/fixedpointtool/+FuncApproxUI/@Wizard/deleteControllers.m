function deleteControllers(this)
    % DELETECONTROLLERS Deletes the controllers that communicate with the
    % client
    
    % Copyright 2017 The MathWorks, Inc.   
    
    delete(this.WizardController);
    this.WizardController = [];    
end
