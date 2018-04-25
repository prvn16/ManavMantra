function data = getOptimizedMemData(this)
    % GETOPTIMIZEDMEMDATA populates the memory information of the
    % optimized block
    
    % Copyright 2017 The MathWorks, Inc.
      
    optimizedTable = this.getOptimizedTable();
    this.LUTInfo.TotalMemory.OptimMem = optimizedTable.Total;
    this.LUTInfo.TableData.OptimMem = optimizedTable.TableData;
    % g1682803 - Add optimized data type info for table data
    this.LUTInfo.TableData.OptimDT = optimizedTable.StorageTypes(this.Problem.NumberOfInputs + 1).tostring();
    for index = 1:this.Problem.NumberOfInputs
        this.LUTInfo.BreakpointDimensions{index}.OptimMem = optimizedTable.BreakpointDimensions{index};
        % g1682803 - Add optimized data type info for breakpoint data
        this.LUTInfo.BreakpointDimensions{index}.OptimDT = optimizedTable.StorageTypes(index).tostring();
    end    
    this.LUTInfo.MemoryReduced = round(this.Solution.percentreduction, 2);
    data = this.LUTInfo;    
end

