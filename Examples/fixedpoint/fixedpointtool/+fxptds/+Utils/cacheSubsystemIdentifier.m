function cacheSubsystemIdentifier(functionIdentifier)
%% CACHESUBSYSTEMIDENTIFIER     function caches away the function identifier for each MATLABVariableResult

%   Copyright 2017 The MathWorks, Inc.

    scopingEngine = fxptds.FPTGUIScopingEngine.getInstance();
    subsystemIdentifier = scopingEngine.getSubsystemIdentifier(functionIdentifier.UniqueKey); 
    
    % If id is empty, there does not exist a key in map
    if isempty(subsystemIdentifier)
        scopingEngine.cacheSubsystemIdentifier(functionIdentifier.UniqueKey, functionIdentifier);
    end
end