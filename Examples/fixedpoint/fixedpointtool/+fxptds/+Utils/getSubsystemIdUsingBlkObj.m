function subsystemIdentifier  = getSubsystemIdUsingBlkObj(blkObj, blkObjId)
%% GETSUBSYSTEMIDUSINGBLKOBJ function uses blkObj and its associated handle/id to construct a subsystem identifier
% This API is used by fxptui.ScopingHierarchyGenerator and
% fxptds.Result classes to query for a subsystem id given a block
% object
% It uses fxptds.SubsystemIdTracker object to query for the id if one
% exists

%   Copyright 2017 The MathWorks, Inc.

    scopingEngine = fxptds.FPTGUIScopingEngine.getInstance();
    subsystemIdentifier = scopingEngine.getSubsystemIdentifier(blkObjId); 
    
    % If id is empty, there does not exist a key in map
    if isempty(subsystemIdentifier)
        % Use blkObj to construct a uniqueIdentifier and store the
        % uniqueIdentifier entry in SubsystemIdTracker
        dh = fxptds.SimulinkDataArrayHandler;
        subsystemData.Object = blkObj; 
        subsystemIdentifier = dh.getUniqueIdentifier(subsystemData);
        
        % Add subsystem identifier to the map
        if ~isempty(subsystemIdentifier)
            scopingEngine.cacheSubsystemIdentifier(blkObjId, subsystemIdentifier);
        end
    end
end
