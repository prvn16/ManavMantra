classdef ResultGroupHandler < handle
    % ResultGroupHandler Singleton class that handles events
    % for all results in a group
    
    %   Copyright 2016-2017 The MathWorks, Inc.
    
    % Events handled by ResultGroupHandler
    events
        SetAcceptForGroup
    end
    
    properties(SetAccess = private)
        ProposalSettings
        AllDatasets
    end
    
    methods
        
        % update accept property of an individual result
        updateAcceptFlag(this, group, value);
        
        % set accept property for a group of results
        setAcceptForGroup(this, group, value);
        
        % set accept property for all thr groups involved starting with a
        % group which could have MATLABFunctionBlock results
        setAcceptForGroups(this, runObject, currentGroup, value);
        
        % set Accept property on a give result 
        setAccept(this, result, value);
        
        % collectgrouspForBatchAccept discovers all the result groups
        % involved while check/uncheck all operation is done on a result
        allDiscoveredGroups = collectGroupsForBatchAccept(this, runObject, group);
        
        % set proposed DT property for a group of results
        setProposedDTForGroup(this, group, value);
    end
    
    methods
        function setProposalSettings(this, value)
            this.ProposalSettings = value;
        end
        function setAllDatasets(this, value)
            this.AllDatasets = value;
        end
    end

end

