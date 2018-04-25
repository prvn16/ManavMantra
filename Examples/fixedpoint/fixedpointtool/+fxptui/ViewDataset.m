classdef ViewDataset < handle
% VIEWDATASET A mini version of the core dataset that is tightly coupled
% with the Fixed-Point Tool. This provides data and other information
% needed for the UI to show results in the spreadsheet.

  % Copyright 2016-2017 The MathWorks, Inc.
    
   properties (SetAccess = private, GetAccess = private)
       Dataset
       BlockDiagram
       UISelectedResult
       SelectedResultObject
       SpreadsheetScopingManager
       DataManager
   end
   
   methods
       function this = ViewDataset(model)
           if nargin < 1
               [msg, identifier] = fxptui.message('incorrectInputArgsModel');
               e = MException(identifier, msg);
               throwAsCaller(e);
           end
           if nargin > 0
               sys = find_system('type','block_diagram','Name',model);
               if isempty(sys)
                   [msg, identifier] = fxptui.message('modelNotLoaded',model);
                   e = MException(identifier, msg);
                   throwAsCaller(e);
               end
           end
           rep = fxptds.FPTRepository.getInstance;
           this.Dataset = rep.getDatasetForSource(model);
           this.BlockDiagram = get_param(model,'Object');
           scopingEngine = fxptds.FPTGUIScopingEngine.getInstance();
           scopingTable = scopingEngine.getScopingTable;
           % Clear out the changeset table since we have captured the
           % entire scoping table at this point. This prevents double
           % processing of the same entries.
           scopingEngine.getChangesetTable;
           this.SpreadsheetScopingManager = fxptui.SpreadsheetScopingHierarchyGenerator(model, scopingTable);                      
           this.DataManager = fxptui.Web.DataManager;
       end
       
       function addData(this, runName)
           if nargin < 2
               results =  this.getResults;
           else
               results = this.getResults(runName);
           end
           if ~isempty(results)
               this.DataManager.addResultsToTable(results);
           end
       end           
              
       function nodeToResultStruct = getNodeResultStruct(this)
           scopingEngine = fxptds.FPTGUIScopingEngine.getInstance();
           scopingTable = scopingEngine.getChangesetTable;
           nodeToResultMap = this.SpreadsheetScopingManager.generate(scopingTable);
           nodeToResultStruct = this.generateOutputResultStruct(nodeToResultMap);
       end
       
       function runData = getRunData(this)
           runData.forPropose = this.getRunsForProposal;
           runData.forApply = this.getRunsForApply;
           runData.forCompare = this.getRunsWithSignalLogs;
           runData.allRuns = this.getAllRuns;
           runData.lastSelectedRun = this.Dataset.getLastUpdatedRun;
       end
       
       
       function updateDataForRunRename(this, runChangeData)
           this.DataManager.removeRunFromTable(runChangeData.oldValue);
           this.addData(runChangeData.newValue);   
       end
       
       function updateChangedResults(this, results)
           if ~isempty(results)
               this.DataManager.addResultsToTable(results);
           end
       end
       
       function nodeToResultStruct = getNodeResultStructForRunRename(this)
           scopingEngine = fxptds.FPTGUIScopingEngine.getInstance();
           scopingTable = scopingEngine.getScopingTable;
           % Clear out the changeset table since we have captured the
           % entire scoping table at this point. This prevents double
           % processing of the same entries.
           scopingEngine.getChangesetTable;
           nodeToResultMap = this.SpreadsheetScopingManager.regenerateOnEntireTable(scopingTable);
           nodeToResultStruct = this.generateOutputResultStruct(nodeToResultMap);
       end
       function allRunNames = getAllRuns(this)
       % GETALLRUNS method returns all run names for a given system
           fpt = fxptui.FixedPointTool.getInstance(this.BlockDiagram.getFullName);
           
           % Get system name for conversion
           sudName = fpt.getSystemForConversion;
           
           % Query all run names for a given system
           allRunNames = fxptui.getRunsForSystem(sudName);
       end
       function runNames = getRunsForProposal(this)
           fpt = fxptui.FixedPointTool.getInstance(this.BlockDiagram.getFullName);
           sudName = fpt.getSystemForConversion;
           if isempty(sudName)
               sudName = this.BlockDiagram.getFullName;
           end
           runNames = fxptui.getRunsForProposalForSystem(sudName);
           if all(cellfun('isempty',runNames))
               runNames = {};
           end
               
       end
       
       function runNames = getRunsForApply(this)
           fpt = fxptui.FixedPointTool.getInstance(this.BlockDiagram.getFullName);
           sudName = fpt.getSystemForConversion;
           if isempty(sudName)
               sudName = this.BlockDiagram.getFullName;
           end
           runNames = fxptui.getRunsWithProposalForSystem(sudName);
           if all(cellfun('isempty',runNames))
               runNames = {};
           end
       end
       
       function runNames = getRunsWithSignalLogs(this)
           DataLayer  = fxptds.DataLayerInterface.getInstance();
           runNames = DataLayer.getAllRunNamesWithSignalLoggingResults(this.Dataset);
       end
      
      function results = getResults(this, varargin)
          % Get results for the top model
          runName = {};
          if ~isempty (varargin)
              runName = varargin{1};
          end
          
          DataLayer = fxptds.DataLayerInterface.getInstance();
          if ~isempty(runName)
            results = DataLayer.getAllResultsFromRunUsingModelSource(this.BlockDiagram.getFullName, runName);
          else
            results = DataLayer.getAllResultsUsingModelSource(this.BlockDiagram.getFullName);
          end
      end
      
      function recordRows = getRecords(this, queryObject)
          scopedIds = {};
          if ~isempty(queryObject.TreeSelection)
              scopedIds = this.SpreadsheetScopingManager.getScopingIds(queryObject.TreeSelection);
          end
          recordRows = this.DataManager.getData(queryObject, scopedIds);         
      end
      
      function dataForVisualizer = getVisualizerRecordsForRun(this, queryObject, runName)
      % Get Visualizer records for a given query object and a specific
      % runname for which data needs to be retrieved
          % Get data from datamanager using query object 
          if isempty(runName)
              runName = this.Dataset.getLastUpdatedRun;
          end
          dataForVisualizer = this.DataManager.getDataForVisualizer(queryObject, runName);
          dataForVisualizer.RunName = runName;
          dataForVisualizer.inScopeIds = [];
          
          if dataForVisualizer.total > 0
              % Query spreadsheet scoping ids 
              scopedIds = {};
              if ~isempty(queryObject.TreeSelection)
                  scopedIds = this.SpreadsheetScopingManager.getScopingIds(queryObject.TreeSelection);
              end

              % Compute scoping information based on tree selection
              scopingIds = dataForVisualizer.rows.Row;
              matchingIndices = false(dataForVisualizer.total, 1);
              for i = 1:numel(scopedIds)
                matchingIndices = matchingIndices | strcmp(scopingIds, scopedIds{i});
              end
              dataForVisualizer.inScopeIds = matchingIndices;
          end
          
      end
      function result = getSelectedResult(this)
          result = this.SelectedResultObject;
      end
      function updateLastSelectedRun(this, runName)
          this.Dataset.setLastUpdatedRun(runName);
      end
      function lastSelectedRun = getLastSelectedRun(this)
          lastSelectedRun = this.Dataset.getLastUpdatedRun;
      end
   end 
   
   methods (Hidden)
       function setSelectedResultID(this, clientSelectedResult)           
           this.UISelectedResult = clientSelectedResult;
           if ~isempty(clientSelectedResult.id)
               this.SelectedResultObject = fxptui.ScopingTableUtil.getResultForClientResultID(clientSelectedResult.id);
           end
       end
       
       function idx = getIndexOfResult(this, result)
          idx = [];
          scopingId = result.getScopingId;
          if ~isempty(scopingId)
             idx = this.DataManager.getIndexOfRowId(scopingId);
          end
       end
       
       function deleteRun(this, runName)
           allDs = fxptds.getAllDatasetsForModel(this.BlockDiagram.getFullName);
           for i = 1:numel(allDs)
               allDs{i}.deleteRun(runName);               
           end
           this.DataManager.removeRunFromTable(runName);
           % Update the code view if it exists
           fptInstance = fxptui.FixedPointTool.getExistingInstance;
           if ~isempty(fptInstance)
               fptInstance.getExternalViewer.runsDeleted(runName);
           end
       end
       
       function updateSpreadsheetMappingForVariantAddition(this, updatedTreeData)
           % Update the spreadsheet scoping manager result mapping for the
           % new tree data (during a variant subsystem creation for MLFB
           % workflows)
           this.SpreadsheetScopingManager.updateMappingForVariantAddition(updatedTreeData);
       end 
       
       function clearDatabase(this)
          this.DataManager.clearTable; 
       end
       
       % test only API
       function dataTable = getTable(this)
           dataTable = this.DataManager.getTable;
       end
   end
   
   methods (Access = 'private')
       function nodeToResultStruct = generateOutputResultStruct(~, nodeToResultMap)
           keys = nodeToResultMap.keys;
           values = nodeToResultMap.values;
           nodeToResultStruct = struct;
           nodeToResultStruct.treeIds = keys;
           nodeToResultStruct.results = values;
       end
   end

end
