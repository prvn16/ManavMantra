function constraint = convertValueToConstraint(value)

% Copyright 2013 The MathWorks, Inc.

import matlab.unittest.constraints.IsEqualTo;

if isa(value, 'matlab.unittest.constraints.Constraint')
    validateattributes(value, {'matlab.unittest.constraints.Constraint'}, {'scalar'});
    constraint = value;
else
    constraint = IsEqualTo(value);
end
end