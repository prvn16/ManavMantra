classdef(Hidden) DirectConditionsSupplier < matlab.unittest.internal.diagnostics.ConditionsSupplier
    % This class is undocumented and may change in a future release.
    
    % Copyright 2017 The MathWorks, Inc.
    properties(Access=private)
        Conditions (1,:) matlab.unittest.diagnostics.Diagnostic;
    end
    
    methods
        function supplier = DirectConditionsSupplier(conditions)
            import matlab.unittest.diagnostics.Diagnostic;
            supplier.Conditions = reshape(Diagnostic.join(conditions),1,[]);
        end
        
        function conditions = getConditions(supplier,~)
            conditions = supplier.Conditions;
        end
    end
end