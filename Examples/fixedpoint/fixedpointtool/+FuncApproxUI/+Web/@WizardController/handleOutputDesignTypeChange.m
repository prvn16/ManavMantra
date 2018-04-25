function handleOutputDesignTypeChange(this, clientData)
%handleDesignTypesChange validates the Design Types
% and publishes the validation status to the client

isValid = FuncApproxUI.Utils.ValidationUtility.validateParam("Problem", clientData.designType, clientData.value);
msgObj.identifier = clientData.designType;
msgObj.isValid = isValid;
this.publish(this.DesignTypesValidityPublishChannel, msgObj);

end

