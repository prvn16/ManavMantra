function appData = getApplicationData(result)
%% GETAPPLICATIONDATA function gets application data from fxptds.AbstractResult result object instance
% result is an instance of fxptds.AbstractResult
% appData is an instance of SimulinkFixedPoint.ApplicationData

%   Copyright 2016 The MathWorks, Inc.

	% Initialize appData to empty
	appData = [];

	% Retrive model information from result
	model = result.getHighestLevelParent;
    
    % getHighestLevelParent is empty for SignalObjectResults
    if isempty(model)
        return;
    end

    % Get application data from model
    appData = SimulinkFixedPoint.getApplicationData(model);
end