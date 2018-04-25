function result = getResultByScopingId(this, scopingId)
%% GETRESULTSBYSCOPINGID function returns results that match a given scoping id 

%  Copyright 2016 The MathWorks, Inc.

    allResults = this.getResults;
    result = findobj(allResults, 'ScopingId', scopingId);    
end