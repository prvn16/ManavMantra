classdef DidNotDetectClassBoundaryMeasurement < matlab.unittest.constraints.Constraint
    % This class is undocumented and will change in a future release.
    
    % Copyright 2015 The MathWorks, Inc.
    
    properties(Constant)
        Catalog = matlab.internal.Catalog('MATLAB:unittest:measurement:MeasurementPlugin');
    end
    properties
        ClassName
    end
    
    methods
        function constraint = DidNotDetectClassBoundaryMeasurement(name)
            constraint.ClassName = name;
        end
        function tf = satisfiedBy(~, plugin)
            tf = ~plugin.MeasuresAtClassBoundary;
        end
        function diag = getDiagnosticFor(constraint, plugin)
            import matlab.unittest.diagnostics.StringDiagnostic;
            if plugin.MeasuresAtClassBoundary
                diag = StringDiagnostic(constraint.Catalog.getString('InvalidFixtureMeasurement', ...
                    constraint.ClassName, 'TestClassSetup', 'TestClassTeardown'));
            else
                diag = StringDiagnostic(constraint.Catalog.getString('ValidFixtureMeasurement', ...
                    constraint.ClassName, 'TestClassSetup', 'TestClassTeardown'));
            end
        end
    end
end