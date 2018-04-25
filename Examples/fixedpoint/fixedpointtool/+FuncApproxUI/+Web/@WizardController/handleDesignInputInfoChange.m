function handleDesignInputInfoChange(this, clientData)
    % Validates the Input Design Types changed by the user and publishes
    % the validation status to the client
    
    %   Copyright 2017 The MathWorks, Inc.
    
    isValidCell = FuncApproxUI.Utils.ValidationUtility.validateParam("Problem", clientData.InputName, clientData.InputValue);
    
    clientData.isTypeValid = isValidCell;
    this.publish(this.DesignInputInfoValidityPublishChannel, clientData);
    
end
