classdef FPTGUIScopingEngine < handle
%% FPTGUISCOPINGENGINE class controls access of Cache Table 
% Class contains a table oject called ScopingTable and provides API
% interface to add/update/delete/query this table object

%   Copyright 2016-2017 The MathWorks, Inc.

    properties (GetAccess=private, SetAccess=private)
        ScopingTable % table datastructure to contain information related to "subsystemId-resultid-runid-datasetsource" map.
        CurScopingChangeset = {};
        ChangesetTable % table datastructure to contain current changeset of results 
        SubsystemIDMap; % Map containing subsystem block handles to their corresponding subsystem identifiers cached
    end
    
    methods (Static)
        function obj = getInstance
        % Returns the stored instance of the repository.
            persistent localObj
            if isempty(localObj) || ~isvalid(localObj)
                localObj = fxptds.FPTGUIScopingEngine;
            end
            obj = localObj;
        end
    end
    
    methods (Access=private)
        function this = FPTGUIScopingEngine
            % Store the FPTGUI scoping related information
            scopingRecordFieldNames = fxptds.FPTGUIScopingAdapter.getFieldNames();
            
            % Initialize table with input variable names which are defined
            % by scopingRecordFieldNames
            this.ScopingTable = table([], [], [], [], [], [], 'VariableNames',scopingRecordFieldNames);
            
            this.SubsystemIDMap = containers.Map('KeyType', 'char', 'ValueType', 'any');
        end
    end
        
    methods
        % addResult to ScopingTable
        % methods to add results to changeset which can be later converted
        % to table object.  Table creation is deferred to time of querying
        % for results mapping to a given node in FPTGUI tree for
        % performance reasons
        addResultToChangeset(this, result);
        convertChangesetToScopingTableRecords(this);
        
        % Query rows that map to the current changeset 
        changesetTable = getChangesetForCriteria(this, scopingTableQueryRecord);
        
        % Soon to be deprecated 
        addResult(this, result, runObject);% addResult used by fxptds.DSEventHandlers.RunEventHandler
        
        % getRows that match the input scopingTableRecord 
        resultRows = getRowsForCriteria(this, scopingTableQueryRecord);
        
        % delete rows that match the criteria specified in scopingTableRecord
        % To be called on clearResultsInRuns and clearResults for a given
        % run
        deleteRowsForCriteria(this, scopingTableQueryRecord);
        
        % delete result that belongs to given set of scopingIds
        deleteResult(this, scopingIds);
        
        % delete all results that belong to  a run and dataset
        deleteAllResults(this, runName, datasetSourceName);
        
        % get row indices that match in the input criteria of scopingTableQueryRecord
        rowIds = getRowIdsForCriteria(this, scopingTableQueryRecord);
     
        % updateRows with with a set of column values on the input column name and row ids
        isUpdated = updateRows(this, rowIds, columnName, columnValue)
        
        % Updates the Run & ID column values with the new run name
        newScopingIdsMap = updateScopingIdsForRunNameChange(this, oldRunName, newRunName, datasetSourceName);
        
        % Query for subsystem identifier given a blkObj id / handle
        subsystemIdentifier = getSubsystemIdentifier(this, id);
        
        % Add a map of blkObj to functionIdentifier to the SubsystemIDMap
        cacheSubsystemIdentifier(this, id, value);
    end
    methods(Access = private)
        % add scopingTableRow given a ScopingTableRecord instance
        addScopingTableRow(this, scopingTableRecord); % add row to member table ScopingTable 
        
        % validate inputs for updateRows function
        isValidUpdate = validateInputsForUpdateRows(this, rowIds, columnName, value);
        
        % construct new ID string by replacing old run name with new run name.
        newID = getNewIDWithUpdatedRunNameForRow(this, rowId, oldRunName, newRunName);
        
    end
    methods(Hidden)
        % test helper to get scoping table instance
        tbl = getScopingTable(this);
        
        % test helper to get changeset table instance
        changesetTable = getChangesetTable(this);
    
        % test helper to clear scoping table
        clearData(this);
        
        % Remove the uniqueID object associated with the id from the map.
        removeSubsystemIDFromMap(this, id);
    end
    methods(Static)
        % query table for rows that match quering record
        rowIds = queryTable(tableToScan, queryingRecord);
        
        % static method to validate rowIds to be of a valid format to query scoping table
        isValid = validateRowIds(rowIds);
        
        % static method to validate if column values used to update scoping table are in valid format
        isValid = validateColumnValues(values);
    end
end
