function [runNames, selection] = getrunsforproposal(h) %#ok
%GETRUNSFORPROPOSAL Get the runsforproposal.

%   Copyright 2011-2017 The MathWorks, Inc.

runNames = {};
selection = '';
me = fxptui.getexplorer;
if isempty(me); return; end


dataset = me.getdataset;
dataLayer = fxptds.DataLayerInterface.getInstance();
allRunNames = dataLayer.getAllRunNames(dataset);

if all(cellfun(@isempty,allRunNames))  
    allRunNames = {dataset.getCurrentRunName};
else
    allRunNames = sort(allRunNames);
end

selection = 0;
% Update the application data based on the default selection.
appData = SimulinkFixedPoint.getApplicationData(me.getRoot.daobject.getFullName);
appData.ScaleUsing = allRunNames{1};
appData.ResultsLocation = allRunNames{1};
me.SelectedRunForProposal = true;

% [EOF]
