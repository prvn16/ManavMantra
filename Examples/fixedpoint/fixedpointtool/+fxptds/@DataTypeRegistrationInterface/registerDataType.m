function registerDataType(this, dataTypeGroup, result)
    % REGISTERDATATYPE This function is processing the group member (AbstractResult) and
    % data types found in the member to the group it belongs to. The class
    % is selecting the kind of data type using the internal property of
    % dataTypeCategory that specifies the type of data type that is
    % required to be registered.
    % The function uses the public API of the DataTypeGroup class of
    % addDataType that assumes the responsibility of accessing the
    % internal infrastrucutre to finalize the consolidation of the incoming
    % data types.
	
    %   Copyright 2016 The MathWorks, Inc.
    
    dataTypeGroup.addDataType(result.(fxptds.DataTypes.getString(this.dataTypeCategory)));
end