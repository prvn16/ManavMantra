function clearResults(this)
    %CLEARRESULTS Clear all results contained in the run or only the one that matches the specified criteria.

    %    Copyright 2012-2017 The MathWorks, Inc.
    
    % Delete all references to results for a given run in FPTGUIScopingEngine
    % before deleting all runs
    this.RunEventHandler.notifyDeleteAllResults(this.RunName, this.Source);
    
    % delete all results from the run (the DataStorage map will be deleted
    % with the Run object)
    results = this.DataStorage.values;
    for rIndex = 1:length(results)
        delete(results{rIndex});
    end
    
    if ~isempty(this.MetaData)
        this.MetaData.clear;
        delete(this.MetaData);
        this.MetaData = [];
    end
    delete(this);
	
end
