function originalTable = getOriginalTable(this)
    % GETORIGINALTABLE retrieves the memory information of the original 
    % block, if available. 
    
    % Copyright 2017 The MathWorks, Inc.
    
    numInputs = this.Problem.NumberOfInputs;
    tableData = FunctionApproximation.internal.Utils.getLUTDataForFunctionToApproximate(this.Problem);
    if(isempty(tableData))
        originalTable = this.DataAdapter.getEmptyTable(numInputs);
        % g1682803 - Add empty strings if no data type info is available
        originalTable.StorageTypes = strings(numInputs + 1, 1);
    else
        originalTable = this.DataAdapter.getTable(tableData, this.Units);
        % g1682803 - The optimization report in the create pane should
        % provide data type information
        originalTable.StorageTypes = tableData.StorageTypes;
    end
end

