function specifiedContainerInfo = getSpecifiedDataType(this, proposalSettings)
    % SPECIFIEDCONTAINERINFO This function provides a public API to query for the consolidated
    % specified data type of the group.
    % NOTE: this functionality has absorbed all the complexity that was
    % previously a hard coded logic in the Autoscaler core and the
    % AutoscalerMetaData. Hence the method started lacking in extensibility
    % and readability. We need to refactor this method and provide similar
    % functionality whilst honoring OCP and SRP, see: g1456874
	
    %   Copyright 2016 The MathWorks, Inc.
    
    fixedIndex = arrayfun(@(x)(x.isFixed), this.initialSpecifiedDataTypes);
    if any(fixedIndex)
        specifiedDataType = SimulinkFixedPoint.AutoscalerUtils.unionizeFixedPointTypes(this.initialSpecifiedDataTypes(fixedIndex));
        
    else
        % identify if any of the registered specified data types is
        % floating point
        isAnyFloatingPoint = any(arrayfun(@(x)(x.isFloat), this.initialSpecifiedDataTypes));
        
        % identify if any of the registered specified data types is of
        % inherited type
        isAnyInherited = any(arrayfun(@(x)(x.isInherited), this.initialSpecifiedDataTypes));
        
        % identify if any of the registered specified data types is
        % irreplaceable by the fixed point tool; we define a data type to
        % be irreplaceable if they are one of the following: enum, bus,
        % alias or boolean
        isIrreplaceableIndex = arrayfun(@(x)(x.isIrreplaceableByFixedPointDT), this.initialSpecifiedDataTypes);
        
        % initialize the data type that will be returned with empty
        specifiedDataType = Simulink.NumericType.empty;
        
        if any(isIrreplaceableIndex)
            % if exactly one of the members has an irreplaceable data type we
            % leverage the data type to the group
            if sum(isIrreplaceableIndex) == 1
                specifiedContainerInfo = this.initialSpecifiedDataTypes(isIrreplaceableIndex);
                return;
            end
        elseif (isAnyFloatingPoint || isAnyInherited)
            % if any of the registered specified data types are floating point
            % or inherited data types we provide the default data type based on
            % the proposal settings
            specifiedDataType = SimulinkFixedPoint.AutoscalerUtils.getDefaultNumericTypeObject(proposalSettings);
        end
    end
    
    % get a string of the consolidated data type to initialize a container
    % info object
    dataTypeStr = '';
    if ~isempty(specifiedDataType)
        dataTypeStr = tostring(specifiedDataType);
    end
    
    % initialize a container info object
    specifiedContainerInfo = SimulinkFixedPoint.DTContainerInfo(dataTypeStr, []);
    
end