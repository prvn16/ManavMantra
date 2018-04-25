function updateRunName(this, runName)
% UPDATERUNNAME Update the runname with the new name.
    
%  Copyright 2012-2017 The MathWorks, Inc.
    
	% Notify FPTGUIScopingEngine of the change before changing the run name
    % g1497576 
    scopingIdsMap = this.RunEventHandler.notifyRunNameChange(this.RunName, runName, this.Source);
    this.RunName  = runName;
    
    % ScopingIdsMap is not empty iff FPTWeb is ON as the scoping id
    % infrastructure is put together for new GUI.
    if ~isempty(scopingIdsMap)
        % Update each result with the new scopingId
        allResults = this.getResultsAsCellArray;
        for idx=1:numel(allResults)
            result = allResults{idx};
            oldScopingId = result.getScopingId;

            newScopingId = scopingIdsMap(oldScopingId{1});
            result.addScopingId({newScopingId});
        end
    end
end

