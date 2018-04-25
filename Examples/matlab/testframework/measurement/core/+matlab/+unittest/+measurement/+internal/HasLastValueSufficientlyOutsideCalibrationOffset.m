classdef HasLastValueSufficientlyOutsideCalibrationOffset < matlab.unittest.constraints.Constraint
    % This class is undocumented and will change in a future release.
    % The constraint is only used for the early termination function in TimeExperiment
    % Copyright 2015-2017 The MathWorks, Inc.
    
    methods
        function tf = satisfiedBy(~, result)
            tf = all(lastMeasurementSufficientlyOutsidePrecision(result));
        end
        function diag = getDiagnosticFor(~, ~)
            import matlab.unittest.internal.diagnostics.EmptyDiagnostic;
            diag = EmptyDiagnostic;
        end
    end
end

function passed = lastMeasurementSufficientlyOutsidePrecision(result)
tare = result.CalibrationValue;
lastmeasurements = result.LastMeasurements;
labels = lastmeasurements.keys;
N = length(labels);

passed = true(1,N);

for i = 1:N
    label = labels{i};
    passed(i) = lastmeasurements(label).isOutsidePrecision(tare);
end
end