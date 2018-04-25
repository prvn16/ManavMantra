classdef DidNotDetectFreshFixtureMeasurement < matlab.unittest.constraints.Constraint
    % This class is undocumented and will change in a future release.
    
    % Copyright 2015 The MathWorks, Inc.
    
    properties(Constant)
        Catalog = matlab.internal.Catalog('MATLAB:unittest:measurement:MeasurementPlugin');
    end
    properties
        TestName
    end
    
    methods
        function constraint = DidNotDetectFreshFixtureMeasurement(name)
            constraint.TestName = name;
        end
        function tf = satisfiedBy(~, plugin)
            tf = ~plugin.MeasuresInFreshFixture;
        end
        function diag = getDiagnosticFor(constraint, plugin)
            import matlab.unittest.diagnostics.StringDiagnostic;
            if plugin.MeasuresInFreshFixture
                diag = StringDiagnostic(constraint.Catalog.getString('InvalidFixtureMeasurement', ...
                    constraint.TestName, 'TestMethodSetup', 'TestMethodTeardown'));
            else
                diag = StringDiagnostic(constraint.Catalog.getString('ValidFixtureMeasurement', ...
                    constraint.TestName, 'TestMethodSetup', 'TestMethodTeardown'));
            end
        end
    end
end