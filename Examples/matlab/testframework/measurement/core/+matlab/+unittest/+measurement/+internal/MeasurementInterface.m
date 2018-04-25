classdef MeasurementInterface < matlab.mixin.Heterogeneous
    % Measurement Interface
    % This class is undocumented and subject to change in a future release
    
    % Copyright 2017 The MathWorks, Inc.
    
    properties(Abstract, SetAccess = immutable)
        Value
        Timestamp
    end
    
    properties(SetAccess=immutable)
        Host = getHostName;
        Platform = getPlatform;
        Version = getVersion;
    end
    
    methods(Abstract)
        t = getTaredValue(measurement,tare)
    end
    
    methods(Abstract, Hidden)
        tf = isOutsidePrecision(measurement,tare,threshold)
    end
    
    methods
        function m = addMeasurement(measurement,newmeasurement)
            m = [measurement, newmeasurement];
        end
    end
end

function host = getHostName
[status, host] = system('hostname');
if ~isequal(status, 0)
    host = '';
end
host = categorical({host});
end

function platform = getPlatform
platform = categorical({computer('arch')});
end

function v = getVersion
v = categorical({version});
end