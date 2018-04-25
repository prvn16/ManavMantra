function deleteInvalidResults(this)
    %% DELETEINVALIDRESULTS function deletes invalid results in the current run object
    
    % Copyright 2016-2017 The MathWorks, Inc.
    results = this.DataStorage.values;
    keys = this.DataStorage.keys;
    
    for rIndex = 1:length(results)
        if ~fxptds.isResultValid(results{rIndex})
            this.DataStorage.remove(keys{rIndex});
        end
    end
end