function isValidUpdate = updateRows(this, rowIds, columnName, values)
%% UPDATEROWS function updates ScopingTable's specific column indicated by 
% columnName with one value indicated by value for given rowIds
%
% rowIds is an array of integers indicating row numbers / indices
% columnName is a char array indicating column header of the table
% value is a cell of values to be updated for the given rowIds

%   Copyright 2016 The MathWorks, Inc.

    % validate inputs for update rows function
    isValidUpdate = this.validateInputsForUpdateRows(rowIds, columnName, values);
    
    % if all inputs are valid, index on the column, update values
    if (isValidUpdate)
        this.ScopingTable.(columnName)(rowIds) = values;
    end
end