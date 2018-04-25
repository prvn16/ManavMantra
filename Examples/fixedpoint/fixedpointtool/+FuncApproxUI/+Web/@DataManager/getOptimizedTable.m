function optimizedTable = getOptimizedTable(this)
    % GETOPTIMIZEDTABLE returns the memory information of the optimized  
    % LUT block    
    
    % Copyright 2017 The MathWorks, Inc.   
    
    tableData = FunctionApproximation.internal.Utils.getLUTDataForApproximateFunction(this.Solution);
    optimizedTable = this.DataAdapter.getTable(tableData, this.Units);
    % g1682803 - The optimization report in the create pane should
    % provide data type information
    optimizedTable.StorageTypes = tableData.StorageTypes;
end

