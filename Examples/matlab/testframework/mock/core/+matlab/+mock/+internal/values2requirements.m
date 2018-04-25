function requirements = values2requirements(values)
% This function is undocumented and may change in a future release.

% Copyright 2016 The MathWorks, Inc.

requirements = cellfun(@convertSingleValue, values, 'UniformOutput',false);
requirements = [matlab.mock.internal.Requirement.empty, requirements{:}];
end

function requirement = convertSingleValue(value)
import matlab.mock.internal.AnyArgumentsRequirement;
import matlab.mock.internal.ConstraintRequirement;
import matlab.mock.internal.MockObjectRequirement;
import matlab.mock.internal.LiteralValueRequirement;

label = builtin('matlab.mock.internal.getLabel', value);
if ~isempty(label) && isa(label, 'matlab.mock.internal.Role')
    requirement = MockObjectRequirement(label);
    return;
end

if builtin('metaclass', value) <= ?matlab.unittest.constraints.Constraint
    requirement = ConstraintRequirement(value);
    return;
end

if builtin('metaclass', value) == ?matlab.mock.AnyArguments
    requirement = AnyArgumentsRequirement;
    return;
end

requirement = LiteralValueRequirement(value);
end

