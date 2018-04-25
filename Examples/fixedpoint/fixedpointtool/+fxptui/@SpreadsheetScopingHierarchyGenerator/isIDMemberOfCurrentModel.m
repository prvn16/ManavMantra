function ismember = isIDMemberOfCurrentModel(this, subsystemID)
% ISIDMEMBEROFCURRENTMODEL Function to identify the MLFB function IDs that
% belong to the current model. MLFB variables are not generated for model
% reference cases as of 17a.

% Copyright 2016-2018 The MathWorks, Inc.

ismember = false;
actModel = '';
datasetSrcs = unique(fxptui.ScopingTableUtil.getDatasetsForSubsystemID(subsystemID));
for i = 1:numel(datasetSrcs)
    idx = strfind(datasetSrcs{i},':');
    if ~isempty(idx)
        mdlBlk = Simulink.ID.getHandle(datasetSrcs{i});
		% Do not process the protected models
        % g1696197
        if ~strcmp(get_param(mdlBlk,'ProtectedModel'), 'on')
			actModel = get_param(mdlBlk,'ModelName');
        end
    else
        actModel = datasetSrcs{i};
    end
    thisModel = this.TreeData.getModel.getFullName;
    if isequal(actModel, thisModel)
        ismember = true;
    end
end
end