function children = getChildren(this)
% GETCHILDREN Gets the objects to be displayed for this node in the list view

% Copyright 2013-2014 The MathWorks, Inc.

    children = [];

    me = fxptui.getexplorer;
    if(~this.isValid) || isempty(me); return; end

    results = this.getRootResults;
    if(isempty(results)); return; end

    me.updateResultsVisibility(results);
    
    logicVec = false(1,numel(results));
    ed = fxptui.FPTEventDispatcher.getInstance;
    
    for i = 1:numel(results)
        child = results(i);
        if isa(child,'fxptds.MATLABExpressionResult')
            wasCleared = this.clearMATLABResultIfNotValid(child);
            if wasCleared
                continue;
            end
        end
        logicVec(i) = child.isVisible && ...
               child.isWithinProvidedScope(this.Identifier);
        if ~me.WasTreeUpdatedWithMLFunctions
            if isa(child, 'fxptds.MATLABExpressionResult')
                function_identifier = child.getUniqueIdentifier.MATLABFunctionIdentifier;
                % Don't use SID directly since model renames, save-as can
                % invalidate it.            
                blockID = function_identifier.BlockIdentifier;
                if blockID.isValid 
                    ed.broadcastEvent('FunctionAddedEvent',...
                                      fxptui.FPTTreeUpdateEventData(...
                                          function_identifier,...
                                          blockID.getObject.getFullName)); 
                    % Turn if off again to ensure all functions are added to the tree
                    % and not just the first one.
                    me.WasTreeUpdatedWithMLFunctions = false;
                end
            end
        end
    end
    % Set the flag to true after processing the results - all function
    % nodes for which data has been collected should be added at this
    % point.
    me.WasTreeUpdatedWithMLFunctions = true;
    children = results(logicVec);
end


% LocalWords:  fxptds
