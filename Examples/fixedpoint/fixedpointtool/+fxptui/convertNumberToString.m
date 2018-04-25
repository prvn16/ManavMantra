function strValue = convertNumberToString(value)
% CONVERTNUMBERTOSTRING Convert the double precision number to a string representation.

% Copyright 2017 The MathWorks, Inc.

if isempty(value)
    strValue = '';
elseif ( isinf(value) || isnan(value))
    strValue = num2str(value);
else
    strValue = SimulinkFixedPoint.DataType.compactButAccurateNum2Str(value);
end
end
