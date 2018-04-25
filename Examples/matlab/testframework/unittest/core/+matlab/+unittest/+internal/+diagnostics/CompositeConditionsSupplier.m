classdef(Hidden) CompositeConditionsSupplier < matlab.unittest.internal.diagnostics.ConditionsSupplier
    % This class is undocumented and may change in a future release.
    
    % Copyright 2017 The MathWorks, Inc.
    properties(Access=private)
        ComposedSuppliers (1,:) cell;
    end
    
    methods
        function conditions = getConditions(composite,diagData)
            import matlab.unittest.diagnostics.Diagnostic;
            cellArrayOfConditions = cellfun(@(supplier) supplier.getConditions(diagData),...
                composite.ComposedSuppliers,'UniformOutput',false);
            conditions = [Diagnostic.empty(1,0),cellArrayOfConditions{:}];
        end
        
        function composite = append(composite,supplier)
            assert(isa(supplier,'matlab.unittest.internal.diagnostics.ConditionsSupplier') & ...
                isscalar(supplier)); % sanity check
            
            composite.ComposedSuppliers = [composite.ComposedSuppliers,...
                {supplier}];
        end
    end
end