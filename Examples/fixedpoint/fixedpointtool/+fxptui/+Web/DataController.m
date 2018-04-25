classdef DataController < handle
% DATACONTROLLER Class definition to communicate core data (spreadsheet +
% histogram) with the web based FPT

% Copyright 2016-2017 The MathWorks, Inc.

properties(SetAccess = private, GetAccess = private)
    SpreadsheetController
    VisualizerController
    ViewDataset
    Model
    Subscriptions
    GridSelectionSubscription
    SpreadhseetSubscribeChannel = '/fpt/spreadSheet/store';
    RowSelectionSubscribeChannel = '/fpt/spreadSheet/dataRowSelection';
    RunDeleteSubscribeChannel = '/fpt/spreadsSheet/deleteRun';
    HistogramSelectedSubscribeChannel = '/visualizer/histogramSelected'; 
    CanvasMovedSubscriptionChannel = '/visualizer/canvasMoved'
    RunInfoPublishChannel = '/fpt/data/runData';
    GridRenderCompleteChannel = '/fpt/spreadsheet/renderComplete';
    VisualizerForSpecificRunSubscribeChannel = '/visualizer/fetchDataForSpecificRun';
    LastUsedClientMessage
    DelayedRowSelectionAfterRunRename
end

methods
    function this = DataController(uniqueID)
        connector.ensureServiceOn;
        this.addUniqueIDToChannels(uniqueID);
        this.Subscriptions{2} = message.subscribe(this.RowSelectionSubscribeChannel,@(msg)sendDataForSpreadsheetSelection(this,msg));
        this.Subscriptions{3} = message.subscribe(this.RunDeleteSubscribeChannel, @(msg)sendDataForRunDeletion(this,msg));
        this.Subscriptions{4} = message.subscribe(this.HistogramSelectedSubscribeChannel, @(msg)sendDataForHistogramSelection(this,msg));
        this.Subscriptions{5} = message.subscribe(this.CanvasMovedSubscriptionChannel, @(data)this.sendDataForCanvasMoved(data));
        this.Subscriptions{6} = message.subscribe(this.VisualizerForSpecificRunSubscribeChannel, @(data)this.sendVisualizerDataForSpecificRun(data));
        this.SpreadsheetController = fxptui.Web.SpreadsheetController(uniqueID);
        this.VisualizerController = fxptui.Web.VisualizerController(uniqueID);
    end
    
    function setModel(this, modelName)
        % Set the model name on the controller so it knows what data to
        % retrieve
        if ~isequal(this.getModel, modelName)
            this.Model = modelName;
            this.ViewDataset = fxptui.ViewDataset(modelName);
        end
    end
    
    function clearDatabase(this)
       this.ViewDataset.clearDatabase; 
    end      
    
     function updateData(this, opCode,  updatedRun)
%     % Update the spreadsheet and the visualizer with results & scoping
%     % hierarchy data based on the opcode sent by the engine. 
        ds = this.getDataset(this.Model);
        if nargin < 3
            if ~isempty(ds)
                switch(opCode)
                    case {'RequestAllData', 'allData'}
                        runName = ds.getAllRunNames;
                        results = this.ViewDataset.getResults;%#ok
                    otherwise
                        runName = ds.getLastUpdatedRun;
                        results = this.ViewDataset.getResults(runName);%#ok
                end
            end
        else
            runName = updatedRun;
            results = this.ViewDataset.getResults(runName); %#ok
        end
        if isempty(runName)
            return;
        end
        if ~iscell(runName)
            runName = {runName};
        end
        this.ViewDataset.getNodeResultStruct;
        for i = 1:numel(runName)
            this.ViewDataset.addData(runName{i});
        end
        runInfo = this.ViewDataset.getRunData;
        message.publish(this.RunInfoPublishChannel, struct('data', runInfo));
        this.SpreadsheetController.updateSpreadsheet;
     end
    
    function updateOnRunChange(this, runChanged)
        % When the run name is changed, delegate to the spreadsheet
        % controller to update its data.
        results = this.ViewDataset.getResults(runChanged.newValue);%#ok
        selectedResult = this.getSelectedResult;
        if ~isempty(selectedResult)
            % Select the changed result row after the spreadsheet is updated       
            this.DelayedRowSelectionAfterRunRename = @()this.selectResult(selectedResult);
        end
        this.ViewDataset.getNodeResultStructForRunRename;
        runInfo = this.ViewDataset.getRunData;
        message.publish(this.RunInfoPublishChannel, struct('data', runInfo));
        this.ViewDataset.updateDataForRunRename(runChanged);
        this.SpreadsheetController.updateSpreadsheet;        
    end
    
    function updateOnProposedDTChange(this, results)
        % When proposed DT is changed, fxptui.Web.ProposedDTChangeHandler
        % will delegate update data responsibility to SpreadsheetController
        % and VisualizerController
            % Update last selected run in ViewDataset
            data.SelectedRun  = results(1).getRunObject.getRunName;
            this.ViewDataset.updateLastSelectedRun(data.SelectedRun);
            
            this.ViewDataset.updateChangedResults(results);
            
            
            % Publish run information on proposedDT change
            % g1552254
            runInfo = this.ViewDataset.getRunData;
            message.publish(this.RunInfoPublishChannel, struct('data', runInfo));
            this.SpreadsheetController.updateSpreadsheet;
            
            % Visualizer could not handle partial update and only group results
            % would show up. 
            this.sendVisualizerDataForSpecificRun(data);
    end
    
    function delete(this)
        this.unsubscribe();
        delete(this.SpreadsheetController);
        delete(this.VisualizerController);
        delete(this.ViewDataset);
    end   
