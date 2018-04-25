function data = getOriginalMemData(this)
    % GETORIGINALMEMDATA returns the memory information for the
    % selected block, if available
    
    % Copyright 2017 The MathWorks, Inc. 
    
    % Get the design type and memory information from the CLI        
    originalTable = this.getOriginalTable();
    this.LUTInfo.TotalMemory.OrigMem = originalTable.Total;
    this.LUTInfo.TableData.OrigMem = originalTable.TableData;
    % g1682803 - Add original data type info for table data
    this.LUTInfo.TableData.OrigDT = originalTable.StorageTypes(this.LUTInfo.NumberOfInputs + 1);
    % g1682803 - Convert to string only if data type is not an empty string
    if (this.LUTInfo.TableData.OrigDT ~= "")
        this.LUTInfo.TableData.OrigDT = this.LUTInfo.TableData.OrigDT.tostring();
    end
    for index = 1:this.LUTInfo.NumberOfInputs
        this.LUTInfo.BreakpointDimensions{index}.OrigMem = originalTable.BreakpointDimensions{index};
        % g1682803 - Add original data type info for breakpoint data
        this.LUTInfo.BreakpointDimensions{index}.OrigDT = originalTable.StorageTypes(index);
        % g1682803 - Convert to string only if data type is not an empty string
        if (this.LUTInfo.BreakpointDimensions{index}.OrigDT ~= "")
            this.LUTInfo.BreakpointDimensions{index}.OrigDT = this.LUTInfo.BreakpointDimensions{index}.OrigDT.tostring();
        end
    end
    data = this.LUTInfo;
end

