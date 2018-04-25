function results = getResultsAsCellArray(this)
    % GETRESULTSASCELLARRAY Gets all the results stored in the engine for the run.
    
    %     Copyright 2015-2017 The MathWorks, Inc.
    
    results = this.DataStorage.values;
end
