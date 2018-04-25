function value = convertInfToString(value)
% CONVERTINFTOSTRING Convertes inf and nan values to its string values.
    
% Copyright 2017 The MathWorks, Inc.
    
if isempty(value)
    value = '';
elseif ( isinf(value) || isnan(value))
    value = num2str(value);
end
end
