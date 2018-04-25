function updateResultHandler(this, result)
%% UPDATERESULTHANDLER function updates ResultHandler member with context information on
% FPT's current proposal settings
% If FPT is in Autoscaling or not
% All Datasets in the context of top model of FPT
% It interfaces with GUIHandler to set these properties on the
% ResultHandler

%   Copyright 2016 The MathWorks, Inc.

    % Query appdata. This property might be empty if FPT is not open
    appData = this.GUIHandler.getApplicationData();
    if isempty(appData)
        appData = fxptds.Utils.getApplicationData(result);
    end
    
    allDatasets = this.GUIHandler.getAllDatasets();
    if isempty(allDatasets)
        % If datasets is empty, Fetch all datasets from application data which contains top model dataset and sub model datasets
        allDatasets = fxptds.Utils.getAllDatasets(appData);
    end
    
    % If no context information is available, return 
    if isempty(appData) || isempty(allDatasets)
        return;
    end
    
    % Update result handler's context 
    this.ResultHandler.updateContext(appData, allDatasets);
end