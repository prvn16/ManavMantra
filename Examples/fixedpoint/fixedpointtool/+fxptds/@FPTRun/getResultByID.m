function result = getResultByID(this, uniqueIdentifier)
%% GETRESULTSBYID function queries run object for results that belongs to a given run

%   Copyright 2016-2017 The MathWorks, Inc.

    result = [];
    
    uniqueID = uniqueIdentifier.UniqueKey;
    if this.DataStorage.isKey(uniqueID)
        result = this.DataStorage(uniqueID);
        if ~isempty(result) && ~fxptds.isResultValid(result)
            result = []; 
        end
    end
end