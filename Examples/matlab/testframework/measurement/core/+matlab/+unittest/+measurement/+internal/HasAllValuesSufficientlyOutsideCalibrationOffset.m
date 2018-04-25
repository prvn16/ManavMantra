classdef HasAllValuesSufficientlyOutsideCalibrationOffset < matlab.unittest.constraints.Constraint
    % This class is undocumented and will change in a future release.
    
    % Copyright 2017 The MathWorks, Inc.
    
    properties(Constant)
        Catalog = matlab.internal.Catalog('MATLAB:unittest:measurement:MeasurementPlugin');
    end
    
    methods
        function tf = satisfiedBy(~, result)
            tf = all(measurementsSufficientlyOutsidePrecision(result));
        end
        
        function diag = getDiagnosticFor(constraint, result)
            import matlab.unittest.diagnostics.StringDiagnostic;
            [passed,labels] = measurementsSufficientlyOutsidePrecision(result);
            if all(passed)
                diag = StringDiagnostic(...
                    constraint.Catalog.getString('SufficientlyOutsidePrecision', ...
                    result.MeasuredVariableName, result.Name));
            else
                message = char.empty;
                failedLabels = unique(labels(~passed));
                for i = 1:length(failedLabels)
                    message = sprintf([message,...
                        constraint.Catalog.getString('InsufficientlyOutsidePrecision', ...
                        result.MeasuredVariableName, appendLabels(result.Name, failedLabels{i})),'\n\n']);
                end
                diag = StringDiagnostic(message);
            end
        end
    end
end

function [passed, labels] = measurementsSufficientlyOutsidePrecision(result)
tare = result.CalibrationValue;
measurements = result.InternalTestActivity.Measurement;
labels = result.InternalTestActivity.Label;
N = length(measurements);
passed = true(1,N);

for i = 1:N
    passed(i) = measurements(i).isOutsidePrecision(tare);
end
end

function name = appendLabels(basename,label)
name = basename;
if ~startsWith(label,'_')
    name = [name,' <',label,'>'];
end
end