end

methods (Hidden)    
    function model = getModel(this)
        model = this.Model;
    end
    
    function spreadsheet = getSpreadsheetController(this)
        spreadsheet = this.SpreadsheetController;
    end
    
    function visualizer = getVisualizerController(this)
        visualizer = this.VisualizerController;
    end
    
    function viewDS = getViewDataset(this)
        viewDS = this.ViewDataset;
    end
    
    function result = getSelectedResult(this)
        result = this.ViewDataset.getSelectedResult;
    end   
    
    function selectResult(this, result)
        if ~isempty(this.GridSelectionSubscription)
            message.unsubscribe(this.GridSelectionSubscription);
            this.GridSelectionSubscription = [];
        end
        index = this.getResultIndex(result);
        if ~isempty(index)
            this.SpreadsheetController.selectResult(result, index);
        end
    end
    
    function index = getResultIndex(this, result)
        index = this.ViewDataset.getIndexOfResult(result);
    end
    
    function setDelayedResultSelection(this, result)
        this.GridSelectionSubscription = message.subscribe(this.GridRenderCompleteChannel, @(msg)this.selectResult(result));
    end
    
    function setupVisualizer(this)
    % Send server ready to client to construct visualizer document
    % panel
        this.VisualizerController.sendServerReady();
    end
    
    function sendDataForHistogramSelection(this, data)
    % Highlights spreadsheet row in FPT on selecting 
    % a column in Visualizer section    
        scopingId = this.VisualizerController.getRowIdForSignalIndex(data.SignalIndex);
        result = fxptui.ScopingTableUtil.getResultForClientResultID(scopingId);
        % If result found, select result in spreadsheet
        if ~isempty(result)
            this.selectResult(result);
        end
    end
    
    function sendDataForSpreadsheetSelection(this, clientSelectedResult)
        % Selects histogram that maps to the selected row in Spreadsheet
               
        % If a delayed row selection after a run rename is a function
        % handle, then execute it at this point. % After a run rename, the
        % selection data sent from the client contains the old result
        % information. We will discard that and select the updated result
        % instead.Once the spreadsheet selection is updated, the visualizer
        % and result details will be updated automatically.
        if isa(this.DelayedRowSelectionAfterRunRename, 'function_handle')
            this.DelayedRowSelectionAfterRunRename();
            this.DelayedRowSelectionAfterRunRename = [];
        else        
            % Select chosen result in view dataset
            this.ViewDataset.setSelectedResultID(clientSelectedResult);
            
            % Select histogram that maps to the client selected result
            this.VisualizerController.selectHistogram(clientSelectedResult.id);
        end
    end
    
    function sendDataForRunDeletion(this, clientData)
        % Deletes histograms when a run is deleted in run browser
        
        % Delete run from view dataset
        this.ViewDataset.deleteRun(clientData.deletedRun);
        
        runInfo = this.ViewDataset.getRunData;
        message.publish(this.RunInfoPublishChannel, struct('data', runInfo));
        
        % Delete run specific results /rows in spreadsheet
        this.SpreadsheetController.updateSpreadsheet;
        
        % Delete histograms mapping to the given run
        this.VisualizerController.clearHistogramsForDeletedRun(clientData);
    end
    
    function data = getSpreadsheetData(this, clientMessage)
    % Get the data to be rendered in the spreadsheet
        
        if nargin < 2
            queryObject = fxptui.Web.Query;
        else
            queryObject = fxptui.Web.Query(clientMessage);
        end
        data.records = [];
        data.total = 0;
        
        selectedTreeID = queryObject.TreeSelection;
        if isempty(selectedTreeID)
            return;
        end
        
        tableRecords = this.ViewDataset.getRecords(queryObject);
        if ~isempty(tableRecords.rows)
            data.records = table2struct(tableRecords.rows);
        end
        % The Range/Proposal properties are used to manage the toolstrip state on the UI
        data.resultsHaveSimRange = tableRecords.resultsHaveSimRange;
        data.resultsHaveDeriveRange = tableRecords.resultsHaveDeriveRange;
        data.resultsHaveProposals = tableRecords.resultsHaveProposals;
        data.total = tableRecords.total;        
    end
    
    function sendDataForCanvasMoved(this, data)
    % sendDataForCanvasMoved function sends visualizer data for  new canvas
    % position 
        % Reroute request to VisualizerControlelr to send data for canvas
        % move
        this.VisualizerController.sendDataForCanvasMove(data);
    end
    
    % Test only API
    function data = getData(this)
        data = this.ViewDataset.getTable;
    end
    
    function sendVisualizerDataForSpecificRun(this, data)
    % SendVisualizerDataForSpecificRun uses a clientMessage to construct a
    % fxptui.Web.Query and notifies Visualizer of the query to fetch data
    % for a specific run (not necessarily the lastUpdatedRun) and send it to client
        
        if ~isempty(this.LastUsedClientMessage) && slfeature('Visualizer')
            clientMessage = this.LastUsedClientMessage;
            clientMessage.hiddenRuns = {};
            queryObject = fxptui.Web.Query(clientMessage);

            this.VisualizerController.LastSelectedRun = data.SelectedRun;
            
            % Get data from visualizer
            dataForVisualizer = this.ViewDataset.getVisualizerRecordsForRun(queryObject, data.SelectedRun);

            % Update visualizer using data queried from datamanager
            this.VisualizerController.updateVisualizerUsingDB(dataForVisualizer);
        end
    end
    function sendVisualizerData(this, clientMessage)
    % SENDVISUALIZERDATA function sends visualizer data for a given client
    % message
        if slfeature('Visualizer')
            queryObject = fxptui.Web.Query(clientMessage);

            % Get data from visualizer
            dataForVisualizer = this.ViewDataset.getVisualizerRecordsForRun(queryObject, this.VisualizerController.LastSelectedRun);
            this.VisualizerController.LastSelectedRun = dataForVisualizer.RunName;
            % Update visualizer using data queried from datamanager
            this.VisualizerController.updateVisualizerUsingDB(dataForVisualizer);
        end
    end
    function setClientMessage(this, clientMessage)
    % SetClientMessage caches the client message     
        if ~isempty(this.LastUsedClientMessage)
            if ~strcmpi(clientMessage.sort.attribute, this.LastUsedClientMessage.sort.attribute) || ...
                clientMessage.sort.descending ~= this.LastUsedClientMessage.sort.descending || ...
                ~strcmpi(clientMessage.treeSelection, this.LastUsedClientMessage.treeSelection) || isempty(this.VisualizerController.LastSelectedRun)
                this.sendVisualizerData(clientMessage);
            end
        else
            % Even if we have an empty cached message, we shouldn't send
            % data unless the last selected run is deleted.
            if isempty(this.VisualizerController.LastSelectedRun)
                this.sendVisualizerData(clientMessage);
            end
        end
        this.LastUsedClientMessage = clientMessage;
    end
