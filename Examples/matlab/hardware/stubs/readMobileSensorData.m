function varargout = readMobileSensorData(fname)
%readMobileSensorData Imports sensor data from file previously collected by
%MATLAB Mobile
%   S = readMobileSensorData(FILENAME) will read file FILENAME, extract sensor
%   data from it and create structure S, where each field in this structure
%   is a timetable with sensor data.
%   If corresponding sensor data is present in the file, structure S will
%   have the following fields:
%   Acceleration - timetable with acceleration data
%   AngularVelocity - timetable with angular velocity data
%   MagneticField - timetable with magnetic field data
%   Orientation - timetable with orientation data
%   Position - timetable with position data
%
%   For example:
%   S = readMobileSensorData('sensorlog_20170726_102034.zip')
%   acceleration = S.Acceleration;
%   plot(acceleration.Timestamp, acceleration{:, 2:end})

%   Copyright 2017 MathWorks, Inc.

varargout = {[]};

% Check if the support package is installed.
try
    fullpathToUtility = which('mobilesensor.internal.MobileDevController');
    if isempty(fullpathToUtility) 
        % Support package not installed - Error.
        error(getString(message('MATLAB:hwstubs:general:mobiledevNotInstalled', '{''ML_ANDROID_SENSORS'', ''ML_APPLE_IOS_SENSORS''}')));
    end
catch e
    throwAsCaller(e);
end



end
