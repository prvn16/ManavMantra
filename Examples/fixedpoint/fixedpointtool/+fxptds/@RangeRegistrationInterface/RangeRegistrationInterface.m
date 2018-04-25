classdef RangeRegistrationInterface < fxptds.DataTypeGroupRegistrationInterface
    % RANGEREGISTRATIONINTERFACE The class of RangeRegistrationInterface is an interface between
    % the data type group class and the members of the group
    % (AbstractResult) taked to register the ranges that belong in a
    % member to the group at the time of insertion of the member to the
    % group.
	
    %   Copyright 2016 The MathWorks, Inc.
    methods
        function register(this, dataTypeGroup, member)
            this.registerRanges(dataTypeGroup, member);
        end
    end
    
    methods(Access=private)
        registerRanges(this, dataTypeGroup, result)
    end
end