function [ok, errmsg] = plotDiffForSelection(h)
%PLOTDIFFFORSELECTION <short description>
%   OUT = PLOTDIFFFORSELECTION(ARGS) <long description>

%   Copyright 2011-2016 The MathWorks, Inc.

ok = true;
errmsg = '';

me = fxptui.getexplorer;
selection = me.getSelectedListNodes;
if isempty(selection); return; end
model = selection.getHighestLevelParent;
appData = SimulinkFixedPoint.getApplicationData(model);
ds = appData.dataset;
if ~selection.hasOneChannel && isempty(h.selectedChannelForDiff)
    return;
end
[runNames, ~] = h.getRunsForDiff;
if numel(runNames) > 1
    if isempty(h.selectedRunForDiff); return; end
    runName = h.selectedRunForDiff;
else
    runName = runNames{:};
end
res2 = ds.getRun(runName).getResultByID(selection.getUniqueIdentifier);

if numel(selection.getTimeSeriesID) > 1
    if isempty(h.selectedChannelForDiff); return; end
    idx = find(selection.getTimeSeriesID == 0);
    chIdx = h.selectedChannelForDiff;
    for i = 1:numel(idx)
        if chIdx >= idx(i)
            chIdx = chIdx + 1;
        end
    end
    fxptui.Plotter.plotDifference(selection.getTimeSeriesID, res2.getTimeSeriesID, chIdx); 
else
    fxptui.Plotter.plotDifference(selection.getTimeSeriesID, res2.getTimeSeriesID, []); 
end
    

% [EOF]
