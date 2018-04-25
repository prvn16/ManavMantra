classdef ConstraintRequirement < matlab.mock.internal.Requirement
    % This class is undocumented and may change in a future release.
    
    % Copyright 2016 The MathWorks, Inc.
    
    properties (SetAccess=private)
        Constraint (1,1) matlab.unittest.constraints.Constraint = ...
            matlab.unittest.constraints.IsAnything;
    end
    
    properties (Dependent, SetAccess=private)
        OneLineSummary string;
    end
    
    methods
        function requirement = ConstraintRequirement(constraint)
            requirement.Constraint = constraint;
        end
        
        function bool = satisfiedBySingleArgument(requirement, argument)
            try
                bool = requirement.Constraint.satisfiedBy(argument);
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
            constraint = requirement.Constraint;
            
            if isa(constraint, 'matlab.unittest.constraints.AndConstraint')
                displayName = [getConstraintDisplay(constraint.FirstConstraint), ' & ', ...
                    getConstraintDisplay(constraint.SecondConstraint)];
            elseif isa(constraint, 'matlab.unittest.constraints.OrConstraint')
                displayName = [getConstraintDisplay(constraint.FirstConstraint), ' | ', ...
                    getConstraintDisplay(constraint.SecondConstraint)];
            else
                displayName = getConstraintDisplay(constraint);
            end
            
            summary = string(getString(message('MATLAB:mock:display:ConstraintSummary', displayName)));
        end
    end
end

function displayName = getConstraintDisplay(constraint)
import matlab.unittest.internal.getSimpleParentName;

prefix = '';
if isa(constraint, 'matlab.unittest.constraints.NotConstraint')
    constraint = constraint.Constraint;
    prefix = '~';
end

displayName = [prefix, getSimpleParentName(class(constraint))];
end

