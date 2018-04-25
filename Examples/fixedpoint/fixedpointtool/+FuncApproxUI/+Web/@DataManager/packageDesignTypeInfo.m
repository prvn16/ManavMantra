function designTypeInfo = packageDesignTypeInfo(this)
    % PACKAGEDESIGNTYPEINFO packages the design type information of the
    % selected block to be sent to the client
    
    % Copyright 2017 The MathWorks, Inc.    
    
    originalTable = this.getOriginalTable();
    designTypeInfo.MemoryUsed = originalTable.Total;
    designTypeInfo.OutputType = this.Problem.OutputType.tostring;
    designTypeInfo.NumberOfInputs = this.Problem.NumberOfInputs;
    for r = 1: designTypeInfo.NumberOfInputs
        designTypeInfo.DataTypes{r} = struct('InputTypes', tostring(this.Problem.InputTypes(r)),...
            'InputLowerBounds', fixed.internal.compactButAccurateNum2Str(this.Problem.InputLowerBounds(r)),...
            'InputUpperBounds', fixed.internal.compactButAccurateNum2Str(this.Problem.InputUpperBounds(r)));
    end
end

