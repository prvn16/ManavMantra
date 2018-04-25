function isValid = validateColumnValues(columnValues)
%% VALIDATECOLUMNVALUES function checks if input column values are valid
% columnValues is a cell array of values to be assigned to a row
% isValid is logical value indicating if columnValues are valid 

%   Copyright 2016 The MathWorks, Inc.

    isValid = true;
    % Verify that values must be a cell array of values (column major)
    if ~iscell(columnValues) || size(columnValues, 2) ~= 1 
        isValid = false;
    end
end