function scopingId = getScopingId(result)
%% GETSCOPINGID function creates string based id on all fields of fxptds.AbstractResult
% 
% result is an instance of fxptds.AbstractResult

%   Copyright 2016 The MathWorks, Inc.

    % get run object from result
    runObject = result.getRunObject;
    
    % Fill in the members of the struct with appropriate information from
    resultId = fxptds.Utils.getResultId(result);
    
    % ResultName = getDisplayLabel of the result
    resultName = fxptds.Utils.getResultName(result);
    
    % SubsystemId = id of the parent subsytem id of the result
    subsystemId = fxptds.Utils.getSubsystemId(result);
    
    % RunName = Name of the run object 
    runName = fxptds.Utils.getRunName(runObject);
    
    % DatasetSourceName = name of the dataset from the run object
    datasetSourceName = fxptds.Utils.getDatasetSource(runObject);
    
    % string scoping id from other fields
    scopingId = [subsystemId{1} '#' resultId{1} '#' runName{1} '#' datasetSourceName{1} '#' resultName{1} '#'];
    scopingId = {scopingId};
end