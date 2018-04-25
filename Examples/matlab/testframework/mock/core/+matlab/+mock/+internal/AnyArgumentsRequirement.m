classdef AnyArgumentsRequirement < matlab.mock.internal.Requirement
    % This class is undocumented and may change in a future release.
    
    % Copyright 2016 The MathWorks, Inc.
    
    properties (SetAccess=private)
        OneLineSummary string = getString(message('MATLAB:mock:display:AnyArgumentsSummary'));
    end
    
    methods
        function bool = satisfiedBySingleArgument(~, ~)
            bool = true;
        end
        
        function bool = satisfiedByZeroArguments(~)
            bool = true;
        end
        
        function requirement = getRequirementForNextArgument(requirement)
        end
    end
end

