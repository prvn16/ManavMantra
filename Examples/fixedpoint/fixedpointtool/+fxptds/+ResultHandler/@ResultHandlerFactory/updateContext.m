 function this = updateContext(this, appData, allDatasets)
%% UPDATECONTEXT function to assign all FPT specific inputs to ResultGroupHandler 
% and to member properties
% FPT context specific inputs are 
% 1. ProposalSettings in GUI
% 2. If currently in midst of autoscaling
% 3. All top model relevant datasets
% All these properties are derived from appData input

%   Copyright 2016-2017 The MathWorks, Inc.

	proposalSettings = appData.AutoscalerProposalSettings;

    % Update result group handler with context information on
    % proposal settings, and all datasets relevant for the
    % edit operation to handle all results in groups
    this.ResultGroupHandler.setProposalSettings(proposalSettings);
    this.ResultGroupHandler.setAllDatasets(allDatasets);

    % Update context information on
    % proposal settings, all datasets relevant for the
    % edit operation to handle all results *NOT* in groups
    this.ProposalSettings = proposalSettings;
    this.AllDatasets = allDatasets;
 end
