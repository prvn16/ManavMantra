function children = getChildren(this)
% GETCHILDREN Gets the results for the node

% Copyright 2013-2014 The MathWorks, Inc.

    children = [];
    if ~this.isValid
        return;
    end
    % identify the results only when feature is on
    if this.isNodeSupported
        % find the results from the application data of instance use
        mdlAppData = SimulinkFixedPoint.getApplicationData(this.getHighestLevelParent);
        % identify the refdataset
        if (mdlAppData.subDatasetMap.Count ~= 0) && (mdlAppData.subDatasetMap.isKey(this.DAObject.handle))
            curRefDataset = mdlAppData.subDatasetMap(this.DAObject.handle);  
            results = curRefDataset.getResultsFromRuns;
        else
            % no results corresponds to this reference
            % early return
            results = [];
        end

        if(isempty(results)); return; end

        me = fxptui.getexplorer;
        if isempty(me); return; end

        me.updateResultsVisibility(results);
        hasMATLABResults = false;
        logicVec = false(1,numel(results));
        for i = 1:numel(results)
            child = results(i);
            if isa(child,'fxptds.MATLABVariableResult')
                wasCleared = this.clearMATLABResultIfNotValid(child);
                if wasCleared
                    continue;
                end
            end
            logicVec(i) = child.isVisible && ...
                child.isWithinProvidedScope(this.Identifier);
            if ~me.WasTreeUpdatedWithMLFunctions
                if isa(child, 'fxptds.MATLABVariableResult')
                    hasMATLABResults = true;
                    function_identifier = child.getUniqueIdentifier.MATLABFunctionIdentifier;
                    % Don't use SID directly since model renames, save-as can
                    % invalidate it.
                    ed.broadcastEvent('FunctionAddedEvent',...
                        fxptui.FPTTreeUpdateEventData(...
                        function_identifier,...
                        Simulink.ID.getFullName(function_identifier.BlockIdentifier.getObject)));
                    % Turn if off again to ensure all functions are added to the tree
                    % and not just the first one.
                    me.WasTreeUpdatedWithMLFunctions = false;
                end
            end
        end
        % Set the flag to true after processing the results - all function
        % nodes for which data has been collected should be added at this
        % point.
        if hasMATLABResults
            me.WasTreeUpdatedWithMLFunctions = true;
        end
        children = results(logicVec);
    end
end
        
