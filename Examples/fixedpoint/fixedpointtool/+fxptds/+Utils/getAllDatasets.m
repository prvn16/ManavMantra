function allDatasets = getAllDatasets(appData)
%% GETALLDATASETS function gets all datasets mapped to a given top model specific ApplicationData
% appData is an instance of SimulinkFixedPoint.ApplicationData

%   Copyright 2016 The MathWorks, Inc.
	
	% Initialize all datasets to empty
	allDatasets = {};
    
    % If appData is empty, return
    if isempty(appData)
       return;
    end
    
	% Query appData's top model dataset and add it to allDatasets 
	topModelDataset = appData.dataset;
	allDatasets{end + 1} = topModelDataset;

	% Query all submodel datasets from subDatasetMap of the appData
	subModelDatasetMaps = appData.subDatasetMap;
	allMdlRefDatasetKeys = subModelDatasetMaps.keys;

	% Add each dataset to allDatasets 
	for idx = 1:length(allMdlRefDatasetKeys)
        subModelDataset  = subModelDatasetMaps(allMdlRefDatasetKeys{idx});
        allDatasets{end + 1} = subModelDataset; %#ok
	end
end
