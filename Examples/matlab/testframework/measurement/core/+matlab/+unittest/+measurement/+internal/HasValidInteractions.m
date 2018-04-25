classdef HasValidInteractions < matlab.unittest.constraints.Constraint
    % This class is undocumented and will change in a future release.
    
    % Copyright 2015-2017 The MathWorks, Inc.
    
    properties(Constant)
        Catalog = matlab.internal.Catalog('MATLAB:unittest:measurement:MeasurementPlugin');
    end
    properties
        TestName
    end
    
    methods
        function constraint = HasValidInteractions(name)
            constraint.TestName = name;
        end
        function tf = satisfiedBy(~, meter)
            tf = meter.hasValidInteractions;
        end
        function diag = getDiagnosticFor(constraint, meter)
            import matlab.unittest.diagnostics.StringDiagnostic;
            if meter.hasValidInteractions
                    diag = StringDiagnostic(constraint.Catalog.getString('ValidMeterInteraction', constraint.TestName));
            else
                diag = StringDiagnostic(constraint.Catalog.getString('InvalidMeterInteraction', constraint.TestName));
            end
        end
    end
end