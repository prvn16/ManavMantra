function isValidUpdate = validateInputsForUpdateRows(this, rowIds, columnName, values)    
%% VALIDATEINPUTFORUPDATEROWS function inputs rowIds, columnName and values which need to be updated in to this.ScopingTable.(columnName)(RowIds)
% and verifies if inputs are of the right type
% 
% Input requirements for successful validation are:
% rowIds must be a vector of row indices / numbers
% values must be a cell array of values (column major)
% number of rows must match the vector of values input
% columnName must be a valid string in ScopingTable's VariableNames

%   Copyright 2016 The MathWorks, Inc.

    isValidUpdate = true;
    
    % Verify if rowIds must be a vector of row indices / numbers
    isValidRowIds = fxptds.FPTGUIScopingEngine.validateRowIds(rowIds);
    if ~isValidRowIds
        isValidUpdate = false;
        return;
    end
    
    % Verify if rowIds must be a vector of row indices / numbers
    isValidColumnValues = fxptds.FPTGUIScopingEngine.validateColumnValues(values);
    if ~isValidColumnValues
        isValidUpdate = false;
        return;
    end
    
    % Verify if number of rowIds match the number of values input for
    % update
    if numel(rowIds) ~= numel(values)
        isValidUpdate = false;
        return;
    end
    
    % Verify that columnName must be a valid string in ScopingTable's VariableNames
    matchingIndices = cellfun(@(x) strcmpi(x, columnName), this.ScopingTable.Properties.VariableNames);
    isValidColumn = matchingIndices(matchingIndices == 1);
    if isempty(isValidColumn) || ~isValidColumn
        isValidUpdate = false;
    end
end
