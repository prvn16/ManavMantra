function [result, numAdded] = findResultFromArrayOrCreate(this, resultArray, searchCriteria)
    % FINDRESULTFROMARRAYORCREATE Looks for a result that matches the specified
    % criteria from an array of results. If it does not find one, it creates a
    % new result in the current run being updated and returns a handle to the
    % result.
    % NOTE: Method originally part of Application Data, see g1431153
	
    % Copyright 2016-2017 The MathWorks, Inc.
    numAdded = 0;
    
    if strcmpi(searchCriteria{1},'UniqueIdentifier')
        result = this.getResultsWithCriteriaFromArray(resultArray, {'UniqueIdentifier',searchCriteria{2}});
        if isempty(result)
            dataStruct = this.createStructFromSearchCriteria(searchCriteria);
            result = this.createAndUpdateResult(fxptds.SimulinkDataArrayHandler(dataStruct));
            numAdded = 1;
        end
    else
        dataStruct = this.createStructFromSearchCriteria(searchCriteria);
        dh = fxptds.SimulinkDataArrayHandler;
        result = this.getResultsWithCriteriaFromArray(resultArray, {'UniqueIdentifier',dh.getUniqueIdentifier(dataStruct)});
        if isempty(result)
            result = this.createAndUpdateResult(fxptds.SimulinkDataArrayHandler(dataStruct));
            numAdded = 1;
        end
    end
end





