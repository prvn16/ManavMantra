function postProcessSimulationData(this)
%POSTPROCESSSIMULATIONDATA Post processing of simulation data collected.

%   Copyright 2015-2017 The MathWorks, Inc.

bd = get_param(this.Model,'Object');

allDatasets = this.getAllDatasets;
for datasetIndex = 1:length(allDatasets)
   currentRunObj = allDatasets{datasetIndex}.getRun(bd.FPTRunName);
   currentRunObj.deleteInvalidResults();
end


% merge results from model references instances
try
    SimulinkFixedPoint.ApplicationData.mergeResultsInReferenceModels(bd.getFullName, bd.FPTRunName);
catch fpt_exception%#ok<NASGU>
end

allDatasets = this.getAllDatasets;
try
    SimulinkFixedPoint.Autoscaler.collectPostSimData(allDatasets, bd.FPTRunName);
catch fpt_exception%#ok<NASGU>
end

% We need to enable codeview if MLFb results are present
if ~isempty(this.StartupController)
    this.StartupController.publishEnableCodeView;
end

% Notify F2F and Code View (if open) that a simulation has completed
% and run updating is complete.
this.getExternalViewer.markSimCompleted();
% Re-enable code view if present
this.enableCodeView(true);

