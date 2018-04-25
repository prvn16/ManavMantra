classdef FPTRepository < handle
% FPTREPOSITORY Singleton class that stores FPTDataset objects.
    
%   Copyright 2012-2016 The MathWorks, Inc.

    properties(Constant,GetAccess=private)
        % Stores the class instance as a constant property
        FPTRepositoryInstance = fxptds.FPTRepository;
    end
    
    properties (GetAccess=private, SetAccess=private)
        ModelDatasetMap;    % Mapping between the source(model/project) and the dataset object.
    end
    
    methods (Static)
        function obj = getInstance
        % Returns the stored instance of the repository.
            obj = fxptds.FPTRepository.FPTRepositoryInstance;
        end
    end
    
    methods (Access=private)
        function this = FPTRepository
            this.ModelDatasetMap = Simulink.sdi.Map(char('a'),?handle);
            mlock; % Prevents clearing of the class from MATLAB.
        end
    end
        
    methods
        datasetObj = getDatasetForSource(this, srcName);
    end
    
    methods(Hidden)
        createDataset(this, model);
        allDatasets = getAllDatasets(this);
        updateSourceNameForDataset(this, oldSourceName, newSourceName);
        allSrc = getAllSources(this);
        removeDatasetForSource(this,srcName);
    end    
end
