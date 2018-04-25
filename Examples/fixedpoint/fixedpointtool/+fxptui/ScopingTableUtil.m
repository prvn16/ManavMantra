classdef ScopingTableUtil < handle
% Utility functions to query data from the Scoping table

% Copyright 2016 The MathWorks, Inc.

    methods (Static)
        function [resultIds, rows] = getResultIdsForDatasetSource(datasetSource)
            % Get all result IDs that map to a given dataset source.
            
            scopingEngine = fxptds.FPTGUIScopingEngine.getInstance();
            subsysCriteriaStruct = fxptds.FPTGUIScopingTableRecord;
            subsysCriteriaStruct.DatasetSourceName = {datasetSource};
            rows = scopingEngine.getRowsForCriteria(subsysCriteriaStruct);
            resultIds = rows.ID;        
        end
        
        function [resultIds, rows] = getResultIdsForSystemId(systemID)
        % Get all result IDs that map to a given subsystem ID.
                        
            scopingEngine = fxptds.FPTGUIScopingEngine.getInstance();
            subsysCriteriaStruct = fxptds.FPTGUIScopingTableRecord;
            subsysCriteriaStruct.SubsystemId = {systemID};
            rows = scopingEngine.getRowsForCriteria(subsysCriteriaStruct);
            resultIds = rows.ID;
        end
        
        function result = getResultForClientResultID(resultScopingID)
            % Returns the result object that corresponds to the unique ID
            % of the result provided by the client (web-app) 
            
            result = [];
            scopingEngine = fxptds.FPTGUIScopingEngine.getInstance();
            
            criteria = fxptds.FPTGUIScopingTableRecord;
            criteria.ID = {resultScopingID};
            row = scopingEngine.getRowsForCriteria(criteria);
            if isempty(row)
                % row can be empty if there is a race condition between
                % selecting a row and renaming a run which causes a change
                % in result ID.
                return;
            end
            rep = fxptds.FPTRepository.getInstance;
            ds = rep.getDatasetForSource(row.DatasetSourceName{:});
            runObj = ds.getRun(row.RunName{:});
            % row.ID needs to be passed as a cell array as that is how it is being
            % stored in the result
            result = runObj.getResultByScopingId(row.ID);            
        end
        
        function [resultIds, rows] = getResultIdsForSystemInDataset(systemID, datasetSource)
         % Get all result IDs that map to a given subsystem within a dataset source.
            
            scopingEngine = fxptds.FPTGUIScopingEngine.getInstance();
            subsysCriteriaStruct = fxptds.FPTGUIScopingTableRecord;
            subsysCriteriaStruct.SubsystemId = {systemID};
            subsysCriteriaStruct.DatasetSourceName = {datasetSource};
            rows = scopingEngine.getRowsForCriteria(subsysCriteriaStruct);
            resultIds = rows.ID;
        end
        
        function datasetSources = getDatasetsForSubsystemID(systemID)
            % Get all the dataset sources for a given system ID
            
            scopingEngine = fxptds.FPTGUIScopingEngine.getInstance();
            subsysCriteriaStruct = fxptds.FPTGUIScopingTableRecord;
            subsysCriteriaStruct.SubsystemId = {systemID};
            rows = scopingEngine.getRowsForCriteria(subsysCriteriaStruct);
            datasetSources = rows.DatasetSourceName;
        end
        
        function [datasetSources, rows] = getDatasetsForResultID(resultID)
            % Get all the dataset sources for a given system ID
            
            scopingEngine = fxptds.FPTGUIScopingEngine.getInstance();
            subsysCriteriaStruct = fxptds.FPTGUIScopingTableRecord;
            subsysCriteriaStruct.ID = {resultID};
            rows = scopingEngine.getRowsForCriteria(subsysCriteriaStruct);
            datasetSources = rows.DatasetSourceName;
        end
        
        function row = getRowForResultID(resultID)
            % Get the table row for the result ID
            
            scopingEngine = fxptds.FPTGUIScopingEngine.getInstance();
            subsysCriteriaStruct = fxptds.FPTGUIScopingTableRecord;
            subsysCriteriaStruct.ID = {resultID};
            row = scopingEngine.getRowsForCriteria(subsysCriteriaStruct);
        end              
    end
end
