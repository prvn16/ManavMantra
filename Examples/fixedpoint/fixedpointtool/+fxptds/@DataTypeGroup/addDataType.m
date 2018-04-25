function addDataType(this, dataTypeContainer)
    % ADDDATATYPE This function provides a public API to register specified data types
    % of the members. At the time of registration, the data types of all
    % the members will not be consolidated since this would require
    % additional information about the proposal settings used in the
    % workflow. We keep a full set of information about the data types and
    % at a later call, when asked about the specified data type of the
    % group, we consolidate all the registered specified data types.
	
    %   Copyright 2016 The MathWorks, Inc.
    
    % add the new data type container to the collection of all data type
    % containers for all group members
    this.initialSpecifiedDataTypes = [this.initialSpecifiedDataTypes ; dataTypeContainer];
end