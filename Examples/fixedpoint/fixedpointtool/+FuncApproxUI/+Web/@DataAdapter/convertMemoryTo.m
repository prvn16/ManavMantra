function output = convertMemoryTo(~, input, unit)
    % CONVERTMEMORYTO converts value in bits to
    % given unit - bytes, KiB, MiB and so on
    
    % Copyright 2017 The MathWorks, Inc.
    
    outputObj = FunctionApproximation.internal.MemoryValue(input, 'Unit', 'bits');
    outputObj.Unit = unit;
    output = outputObj.Value;
end
