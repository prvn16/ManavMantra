classdef(Hidden) Meter < handle
    % This class is undocumented and may change in a future release.
    
    % Copyright 2015-2017 The MathWorks, Inc.
    
    properties(SetAccess={?matlab.unittest.measurement.internal.Meter,...
            ?matlab.unittest.measurement.internal.ExperimentOperator})
        MeasurementContainer;
    end
    
    properties(Hidden, SetAccess=protected)
        State = matlab.unittest.measurement.internal.states.Unused;
    end
    
    properties (Hidden, Access=protected)
        Listeners = event.listener.empty;
    end
    
    properties(Hidden, SetAccess=protected)
        % List of Labels in usage order by starts and logs
        LabelList = {};
        
        % Temporary validation, to be removed in phase3 with nested start/stop
        HasValidLabelList = true;  
    end
    
    methods(Abstract)
        start(meter,label)
        stop(meter,label)
    end
    
    methods
        function meter = Meter
            meter.MeasurementContainer = containers.Map;
        end
        
        function connect(meter, testCase)
            meter.clear;
            L(1) = event.listener(testCase,'MeasurementStarted', @(o,e)doStart(meter,e));
            L(2) = event.listener(testCase,'MeasurementStopped', @(o,e)doStop(meter,e));
            L(3) = event.listener(testCase,'MeasurementLogged', @(o,e)doLog(meter,e));
            meter.Listeners = L;
        end
        
        function disconnect(meter)
            delete(meter.Listeners);
        end
        
        function clear(meter)
            import matlab.unittest.measurement.internal.states.Unused;
            
            meter.disconnect();
            meter.MeasurementContainer = containers.Map;
            meter.LabelList = {};
            meter.HasValidLabelList = true;  
            meter.State = Unused;
        end
        
        function tf = hasValidInteractions(meter)
            import matlab.unittest.measurement.internal.states.Completed;
            import matlab.unittest.measurement.internal.states.Unused;
            
            tf = meter.HasValidLabelList && ...
                (isequal(meter.State,Completed) || isequal(meter.State,Unused));
        end
        
    end
    
    methods(Access=protected)
        function m = createEmptyMeasurement(~)
            m = matlab.unittest.measurement.internal.MeasurementInterface.empty;
        end
        
        function addMeasurement(meter, measurement, label)
            if ~meter.MeasurementContainer.isKey(label)
                meter.MeasurementContainer(label) = meter.createEmptyMeasurement;
            end
            meter.MeasurementContainer(label) = meter.MeasurementContainer(label).addMeasurement(measurement);
            
        end
    end
    
    methods (Hidden)
        function logTimeMeasurement(meter,measurement,label) %#ok<INUSD>
            % no-op default behavior
        end
        
        function tf = isSelfMeasured(meter)
            % A helper function to determine if self-measured
            % assuming implicit boundaries always exist
            tf = meter.MeasurementContainer.Count > 1;
        end
    end
    
end

function doLog(meter,evd)
meter.LabelList(end+1) = {evd.Label};
logMeasurement(evd.Value, meter, evd.Label);
end

function doStart(meter,evd)
meter.LabelList(end+1) = {evd.Label};
meter.start(evd.Label);
end

function doStop(meter,evd)
meter.stop(evd.Label);
if ~strcmp(evd.Label,meter.LabelList{end}) && ~strcmp(evd.Label,'_implicit')
    meter.HasValidLabelList = false;
end
end