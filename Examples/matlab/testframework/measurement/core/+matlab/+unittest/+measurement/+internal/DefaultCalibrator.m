classdef DefaultCalibrator < matlab.unittest.measurement.internal.Calibrator
    % This class is undocumented and subject to change in a future release
    
    % Copyright 2016-2017 The MathWorks, Inc.
    
    properties (Access = protected)
        CalibrationValue
        CalibrationResult
        
        SelfMeasurableCalibrationValue
        SelfMeasurableCalibrationResult
    end
    
    properties (Constant, Access=private)
        CalibrationSuite = getCalibrationSuite;
        DefaultCalibrationSuiteElement = getDefaultCalibrationTest;
        SelfMeasuredCalibrationSuite = getSelfMeasuredCalibrationSuite;
    end
    
    methods
        
        function calibrate(calibrator,meter,suite)
            import matlab.unittest.TestRunner;
            import matlab.unittest.measurement.MeasurementResult;
            import matlab.unittest.measurement.MeasurementPlugin;
            import matlab.unittest.measurement.internal.ExperimentOperator;
            import matlab.unittest.measurement.internal.NullCalibrator;
            
            [calibrationSuite,selfMeasuredCalibrationSuite,suiteIdx] = calibrator.getApplicableCalibrationSuites(suite);
            
            operator = ExperimentOperator(meter,NullCalibrator);
            operator.Result = MeasurementResult({calibrationSuite.Name, selfMeasuredCalibrationSuite.Name}, 'CalibrationOffset');
            
            % Run the suite 10 times (4 warmup, 6 samples)
            runner = TestRunner.withNoPlugins;
            runner.addPlugin(MeasurementPlugin(operator));
            runner.runRepeatedly([calibrationSuite, selfMeasuredCalibrationSuite], 10);
            
            result = applyWarmups(operator.Result, 4);
            
            % Calculate the lowerbound of each calibration now - this array
            % is typically much smaller than the suite under test and is
            % frequently queried for calculations
            calibrationThreshold = zeros(length(result),1);
            for k=1:length(result)
                v = [result(k).InternalTestActivity.Measurement.Value];
                calibrationThreshold(k) = min(v(5:10));
            end
            
            % Assign the relevant calibration results to suite indices to
            % which they apply
            calibrator.CalibrationResult = result(suiteIdx);
            calibrator.CalibrationValue = calibrationThreshold(suiteIdx);
            
            % Keep the self-measured calibration if we need to swap with it
            % later
            numSelfMeasured = numel(selfMeasuredCalibrationSuite);
            
            calibrator.SelfMeasurableCalibrationResult = result(end - numSelfMeasured + 1:end);
            calibrator.SelfMeasurableCalibrationValue = calibrationThreshold(end - numSelfMeasured + 1:end);
        end
        
        function measResult = getCalibrationResults(calibrator,suiteIdx,measResult,meter)
            import matlab.unittest.measurement.MeasurementResult;
            
            if meter.isSelfMeasured && ~isempty(calibrator.SelfMeasurableCalibrationValue)
                % use the self-timing calibration result instead (except script based test)
                measResult.CalibrationValue = calibrator.SelfMeasurableCalibrationValue;
                measResult.CalibrationResult = calibrator.SelfMeasurableCalibrationResult;
            else
                % pull from the standard calibration suites
                measResult.CalibrationValue = calibrator.CalibrationValue(suiteIdx);
                measResult.CalibrationResult = calibrator.CalibrationResult(suiteIdx);
            end
        end
        
    end
    
    methods (Access = private)
        
        function [calibrationSuite,selfMeasuredCalibrationSuite,suiteIdx] = getApplicableCalibrationSuites(calibrator,suite)
            import matlab.unittest.Test;
            import matlab.unittest.measurement.internal.calibration.ClassBasedTest;
            
            % Find the indices of our calibration suite that have the same providers
            % and then find those with matching number of parameters
            calibrationSuite = calibrator.CalibrationSuite;
            providersIdx = matchProviders(calibrationSuite, suite);
            providersIdx(providersIdx == 0) = find(strcmp(...
                calibrator.DefaultCalibrationSuiteElement.Name, ...
                {calibrationSuite.Name}));
            [paramsIdx, numSuiteParams] = matchParameters(calibrationSuite, suite);
            
            % For those with zero parameters, use the provider criteria, for those with
            % more than zero parameters, use the parameters criteria
            zeroParamsMask = (numSuiteParams == 0);
            idx(zeroParamsMask) = providersIdx(zeroParamsMask);
            idx(~zeroParamsMask) = paramsIdx(~zeroParamsMask);
            
            % Grab unique calibration suite indices and select the corresponding suite
            % elements needed for calibration
            [idx, ~, suiteIdx] = unique(idx);
            calibrationSuite = calibrationSuite(idx);
            
            % We can't know ahead of time if a suite is self-measured, but
            % we can at least bin those that could be to test later
            selfMeasuredCalibrationSuite = calibrator.SelfMeasuredCalibrationSuite;
            % suites created "fromTestCase" are also self-measured
            % candidates, but use the standard Class-Based calibrations
            suiteFromTestCase = Test.fromTestCase(ClassBasedTest,'zeroParams');
            selfMeasurableCandidates = ...
                matchProviders(selfMeasuredCalibrationSuite, suite) | ...
                matchProviders(suiteFromTestCase, suite);
            if ~any(selfMeasurableCandidates)
                % don't bother running these if they will never apply
                selfMeasuredCalibrationSuite(:) = [];
            end
        end
        
    end
    
end

function [idx, numSuiteParams] = matchParameters(calibrationSuite, suite)

numSuiteParams = [suite.NumInputParameters];
numCalibrationParams = [calibrationSuite.NumInputParameters];

[mask, idx] = ismember(numSuiteParams, numCalibrationParams);

% If any number of parameters were not found in our calibration suite, use
% the calibration element with the largest number of parameters.
[~, maxIdx] = max(numCalibrationParams(:));
idx(~mask) = maxIdx;

end

function result = applyWarmups(result, numWarmups)

for idx = 1:numel(result)
    testActivity = result(idx).InternalTestActivity;
    numWarmupsExecuted = min(numWarmups, height(testActivity));
    testActivity.Objective(1:numWarmupsExecuted) = categorical({'warmup'});
    result(idx).InternalTestActivity = testActivity;
end

end

function suite = getCalibrationSuite
import matlab.unittest.TestSuite;
suite = TestSuite.fromPackage('matlab.unittest.measurement.internal.calibration');
end
function test = getDefaultCalibrationTest
import matlab.unittest.TestSuite;
test = TestSuite.fromName('matlab.unittest.measurement.internal.calibration.ClassBasedTest/zeroParams');
end
function suite = getSelfMeasuredCalibrationSuite
import matlab.unittest.TestSuite;
suite = TestSuite.fromPackage('matlab.unittest.measurement.internal.calibration.selfmeasured');
end