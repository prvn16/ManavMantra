function allSrc = getAllSources(this)
%% GETALLSOURCES function gets all model names from ModelDataSetMap of fxptds.FPTRepository
%
% returns allSrc is list of all model names 

%   Copyright 2016 The MathWorks, Inc.

    % returns an array of sources that are associated with dataset objects in the repository.
    allSrc(1:this.ModelDatasetMap.getCount) = {''};
    for i = 1:this.ModelDatasetMap.getCount
        allSrc{i} = this.ModelDatasetMap.getKeyByIndex(i);
    end
end
    
