classdef ExperimentOperator < handle
    % This class is undocumented and will change in a future release.
    
    % Copyright 2015-2017 The MathWorks, Inc.
    
    events (Hidden, NotifyAccess = private)
        MeasurementCompleted
    end
    
    properties
        Result = matlab.unittest.measurement.MeasurementResult.empty;
    end
    
    properties (Hidden, SetAccess = immutable)
        Meter;
    end
    
    properties(SetAccess = immutable, GetAccess = private)
        Calibrator;
    end
    
    
    methods
        function operator = ExperimentOperator(meter,calibrator)
            import matlab.unittest.measurement.internal.DefaultCalibrator;
            
            operator.Meter = meter;
            
            if nargin>1
                operator.Calibrator = calibrator;
            else
                operator.Calibrator = DefaultCalibrator;
            end
        end
        
        function completeTestRun(operator,idx)
            import matlab.unittest.measurement.internal.MeasurementEventData;
            
            measResult = operator.Result(idx);
            meter = operator.Meter;
            
            % Extract tare value from Calibrator and save to measurement result
            measResult = operator.Calibrator.getCalibrationResults(idx,measResult,meter);
            
            % Triage the labeled measurements from meter and write to measResult
            measResult = triageMeasurementContainer(meter,measResult);
            
            operator.notify('MeasurementCompleted', ...
                MeasurementEventData(measResult,idx));
            
            operator.Result(idx) = measResult;
        end
        
        function storeFinalizedTestResult(operator, idx, testResult)
            
            measResult = operator.Result(idx);
            if isempty(measResult.InternalTestActivity)
                % this should only be hit in the event that TestClassSetup
                % was incomplete
                measResult = measResult.newTestRun;
            end
            
            measResult = triageTestResult(measResult, flatten(testResult));

            operator.Result(idx) = measResult;
        end
        
        function calibrate(operator, suite)
            operator.Calibrator.calibrate(operator.Meter,suite);
        end
        
        
    end
    
end

function measResult = triageMeasurementContainer(meter,measResult)
container = meter.MeasurementContainer;
tare = measResult.CalibrationValue;

Labels = unique(meter.LabelList,'stable');
for i = 1:length(Labels)
    label = Labels{i};
    
    if meter.isSelfMeasured && strcmp(label,'_implicit')
        container.remove('_implicit');
        continue;
    end
    
    % If error occurs before the 'stop', we will have the label from 'start' 
    % but not from the container.
    if container.isKey(label)
        measurement = container(label);    
        measResult.InternalTestActivity(end, {'Measurement'}) = {measurement};
        measResult.LastMeasuredValues(label) = measurement.getTaredValue(tare);
    end
    measResult.InternalTestActivity(end, {'Label'}) = {label};
    
    % If there are more labels, dup new TestActivityRow
    if i ~= length(Labels)
        iter = measResult.InternalTestActivity{end,{'Iteration'}};
        measResult = measResult.newTestRun(iter);
    end
end

measResult.LastMeasurements = container;

end

function measResult = triageTestResult(measResult, testResult)
% Store TestResult array to the InternalTestActivity of MeasurementResult 

activity = measResult.InternalTestActivity;
if height(activity) == length(testResult)
    % No multiple measurements in all iterations
    activity.TestResult = testResult;
else
    for iter = 1:max(activity.Iteration)
        index = (activity.Iteration == iter);
        activity.TestResult(index) = repmat(testResult(iter),sum(index),1);
    end
end
measResult.InternalTestActivity = activity;
end