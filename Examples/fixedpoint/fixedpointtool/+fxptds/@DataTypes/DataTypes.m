classdef DataTypes < uint8
    % DATATYPES The DataTypes enumeration lists all possible data types that are of
    % importance in the automatic data typing workflow. Currently we
    % identify specified data types, proposed data types and compiled data
    % types to be of importance for the workflow.
	
    %   Copyright 2016 The MathWorks, Inc.
    
    enumeration
        SpecifiedDataType   (1)
        ProposedDataType    (2)
        CompiledDataType    (3)
    end
    methods(Static)
        dataTypeString = getString(dataType);
    end
end