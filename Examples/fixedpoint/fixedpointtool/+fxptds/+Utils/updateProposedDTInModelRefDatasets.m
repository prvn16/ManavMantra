function updateProposedDTInModelRefDatasets(result, allDatasets)
%% UPDATEPROPOSEDDTINMODELREFDATASETS function updates proposed datatype of a result on 
% all the results in model block datasets across model referene boundaries
% of the model
%  result is an instance of fxptds.AbstractResult

%   Copyright 2016 The MathWorks, Inc.

    
    % NOTE: isReadOnly property of a result indicates if the result belongs to a
    % model reference dataset while originating from a reference
    % instance dataset
    % The results with this property set to true are only given updates to
    % proposedDT, accept state, ranges etc. However, these results
    % themselves donot contribute to / trigger any updates across results model reference
    % hierarchy 
    if ~result.isReadOnly 
        % for each dataset, get result that matches the unique identifier
        % of the current result
        for idx = 1:length(allDatasets)
            curDS = allDatasets{idx};
            runObj = curDS.getRun(result.getRunName);
            dsResult = runObj.getResultByID(result.getUniqueIdentifier);
            
            % if result with matching identifier found and if the result
            % belongs to a model block dataset, then update proposedDT
            if ~isempty(dsResult) && (~isequal(dsResult, result)) && dsResult.isReadOnly
                
                % Update proposed data type
                dsResult.setProposedDT(result.getProposedDT);
                
                % Update accept flag
                dsResult.setAccept(result.getAccept);
            end
        end
    end
end
