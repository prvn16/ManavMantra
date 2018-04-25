function [ok, errmsg] = compareRunsForSelection(h)
%PLOTDIFFFORSELECTION


%   Copyright 2011-2014 The MathWorks, Inc.

ok = true;
errmsg = '';

me = fxptui.getexplorer;
selection = me.getSelectedListNodes;
model = selection.getHighestLevelParent;
appData = SimulinkFixedPoint.getApplicationData(model);
ds = appData.dataset;
runObj1 = ds.getRun(selection.getRunName);
runID1 = runObj1.getTimeSeriesRunID;
[runNames, ~] = h.getRunsForDiff;
if numel(runNames) > 1
    if isempty(h.selectedRunForDiff); return; end
    runObj2 = ds.getRun(h.selectedRunForDiff);
    runID2 = runObj2.getTimeSeriesRunID;
else
    runObj2 = ds.getRun(runNames{:});
    runID2 = runObj2.getTimeSeriesRunID;
end

% compare runs here and select the appropriate radio button.
if selection.isPlottable
    if isempty(h.selectedChannelForDiff)
        chIdx = 1;
    else
        idx = find(selection.getTimeSeriesID == 0);
        chIdx = h.selectedChannelForDiff;
        for i = 1:numel(idx)
            if chIdx >= idx(i)
                chIdx = chIdx + 1;
            end
        end
    end
    fxptui.Plotter.compareRuns(runID1, runID2,selection.getTimeSeriesID(chIdx));
else
    fxptui.Plotter.compareRuns(runID1, runID2,[]);
end



