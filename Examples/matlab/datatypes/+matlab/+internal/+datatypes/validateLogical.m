function paramVal = validateLogical(paramVal,paramName)
%VALIDATELOGICAL Validate a scalar logical input.

%   Copyright 2012-2014 The MathWorks, Inc.

if isscalar(paramVal) && (islogical(paramVal) || isnumeric(paramVal))
    paramVal = logical(paramVal);
else
    error(message('MATLAB:table:InvalidLogicalVal', paramName));
end
