function [runNames, value] = getRunsForDiff(h, varargin)
%GETRUNSFORDIFF Get the runsforDiff.
%   OUT = GETRUNSFORDIFF(ARGS) <long description>

%   Copyright 2011-2017 The MathWorks, Inc.


runNames = {''};
value = 0;
if slfeature('FPTWeb')
    if nargin > 1
        selection = varargin{1};
    end
else
    me = fxptui.getexplorer;
    if isempty(me); return; end
    selection = me.getSelectedListNodes;
end
model = selection.getHighestLevelParent;
appData = SimulinkFixedPoint.getApplicationData(model);
ds = appData.dataset;

% TODO: check if subdatasets runnames are not required? 
DataLayer = fxptds.DataLayerInterface.getInstance();
allRunNames = DataLayer.getAllRunNamesUsingApplicationData(appData);

cnt = 1;

if ~isempty(allRunNames)
    if strcmpi(h.methodSelection, 'comparesignals') || strcmpi(h.methodSelection, 'selectchannelforcomparesignals')
        for i = 1:numel(allRunNames)
            runObj = ds.getRun(allRunNames{i});
            res = runObj.getResultByID(selection.getUniqueIdentifier);
            if ~isempty(res) && res.isPlottable
                runNames{cnt} = allRunNames{i};
                cnt = cnt+1;
            end
        end
    elseif strcmpi(h.methodSelection, 'compareruns') || strcmpi(h.methodSelection, 'selectchannelforcompareruns')
        for i = 1:numel(allRunNames)
            res = ds.getRun(allRunNames{i}).getResults;
            hasSignals = false;
            for k = 1:numel(res)
                if(res(k).isPlottable)
                    hasSignals = true;
                    break;
                end
            end
            if hasSignals
                runNames{cnt} = allRunNames{i};
                cnt = cnt+1;
            end
        end
    end
    runNames = setdiff(runNames,{selection.getRunName});
    runNames = sort(runNames);
    h.runsForDiff = runNames;
    if ~all(cellfun(@isempty,runNames)) && isempty(h.selectedRunForDiff)
        h.selectedRunForDiff = runNames{1};
    end
end

% [EOF]
