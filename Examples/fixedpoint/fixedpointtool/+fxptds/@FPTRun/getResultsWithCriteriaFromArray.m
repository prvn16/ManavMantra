function result = getResultsWithCriteriaFromArray(this, resultArray, matchingCriteria)
    % GETRESULTSWITHCRITERIAFROMARRAY Returns the result that matches the specified criteria in the specified resultArray
    
    % Copyright 2012-2017 The MathWorks, Inc.
    
    propNames = matchingCriteria(1:2:end);
    if ~all(cellfun(@ischar,propNames))
        [errMsg, errID] = fxptui.message('debugNotValidPropNames');
        error(errID, errMsg);
    end
    propValues = matchingCriteria(2:2:end);
    allResults = resultArray;
    indices_id = 0;
    
    for i = 1:length(propNames)
        if strcmpi(propNames{i},'UniqueIdentifier')
            indices_id = i;
            break;
        end
    end
    
    if sum(indices_id) > 0
        if isa(propValues{indices_id}, 'fxptds.AbstractIdentifier')
            uniqueID = propValues{indices_id}.UniqueKey;
            allResults = [];
            if this.DataStorage.isKey(uniqueID)
                allResults = this.DataStorage(uniqueID);
                if ~isempty(allResults) && ~fxptds.isResultValid(allResults)
                    allResults = [];
                end
            end
            
        end
    else
        if isempty(allResults)
            allResults = this.getResultsFromDataStorage;
        else
            if iscell(allResults)
                allResults = [allResults{1:numel(allResults)}];
            end
        end
        if ~isempty(allResults)
            for i = 1:length(propNames)
                % Find the first match
                allResults = findobj(allResults,propNames{i},propValues{i});
                if isempty(allResults)
                    result = [];
                    return;
                end
            end
        end
    end
    result = reshape(allResults,1,[]);
    
end