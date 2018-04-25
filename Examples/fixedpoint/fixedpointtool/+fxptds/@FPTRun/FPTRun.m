classdef FPTRun < handle
% FPTRUN  creates a run to hold the results.
    
%     Copyright 2012-2017 The MathWorks, Inc.
    properties (SetAccess = private)
       dataTypeGroupInterface = fxptds.DataTypeGroupInterface.empty();
       DataStorage
	   Source
       MLFBHierarchyMap; % Stores the hierarchy of MATLABFunctionBlock to its associated function identifiers
    end
    
    properties (SetAccess = private, GetAccess = private)
        RunName
    end
    
    properties(Hidden, SetAccess = private)
        actionsQueue;
        RunID 
        SDITsRunID
        MetaData;
        Timestamp;
        % RootFunctionIDsMap contains a map of the block identifiers with
        % their valid root function IDs. It is used to calculate if a block
        % has had any changes between runs.
        RootFunctionIDsMap 
        RunEventHandler;
    end

    methods
        function this = FPTRun(runName, runID)
            this.RunName = runName;
            this.RunID = runID;
            
            this.Timestamp = cputime;
            this.RootFunctionIDsMap = Simulink.sdi.Map(char('a'),{-1});
            this.RunEventHandler = fxptds.DSEventHandlers.RunEventHandlerFactory.getInstance();
            this.dataTypeGroupInterface = fxptds.DataTypeGroupInterface();
			this.DataStorage = containers.Map('KeyType', 'char', 'ValueType', 'any');
            this.MLFBHierarchyMap = containers.Map('KeyType', 'double', 'ValueType', 'any');
            this.actionsQueue = {};
        end

		function setSource(this, source)
           this.Source = source; 
        end
        
        %% Actions Queue Functions
        function pushAction(this, engineAction)
            this.actionsQueue = [this.actionsQueue {engineAction}];
        end
        
        function action = popAction(this)
            action = [];
            if ~isempty(this.actionsQueue)
                action = this.actionsQueue{end};
                this.actionsQueue(end) = '';
            end
        end
        
        function exists = actionExists(this, action)
            exists = false;
            for index = 1:length(this.actionsQueue)
                if this.actionsQueue{index} == action
                    exists = true;
                    return;
                end
            end
        end
        
        function clearActionsQueue(this)
           this.actionsQueue = {}; 
        end
        %%
        runName = getRunName(this);
        
        
        result = createAndUpdateResult(this, dataArrayHandlerObj);
        result = createAndUpdateResultWithID(this, data);
        res = getResults(this);
        res = getResultsWithCriteriaFromArray(this, resultArray, matchCriteria);
        res = getResultsFromDataStorage(this);
        res = getResultsAsCellArray(this);
        [result, numAdded, dHandler] = getResult(this, blkObj, pathitem)
        result = getResultByID(this, uniqueIdentifier);
        result = getResultByScopingId(this, scopingId);
        
        % Creates a MLFB blockHandle to list of functionIdentifiers list
        % map in the MLFBHierarchyMap of the RunObject
        addMLFBHierarchy(this, blockHandle, functionIdentifiers);
        
        
        addResult(this, result);
        updateResult(this, result, data);
        
        % new groups interface
        setDataTypeGroupInterface(this, dataTypeGroupInterface)
        
        
        setMetaData(this, metadata);
        metaData = getMetaData(this);   
       
        restoreFailedResults = restoreResults(this, savableResults);
   
        clearSignalResults(this, results);
        
        cleanupOnSimulation(this, writeMode);
        cleanupOnDerivation(this);
        
        clearSimulationResults(this, results);
        clearScalingResults(this, results);
        clearRangeAnalysisResults(this, results);
        
        clearResultFromRun(this, result);
        
        flag = hasResults(this);
        flag = hasDataTypeProposals(this);
        hasResults = hasDerivedRangeResults(this);
         
        updateRunName(this, runName);
        
        setTimeSeriesRunID(this, timeseriesID);
        timeseriesID = getTimeSeriesRunID(this);
        
        rootFunctionIDMap = getRootFunctionIDsMap(this);
        insertRootFunctionIDs(this, blockUniqueKey, RootFunctionIDs);
       
        
        % moved from ApplicationData
        [result, numAdded] = findResultFromArrayOrCreate(this, resultArray, searchCriteria)
        dStruct = createStructFromSearchCriteria(~, searchCriteria)
        [result, newResults, numAdded] = findResultForBlockFromArrayOrCreate(this, allResults, blkObj)
    end
	
	methods(Access = ?fxptds.FPTDataset, Hidden)
       clearResults(this); 
    end

end
