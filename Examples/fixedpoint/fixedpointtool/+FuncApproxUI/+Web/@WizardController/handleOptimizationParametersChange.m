function handleOptimizationParametersChange(this, clientData)
%HANDLEOPTIMIZATIONPARAMETERSCHANGE validates the Optimization Parametes
% and publishes the validation status to the client
isValid = FuncApproxUI.Utils.ValidationUtility.validateParam("Options",...
    clientData.optimizationParameter, clientData.value);

% Notify the client when an invalid optimiation value is specified by the
% user
msgObj.identifier = clientData.optimizationParameter;
msgObj.isValid = isValid;
this.publish(this.OptimizationParamsValidityPublishChannel, msgObj);
end

