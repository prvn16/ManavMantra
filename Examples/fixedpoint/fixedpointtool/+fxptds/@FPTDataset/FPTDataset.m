classdef (Sealed) FPTDataset < handle
% FPTDATASET Stores and manages runs containing data.
    
%  Copyright 2012-2017 The MathWorks, Inc.

    properties (Hidden, SetAccess=private)
        RunNameObjMap;                 % Mapping between the run-name and run object
        RunNameTsIDMap;                % Mapping between the run-name and Time-series run ID from the global engine
        EmbeddedRunNames;
        LastModifiedRun='';            % Last run that was written to in the dataset. Used for traceability
        Source;
        runID = 0;
        EventHandler;
    end
    
    methods
        %% Constructor
        function this = FPTDataset(srcName)
            this.Source = srcName;
            this.RunNameObjMap = Simulink.sdi.Map(char('a'),?handle);
            this.RunNameTsIDMap = Simulink.sdi.Map(char('a'),int32(0));
            if fxptds.isSimulinkModel(this.Source)
                % Add Simulink event listeners
                this.EventHandler = fxptds.SimulinkEventHandlerInterface();
                this.EventHandler.registerDataset(this);
            end
            this.EmbeddedRunNames = {};
        end    
        
        
        source = getSource(this);% Get Source Model Name associated with the Dataset
        
        runObj = getRun(this, runName);% Get RunObject from run name
        res = getResultsFromRuns(this);% Get results from all runs
        res = getResultsFromRun(this, runName);% Get results from one run
        
        runName = getCurrentRunName(this);
        runNames = getAllRunNames(this);
        lastModifiedRun = getLastModifiedRun(this);% Get last modified run associated with the Dataset
        setLastModifiedRun(this, runName);% Set last modified run 
        updateForRunNameChange(this, oldRunName, newRunName);
        
        restoredRun = restoreRun(this, savedRun, savedResults);% Restore run from the set of saved results
        
        clearResultsInRuns(this);% Delete results from all runs
        delete(this);% Destructor dataset
        deleteRun(this, runName);
        cleanupForRunDeletion(this, runName); % Clean up when run is deleted.
        
        initializeOnSimulationStart(this, writeMode); % Update when sim starts for the model source
        containsRun = containsRunWithName(this, runName); % Check if run name exists in Dataset
        createRun(this, runName);
        mapSDIRunForTs(this, ID);
        
        addEmbeddedRunName(this, embeddedRunName);
        removeEmbeddedRunName(this, embeddedRunName);
        
    end
end

