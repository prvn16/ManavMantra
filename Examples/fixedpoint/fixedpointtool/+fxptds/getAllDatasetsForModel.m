function datasetArray = getAllDatasetsForModel(system)
%GETALLDATASETSFORMODEL Get all the datasets for a given system/model

%   Copyright 2016 The MathWorks, Inc.

datasetArray = {};
mdlList = fxptui.getValidSystemList(system);
rep = fxptds.FPTRepository.getInstance;
for idx = 1:length(mdlList)
    load_system(mdlList{idx});
    srcID = Simulink.ID.getSID(mdlList{idx});    
    datasetArray{end+1} = rep.getDatasetForSource(srcID); %#ok<AGROW>
end
