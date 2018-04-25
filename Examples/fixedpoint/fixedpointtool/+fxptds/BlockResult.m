classdef BlockResult < fxptds.AbstractSimulinkResult
    % BLOCKRESULT Definition for results from Simulink blocks.
    
    % Copyright 2012-2017 The MathWorks, Inc.
    
    methods
        function this = BlockResult(data)
            % Class should be able to instantiate with no input arguments
            if nargin == 0
                argList = {};
            else
                argList{1} = data;
            end
            this@fxptds.AbstractSimulinkResult(argList{:});
        end
        
        
        function icon = getDisplayIcon(this)
            icon = '';
            % Using the overloaded UDD find and not the built in method.
            if ~this.isResultValid; return; end
            if ~this.isPlottable
                icon = fullfile('toolbox','fixedpoint','fixedpointtool','resources',['BlockIcon' this.Alert '.png']);
            else
                icon = fullfile('toolbox','fixedpoint','fixedpointtool','resources',['BlockLoggedIcon' this.Alert '.png']);
            end
        end
        
        function setDerivedRangeState(this)
            this.DerivedRangeState = fxptds.DerivedRangeStates.Default;
            hasinsufficientrange = this.hasInsufficientRange && this.hasDerivedMinMax;
            if hasinsufficientrange
                % If there is insuffifient range, check if any design range on the
                % block is empty or if it is an inport block as a
                % possible source of empty ranges. The user facing message can be
                % more granular based on the source of this insufficient range.
                if this.isAnyDesignRangeEmpty && isa(this.getUniqueIdentifier.getObject, 'Simulink.Inport')
                    %  possible source of empty range signals
                    %  fxptds.Utils -- add containsMessage function to
                    %  do the same thing
                    this.DerivedRangeState = fxptds.DerivedRangeStates.InsufficientRangeInterface;
                else
                    this.DerivedRangeState  = fxptds.DerivedRangeStates.InsufficientRange;
                end
            else % does has sufficient range but check for empty intersection
                % check to see intersection
                if this.hasConflictingDesignAndDerivedRangeIntersection
                    this.DerivedRangeState  = fxptds.DerivedRangeStates.EmptyIntersection;
                end
            end
            this.setCommentsForDerivedRanges;
        end
        
    end
    methods(Hidden)
        function computeIfInheritanceReplaceable(this)
            % computeIfInheritanceReplaceable API verifies if a result is a
            % candidate for fixed point proposal on having an inheritance
            % rule as specified type.
            % For Simulink Blocks, all results at the outport of a block
            % have this value computed to true.
            % For any other result, this API set isInheritanceReplaceable
            % property to false.
            
            this.IsInheritanceReplaceable = false;
            owner = this.UniqueIdentifier.getObject;
            autoscaler = this.getAutoscaler;
            
            % returns output port associated with the result
            port = this.getPortForResult;
            
            % fix for g1183610 - where the test fails when port is empty
            % and proposal happens in the downstream.
            if ~isempty(port)
                % gets the pathitem of the outport
                pathItem = autoscaler.getPortMapping(owner, [], port.PortNumber);
                if ~isempty(pathItem)
                    if iscell(pathItem); pathItem = pathItem{:}; end
                    
                    % checks if the result's pathitem is same as the outport path
                    % item indicating if the result if outport result or not.
                    if(isequal(this.getElementName, pathItem))
                        % Check if the port is a bus.
                        % For bus signals, inherited data type cannot be
                        % replaced with a fixed point data type.
                        ph = get_param(owner.Handle,'PortHandles');
                        if ~(get_param(ph.Outport(port.PortNumber),'CompiledPortBusMode') == 1)
                            this.IsInheritanceReplaceable = true;
                        end
                    end
                end
            end
            
            if ~this.IsInheritanceReplaceable ...
                    && ( ...
                    isa(owner, 'Simulink.Lookup_nD') ...
                    || isa(owner, 'Simulink.PreLookup') ...
                    || isa(owner, 'Simulink.Interpolation_nD') ...
                    || isa(owner, 'Simulink.LookupNDDirect') ...
                    )
                
                % Additional checks for the inheritance types in lookup blocks
                % There is a potential to extend this to all value based inheritance that
                % is not at the output path item
                specifiedDataTypeContainer = this.getSpecifiedDTContainerInfo;
                if isInherited(specifiedDataTypeContainer)
                    inheritanceType = getInheritanceType(specifiedDataTypeContainer);
                    if inheritanceType == SimulinkFixedPoint.AutoscalerInheritanceTypes.INHERITFROMTABLEDATA ...
                            || inheritanceType == SimulinkFixedPoint.AutoscalerInheritanceTypes.INHERITFROMBREAKPOINTDATA
                        this.IsInheritanceReplaceable = true;
                    end
                end
            end
        end
    end
    
end

