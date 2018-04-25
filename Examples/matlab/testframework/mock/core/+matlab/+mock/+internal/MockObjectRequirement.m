classdef MockObjectRequirement < matlab.mock.internal.Requirement
    % This class is undocumented and may change in a future release.
    
    % Copyright 2016-2017 The MathWorks, Inc.
    
    properties (SetAccess=immutable)
        Role;
    end
    
    properties (Dependent, SetAccess=private)
        OneLineSummary string;
    end
    
    methods
        function requirement = MockObjectRequirement(role)
            validateattributes(role, {'matlab.mock.internal.Role'}, {});
            requirement.Role = role;
        end
        
        function bool = satisfiedBySingleArgument(requirement, argument)
            argumentRole = builtin('matlab.mock.internal.getLabel', argument);
            if ~(builtin('metaclass', argumentRole) <= ?matlab.mock.internal.Role)
                bool = false;
                return;
            end
            bool = requirement.Role.describes(argumentRole);
        end
        
        function bool = satisfiedByZeroArguments(~)
            bool = false;
        end
        
        function requirement = getRequirementForNextArgument(requirement)
            requirement(1) = [];
        end
        
        function summary = get.OneLineSummary(requirement)
            summary = string(getString(message('MATLAB:mock:display:MockObjectSummary', ...
                requirement.Role.InteractionCatalog.MockObjectSimpleClassName)));
        end
    end
end

