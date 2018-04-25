function createOptimizationTable(this)
    % CREATEOPTIMIZATIONTABLE creates an empty struct for the memory table
    % information to be sent to the client
    
    % Copyright 2017 The MathWorks, Inc.
    
    % g1678597 - MFB workflow Memory Usage table unexpectedly shows 
    % some memory usage from the previous run if # of BPs in the 
    % previous one is greater than the current run
    this.LUTInfo = {};
    this.LUTInfo.NumberOfInputs = this.Problem.NumberOfInputs;
    
    % g1682803 - The optimization report in the create pane should
    % provide data type information
    emptyOptimReportRowStruct = struct('OrigMem', '' , 'OrigDT', '', 'OptimMem', '', 'OptimDT', '');
    this.LUTInfo.TotalMemory = emptyOptimReportRowStruct;
    this.LUTInfo.TableData = emptyOptimReportRowStruct;
    for index = 1:this.LUTInfo.NumberOfInputs
        this.LUTInfo.BreakpointDimensions{index} = emptyOptimReportRowStruct;
    end
end

