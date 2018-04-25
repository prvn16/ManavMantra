function cb_hiliteResultInFPT (blkObject)
%% CB_HILITERESULTINFPT is a callback function
% This callback is used to select the block result in FPT.
%   Copyright 2014-2017 The MathWorks, Inc.

me = fxptui.getexplorer;
fpt = fxptui.FixedPointTool.getExistingInstance;

if ~isempty(me) || ~isempty(fpt)
    fxptui.showFPT;
    
    [blockResult,runName] = getResultForObject(blkObject);
    if isempty(blockResult)
        % if is true when the result is empty in all the runs or
        % results do not have any interesting info to show.
        fxptui.showdialog('resultNotFound',fxptui.message('resultsNotCollectedWarnMsg'));
        return;
    end
    
    if ~isempty(fpt)
        dataObj = fxptds.SimulinkDataArrayHandler;
        selectedBlkObj = fpt.getSelectedTreeNode;
        identifier.Object = selectedBlkObj;
        uniqueId = dataObj.getUniqueIdentifier(identifier);
        if ~blockResult.isWithinProvidedScope(uniqueId)
            % if the block is not within the provided scope then we need to
            % select the parent tree node first and then the result
            fpt.selectTreeAndThenResultInUI(blkObject.getParent, blockResult);
        else
            fpt.selectResultInUI(blockResult);
        end
    else
        uniqueId = me.getSelectedTreeNode.getUniqueIdentifier;
        if ~blockResult.isWithinProvidedScope(uniqueId)
            % if the block is not within the provided scope then we need to
            % select the parent tree node
            me.selectnode(blkObject.getParent.getFullName);
        end
        if ~selectListViewNodeInFPT(me, blockResult)
            [rowFilter,currentRowFilterIndex] = getCurrentRowFilterAndIndex(me);
            if ~isequal(currentRowFilterIndex,0) && rowFilterQuestDlg(rowFilter,runName)
                % change the row filter to select the all results
                selectListViewNodeInFPT(me,blockResult);
            end
        end
    end
end

end


function [blockResult,runName] = getResultForObject(blkObject)

% get the FPT data set
ds = getFPTDatasetForModel(blkObject);

runName = ds.getLastUpdatedRun;

blockResult = '';

autoscaleExtensions =  SimulinkFixedPoint.EntityAutoscalersInterface.getInterface();
autoscaler = autoscaleExtensions.getAutoscaler(blkObject);
pathItem = autoscaler.getPortMapping(blkObject, [], 1);

if isempty(pathItem)
    pathItem = '1';
end
        
if ~isempty(runName)
    fptRun = ds.getRun(runName);
    blockResult = getResultWithInterestingInformation(fptRun.getResult(blkObject, pathItem));
end

if isempty(blockResult)
    % The result for the block in the last updated entry is either
    % empty or does not have any interesting information to show. Try
    % searching for results in other available runs.
    
    % if the result is not available in the given runs, find the
    % result in other runs...
    blockResultFromAllRuns = {};
    
    DataLayer = fxptds.DataLayerInterface.getInstance();
    runNames = DataLayer.getAllRunNamesWithResults(ds);
       
    for idx=1:numel(runNames)
        runObj = ds.getRun(runNames{idx});
        resultsInRun = runObj.getResult(blkObject, pathItem);
        if ~isempty(resultsInRun)
            blockResultFromAllRuns{end+1} = resultsInRun; %#ok
        end
    end
    blockResultFromAllRuns = [blockResultFromAllRuns{:}];
    
    blockResult = getResultWithInterestingInformation(blockResultFromAllRuns);
    if ~isempty(blockResult)
        runName = blockResult.getRunName;
    end
end
end


function ds = getFPTDatasetForModel(blockObject)
% return the data set for the block object.
rep = fxptds.FPTRepository.getInstance;
ds = rep.getDatasetForSource(bdroot(blockObject.getFullName));
end

function [rowFilter,currentRowFilterIndex] = getCurrentRowFilterAndIndex (me)
rowFilter = me.find('-isa','DAStudio.ToolBarComboBox');
currentRowFilterIndex = rowFilter.getCurrentItem;
end

function isSelected = selectListViewNodeInFPT(me,blockResult)
isSelected = me.imme.selectListViewNode(blockResult);
end
function changeFilter = rowFilterQuestDlg (rowFilter,runName)
% row filter is not set to All results

choice = questdlg(fxptui.message('textQuestDlgRowFilter',runName), ... % Text
    fxptui.message('noResultFoundTitle'), ...% Title
    fxptui.message('btnChangeFilter'),...% 1st option
    fxptui.message('btnCancel'),... %2nd option
    fxptui.message('btnChangeFilter')); % default selected option
switch choice
    case fxptui.message('btnChangeFilter')
        changeFilter = 1;
        rowFilter.selectItem(0);
    otherwise
        changeFilter = 0;
        
end
end

function result = getResultWithInterestingInformation(allResults)
result = '';
for cnt = 1 : numel(allResults)
    if allResults(cnt).hasInterestingInformation
        % if the block result found in other available run has any
        % interesting info to show, then break the loop and select
        % it for the user.
        result = allResults(cnt);
        break;
    end
end
end

