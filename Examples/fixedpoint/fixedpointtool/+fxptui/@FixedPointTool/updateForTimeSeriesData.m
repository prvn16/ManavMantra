function updateForTimeSeriesData(this, eventData)
% UPDATEFORTIMESERIESDATA Maps the results collected in the SDI to the results collected in FPT.

%   Copyright 2011-2017 The MathWorks, Inc.

rootModel = this.getModel;

if ~isempty(eventData.modelName) && ~strcmpi(rootModel, eventData.modelName)
    return; % Run was added for a different model.
end

if isempty(eventData.modelName)
    % FPA calls the sdiEngine.createRunFromNamesAndValues API that does not
    % require the model name to be passed with the eventData. In this case the
    % modelName will be empty.
    eventData.modelName = rootModel;
end

DataTypeWorkflow.SigLogServices.updateFromEventData(eventData);

%% Revisit where this needs to stop. This might not work for signal builder
% Update the status of the record button when restoring the UI. This is triggered after data has been updated in the tool.
if ~isempty(this.InitSDIRecordState)
    sdiEngine = Simulink.sdi.Instance.engine();
    if strcmpi(this.InitSDIRecordState,'off')
        sdiEngine.stop;
    end
end
end
