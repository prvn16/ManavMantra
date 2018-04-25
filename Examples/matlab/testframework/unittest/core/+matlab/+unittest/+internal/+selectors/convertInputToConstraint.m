function constraint = convertInputToConstraint(input,propertyName)

% Copyright 2013-2016 The MathWorks, Inc.

validateattributes(input, {'char', 'matlab.unittest.constraints.Constraint','string'}, {'nonempty','row'});

if isstring(input)
    matlab.unittest.internal.validateNonemptyText(input,propertyName);
    input=char(input);
end


constraint = matlab.unittest.internal.selectors.convertValueToConstraint(input);