end

methods (Access = private)
    function fptDataSet = getDataset(~, modelName)
        fptDataSet = [];
        if ~isempty(modelName)
            fptRepositoryInstance = fxptds.FPTRepository.getInstance;
            fptDataSet = fptRepositoryInstance.getDatasetForSource(modelName);
        end
    end
    
    function addUniqueIDToChannels(this, uniqueID)
        this.SpreadhseetSubscribeChannel = sprintf('%s/%s',this.SpreadhseetSubscribeChannel, uniqueID);
        this.RowSelectionSubscribeChannel = sprintf('%s/%s',this.RowSelectionSubscribeChannel, uniqueID);
        this.RunDeleteSubscribeChannel = sprintf('%s/%s',this.RunDeleteSubscribeChannel,uniqueID);
        this.HistogramSelectedSubscribeChannel = sprintf('%s/%s',this.HistogramSelectedSubscribeChannel,uniqueID);
        this.CanvasMovedSubscriptionChannel = sprintf('%s/%s', this.CanvasMovedSubscriptionChannel, uniqueID);
        this.VisualizerForSpecificRunSubscribeChannel = sprintf('%s/%s', this.VisualizerForSpecificRunSubscribeChannel, uniqueID);
        
        this.RunInfoPublishChannel = sprintf('%s/%s',this.RunInfoPublishChannel,uniqueID);
        this.GridRenderCompleteChannel = sprintf('%s/%s',this.GridRenderCompleteChannel, uniqueID);
    end      
    
    function unsubscribe(this)
        for i = 1:numel(this.Subscriptions)
            message.unsubscribe(this.Subscriptions{i});
        end
    end
end

end
