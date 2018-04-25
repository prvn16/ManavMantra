classdef ConstraintsRegistrationInterface < fxptds.DataTypeGroupRegistrationInterface
    % CONSTRAINTSREGISTRATIONINTERFACE The class of ConstraintsRegistrationInterface is an interface between
    % the data type group class and the members of the group
    % (AbstractResult) tasked to register the constraints that belong in a
    % member to the group at the time of insertion of the member to the
    % group.
	
    %   Copyright 2016 The MathWorks, Inc.
    
    methods
        function register(this, dataTypeGroup, member)
            this.registerConstraints(dataTypeGroup, member);
        end
    end
    
    methods(Access=private)
        registerConstraints(this, dataTypeGroup, result)
    end
end