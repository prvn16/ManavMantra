classdef DataTypeRegistrationInterface < fxptds.DataTypeGroupRegistrationInterface
    % DATATYPEREGISTRATIONINTERFACE The class of DataTypeRegistrationInterface is an interface between
    % the data type group class and the members of the group
    % (AbstractResult) taked to register the data types that belong in a
    % member to the group at the time of insertion of the member to the
    % group.
	
    %   Copyright 2016 The MathWorks, Inc.
    properties(Access=private)
        dataTypeCategory fxptds.DataTypes = fxptds.DataTypes.empty()
    end
    methods
        function this = DataTypeRegistrationInterface(dataTypeCategory)
            this.dataTypeCategory = dataTypeCategory;
        end
        function register(this, dataTypeGroup, member)
            this.registerDataType(dataTypeGroup, member);
        end
    end
    
    methods(Access=private)
        registerDataType(this, dataTypeGroup, result)
    end
end