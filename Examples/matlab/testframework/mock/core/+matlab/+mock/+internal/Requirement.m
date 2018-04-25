classdef Requirement < matlab.mixin.Heterogeneous
    % This class is undocumented and may change in a future release.
    
    % Copyright 2016 The MathWorks, Inc.
    
    properties (Abstract, SetAccess=private)
        OneLineSummary string;
    end
    
    methods (Abstract)
        bool = satisfiedBySingleArgument(requirement, arguments);
        bool = satisfiedByZeroArguments(requirement);
        nextRequirement = getRequirementForNextArgument(requirement);
    end
    
    methods (Sealed)
        function bool = satisfiedByAllArguments(requirements, arguments)
            
            if isempty(requirements)
                bool = isempty(arguments);
                return;
            end
            
            thisRequirement = requirements(1);
            
            if isempty(arguments)
                bool = all(arrayfun(@satisfiedByZeroArguments, requirements));
                return;
            end
            
            if ~thisRequirement.satisfiedBySingleArgument(arguments{1})
                bool = false;
                return;
            end
            
            remainingRequirements = [thisRequirement.getRequirementForNextArgument, requirements(2:end)];
            remainingArguments = arguments(2:end);
            bool = remainingRequirements.satisfiedByAllArguments(remainingArguments);
        end
    end
end

