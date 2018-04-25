function initializeRegistrationInterface(this)
    % INITIALIZEREGISTRATIONINTERFACE This function initializes the common gateway registration interface
    % for the data type group. This is the place where we add or remove
    % different interfaces in order to extract information about the group.
    % The class of data type group remains agnostic of the registered
    % interfaces and simply uses the gateway to query a newly added member.
	
    %   Copyright 2016-2017 The MathWorks, Inc.
    
    this.registrationInterface = {...
        fxptds.RangeRegistrationInterface(), ... % register the ranges of a newly added member
        fxptds.ConstraintsRegistrationInterface(), ... % register the constraints of a newly added member
        fxptds.DataTypeRegistrationInterface(fxptds.DataTypes.SpecifiedDataType)}; % register the specified data types of a newly added member
end