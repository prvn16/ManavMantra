function allDatasets = getAllDatasets(~)
%% GETALLDATASETS function queries current fixed point tool instance for 
% all datasets involved in top model context

%   Copyright 2016 The MathWorks, Inc.

    allDatasets = [];
    
    model = fxptui.getTopModelFromFPT;
    
    if ~isempty(model)
        allDatasets = fxptds.getAllDatasetsForModel(model);
    end
end