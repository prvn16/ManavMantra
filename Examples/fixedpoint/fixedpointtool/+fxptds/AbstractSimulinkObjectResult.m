classdef AbstractSimulinkObjectResult < fxptds.AbstractSimulinkResult
    % ABSTRACTSIMULINKOBJECTRESULT Defines a common implementation for all data & datatype
    % objects in Simulink
    
    % Copyright 2013-2017 The MathWorks, Inc.
    
    methods
        function this = AbstractSimulinkObjectResult(data)
            this@fxptds.AbstractSimulinkResult(data);
        end
        
        function [cls,source] = getObjectClassAndSource(this)
            dataObjectWrapper = this.getUniqueIdentifier.getObject;
            cls = class(dataObjectWrapper.Object) ;
            source = SimulinkFixedPoint.AutoscalerVarSourceTypes.enum2string(dataObjectWrapper.WorkspaceType);
        end
        
        function parent = getHighestLevelParent(this)
            dataObjectWrapper = this.getUniqueIdentifier.getObject;
            parent = dataObjectWrapper.ContextName;
        end
        
        function inScopeFlag = isWithinProvidedScope(this, systemIdentifierObj)
            % If one or more source(s) of the result are found in systemIdentifierObj, the
            % inScopeFlag is set to true.

            % Initializing with default value
            inScopeFlag = false;
            % Get all sources for the result
            actualSources = this.ActualSourceIDs;            
            if ~isempty(actualSources)                
                for iSource = 1:numel(actualSources)
                    % Source of interest
                    currentSource = actualSources{iSource};                    
                    if currentSource.isValid
                        % Check if valid source is in scope of systemIdentifierObj
                        isInScope = currentSource.isWithinProvidedScope(systemIdentifierObj);
                        if isInScope
                            % If a single valid source is in scope it would imply that the
                            % result is in scope. Hence, setting inScopeFlag to true.
                            inScopeFlag = true;
                            break;
                        end
                    end
                end
            end
        end
                
        function subsystemId = getSubsystemId(~)
            subsystemId = {'DataObjects'};
        end
    end
        
    methods(Hidden)
        function computeIfInheritanceReplaceable(~)
            % Inheritance is irreplaceable by default. Exceptions are handled in child
            % classes.
            % NO-OP
        end
        
        function overflowMode = getOverflowMode(~)
            % No overflow mode setting for Simulink data type objects
            overflowMode = '';
        end
        
        function blockList = getClientBlocks(this)
            % Get all the identifiers of all clients of the result and obtain the
            % corresponding objects from the identifiers. blockList is the array of the
            % objects.
            actualSourceIDs = this.ActualSourceIDs;
            blockList = {};
            for iSource= 1:length(actualSourceIDs)
                blockList = [blockList {actualSourceIDs{iSource}.getObject}];  %#ok<AGROW>
            end
        end
    end
end
