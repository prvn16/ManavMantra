function dataTypeStr = getString(dataType)
    % GETSTRING This function resolves the enumerated type to the proper string
    % representation that can be used to query the data set elements
    % (AbstractResult) for the data types
    % NOTE: there is an inconsistency in the APIs that are provided by the
    % AbstractResult classes in terms of the specified data types. There is
    % an active plan to resolve the inconsistency, see g1445389
	
    %   Copyright 2016 The MathWorks, Inc.
    
    switch(dataType)
        case fxptds.DataTypes.SpecifiedDataType
            dataTypeStr = 'getSpecifiedDTContainerInfo';
        case fxptds.DataTypes.ProposedDataType
            dataTypeStr = 'ProposedDT';
        case fxptds.DataTypes.CompiledDataType
            dataTypeStr = 'CompiledDT';
        otherwise
            DAStudio.error('SimulinkFixedPoint:autoscaling:invalidDataTypeSpecification');
    end
    
end