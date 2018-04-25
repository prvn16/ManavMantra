classdef LiteralValueRequirement < matlab.mock.internal.Requirement
    % This class is undocumented and may change in a future release.
    
    % Copyright 2016 The MathWorks, Inc.
    
    properties (Constant, Access=private)
        Comparator = defineComparator;
    end
    
    properties (SetAccess=immutable)
        Value;
    end
    
    properties (Dependent, Access=private)
        ValueConstraint matlab.unittest.constraints.Constraint;
    end
    
    properties (Dependent, SetAccess=private)
        OneLineSummary string;
    end
    
    methods
        function requirement = LiteralValueRequirement(value)
            requirement.Value = value;
        end
        
        function bool = satisfiedBySingleArgument(requirement, argument)
            constraint = requirement.ValueConstraint;
            try
                bool = constraint.satisfiedBy(argument);
            catch
                bool = false;
            end
        end
        
        function bool = satisfiedByZeroArguments(~)
            bool = false;
        end
        
        function requirement = getRequirementForNextArgument(requirement)
            requirement(1) = [];
        end
        
        function summary = get.OneLineSummary(requirement)
            import matlab.mock.internal.getOneLineSummary;
            summary = getOneLineSummary(requirement.Value);
        end
        
        function constraint = get.ValueConstraint(requirement)
            import matlab.unittest.constraints.IsEqualTo;
            constraint = IsEqualTo(requirement.Value, 'Using',requirement.Comparator);
        end
    end
end

function comp = defineComparator
import matlab.unittest.constraints.IsEqualTo;
import matlab.mock.internal.StrictObjectComparator;

% Use IsEqualTo's list of comparators, but make object comparison strict
comp = IsEqualTo.DefaultComparator;
mask = arrayfun(@(c)class(c) == "matlab.unittest.constraints.ObjectComparator", comp);
comp(mask) = StrictObjectComparator;
end

% LocalWords:  mcls
