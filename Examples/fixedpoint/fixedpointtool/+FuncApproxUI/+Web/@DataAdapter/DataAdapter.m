classdef DataAdapter
    % DATAADAPTER acts as an adapter for the data conversion between the
    % WizardController and the Function Approximation CLI
    
    % Copyright 2017 The MathWorks, Inc.
    
    methods
        function this = DataAdapter()
        end
    end
    
    methods(Hidden)
        output = convertMemoryTo(this, memory, unit);
        tableDataStruct = getTable(this, data, unit);
        tableDataStruct = getEmptyTable(this, numDimensions);
        tableDataStruct = getTableMetadata(this);
    end
end

