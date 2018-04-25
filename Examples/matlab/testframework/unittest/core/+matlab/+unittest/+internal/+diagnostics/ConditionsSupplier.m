classdef(Hidden,HandleCompatible) ConditionsSupplier
    % This class is undocumented and may change in a future release.
    
    % Copyright 2017 The MathWorks, Inc.
    methods(Hidden, Abstract)
        conditions = getConditions(supplier,diagnosticData)
    end
end