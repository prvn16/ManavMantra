function updateForTimeSeriesData(h, eventData)
% UPDATEFORTIMESERIESDATA Maps the results collected in the SDI to the results collected in FPT.

%   Copyright 2011-2017 The MathWorks, Inc.

% re-populate the referenced models if they were previously closed
success = loadReferencedModels(h);
if ~success; return; end

rootModel = h.getTopNode.getDAObject;
if ~isempty(eventData.modelName) && ~strcmpi(rootModel.getFullName, eventData.modelName)
    return; % Run was added for a different model.
end

if isempty(eventData.modelName)
    % FPA calls the sdiEngine.createRunFromNamesAndValues API that does not
    % require the model name to be passed with the eventData. In this case the
    % modelName will be empty.
    eventData.modelName = rootModel.getFullName;
end

DataTypeWorkflow.SigLogServices.updateFromEventData(eventData);

%update listview
h.getFPTRoot.fireHierarchyChanged;

%------------------------------------------------------
%[EOF]
