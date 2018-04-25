classdef FPTModelSaveAsUtility
    % Utility functions to query data when the Save as operation is
    % performed on the model
    
    % Copyright 2016 The MathWorks, Inc.
        
    methods(Static, Hidden)
        
        function addResultsToScopingEngine(newMdlName)
            % adds the result's resultId, runName, subsystemId and datasetSourceName in
            % fxptds.FPTRepository's ScopingTable.
            datasets = fxptui.FPTModelSaveAsUtility.getDatasetsForModel(newMdlName);
            results = fxptui.ResultsCheckerUtility.getResultsFromAllRuns(datasets);
            scopingEngine = fxptds.FPTGUIScopingEngine.getInstance();            
            for i = 1:numel(results)
                % add result to current scoping changeset
                scopingEngine.addResultToChangeset(results(i));
            end
        end
        
        function datasets = getDatasetsForModel(mdlName)
            % Get the datasets for a given system/model
            rep = fxptds.FPTRepository.getInstance;
            datasets = rep.getDatasetForSource(mdlName);
        end
        
        function removeResultsFromScopingEngine(oldDatasetSource)
            % removes the result's associated with the old model's dataset
            % source from the scoping engine changeset
            scopingEngine = fxptds.FPTGUIScopingEngine.getInstance();
            subsysCriteriaRecord = fxptds.FPTGUIScopingTableRecord;
            subsysCriteriaRecord.DatasetSourceName = {oldDatasetSource};
            scopingEngine.deleteRowsForCriteria(subsysCriteriaRecord);
        end
        
        function updateScopingEngine(oldMdlName, newMdlName)
            fxptui.FPTModelSaveAsUtility.removeResultsFromScopingEngine(oldMdlName);
            fxptui.FPTModelSaveAsUtility.addResultsToScopingEngine(newMdlName);
        end
    end
    
end
