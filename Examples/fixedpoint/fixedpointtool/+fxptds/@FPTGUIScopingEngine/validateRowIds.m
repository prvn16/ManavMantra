function isValid = validateRowIds(rowIds)
%% VALIDATEROWIDS function checks if inputs rowIds are valid
% rowIds is an array representing rowIds 
% isValid is logical indicating if rowIds are valid

%   Copyright 2016 The MathWorks, Inc.

    isValid = true;
    % Verify if rowIds must be a vector of row indices / numbers
    if isempty(rowIds) || ~isnumeric(rowIds)
        isValid = false;
    end
end