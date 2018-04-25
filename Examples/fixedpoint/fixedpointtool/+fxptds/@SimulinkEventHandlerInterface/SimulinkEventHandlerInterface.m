classdef SimulinkEventHandlerInterface < handle
%% SIMULINKEVENTHANDLERINTERFACE class handles events from Simulink model that Fixed Point Tool should react to.

%   Copyright 2016-2017 The MathWorks, Inc.

    properties(SetAccess=private)
        ModelListeners = {};
        
        % Used only for testing purposes
        LastDatasetAccessed;
    end
    methods
        registerDataset(this, datasetObject);
        notifySimulationStart(this, model);
    end
    
end
