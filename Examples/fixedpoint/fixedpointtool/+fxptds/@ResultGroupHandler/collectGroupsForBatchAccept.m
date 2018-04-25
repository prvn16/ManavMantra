function newGroups = collectGroupsForBatchAccept(~, runObj, group)
%% COLLECTGROUPSFORBATCHACCEPT function collects all group labels that will be affected by a batch accept operation on input "groupLabels"
%
% runObject is an instance of fxptds.FPTRun
% 
% group the group that contains the result that triggered the action

%   Copyright 2016 The MathWorks, Inc.
    
    % Get AutoscalerMetaData from runObject
    autoscalerMetaData = runObj.getMetaData;
    newGroups = {};
    if ~isempty(autoscalerMetaData)

        % get all results that belong to the group
        sharedGroupResults = group.getGroupMembers();

        % index into MATLAB Variable Results
        indexMLVarResults = cellfun(@(x) isa(x, 'fxptds.MATLABVariableResult'), sharedGroupResults);

        if any(indexMLVarResults)
            % collect all results within MLFB per result in indexMLVarResults
            % query the group names of all results collected
            fHandle =  @(pAutoscalerMetaData, x) SimulinkFixedPoint.AutoscalerUtils.collectGroupsInMLFB(runObj, x);
            mlfbGroups = cellfun(@(x) fHandle(autoscalerMetaData, x), sharedGroupResults(indexMLVarResults), 'UniformOutput', false);
            newGroups = [mlfbGroups{:}];
        end
    end 
end
