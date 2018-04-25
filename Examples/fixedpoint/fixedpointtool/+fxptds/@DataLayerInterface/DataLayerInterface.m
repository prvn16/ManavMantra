classdef DataLayerInterface < handle
%% DATALAYERINTERFACE class implements a singleton instance which acts as a unified gateway for accessing fxptds.* APIs

%   Copyright 2016-2017 The MathWorks, Inc.

    methods (Static)
        function obj = getInstance
        % Returns the stored instance of the repository.
            persistent localObj
            if isempty(localObj) || ~isvalid(localObj)
                localObj = fxptds.DataLayerInterface;
            end
            obj = localObj;
        end
    end
    
    methods (Access=private)
        function this = DataLayerInterface
            
        end
    end
    methods
        runNames = getAllRunNamesWithResults(this, dataset);
        runNames = getAllRunNamesForProposal(this, dataset);
        runNames = getAllRunNamesUsingApplicationData(this, applicationData);
        runNames = getAllRunNamesUsingModelSource(this, modelName);
        runNames = getAllRunNamesWithSignalLoggingResults(this,  dataset);
        runNames = getAllRunNamesUnderModel(this, modelName);
        results = getAllResultsFromRunUsingModelSource(this, modelName, runName);
        
        hasAction = hasExecutedAction(this, modelName, runName, action); 
        % embedded run name management 
        % NOTE: this functionality will be moved to an external layer, see
        % g1450668
        addEmbeddedRunName(this, modelName, embeddedRunName);
        clearEmbeddedRunName(this, modelName, embeddedRunName);
        
    end
end