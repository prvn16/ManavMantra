classdef ResultHandlerFactory < handle
%% RESULTHANDLER classes handles functionalities of results which can affect result's fellow group members 
% Class contains three properties
% ProposalSettings - Reflects on the current proposal settings in FPT GUI
% Datasets - Reflects on all datasets relevant to the top model on which FPT GUI is open 
% Methods on the class include:
% setAcceptForGroup - setting accept on a group of results
% setProposedDTForGroup - setting proposed data type on a group of results
% setProposedDT - setting accept on an individual result
% updateContext - set the context of setting accept / proposed data type

%   Copyright 2016-2017 The MathWorks, Inc.

    properties(SetAccess = private)
		ProposalSettings
        AllDatasets
    end
    
    properties(GetAccess = protected)
        ResultGroupHandler = fxptds.ResultGroupHandler;
    end
    
    methods(Abstract)
        setAccept(this, result, value);
    end
    
    methods
        function setProposalSettings(this, value)
            this.ProposalSettings = value;
        end
        function setAllDatasets(this, value)
            this.AllDatasets = value;
        end
        setAcceptForGroup(this, result, value);        
        setProposedDTForGroup(this, eventSrc, eventData);
        setProposedDT(this, eventSrc, eventData, updateModelBlocksAndAlerts);
        updateContext(this, appData, allDatasets);
    end
end
