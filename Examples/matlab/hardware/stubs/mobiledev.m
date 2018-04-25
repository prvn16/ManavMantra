function varargout = mobiledev(varargin)
%MOBILEDEV Read sensor data from mobile device running MATLAB Mobile.
%
%   Supported OS:
%   Android, Apple iOS
%
%   m = mobiledev() creates an object that reads sensor data from a mobile device
%   connected to the same network as the computer running MATLAB.
%
%
%   mobiledev methods:
%
%       Accessing logged data.
%           accellog - returns logged acceleration data
%           angvellog - returns logged angular velocity data
%           magfieldlog - returns logged magnetic field data
%           orientlog - returns logged orientation data       
%           poslog - returns logged position data
%
%       Discarding logged data.
%           discardlogs - discard all logged data
%
%   mobiledev properties:
%       Connected - Shows status of connection between MATLAB Mobile and mobiledev object in MATLAB
%       Logging - Shows and controls status of data transfer from device to MATLAB
%       InitialTimestamp - Time when first data point was transferred from 
%                          device to mobiledev in date format dd-mmm-yyyy HH:MM:SS.FFF.
%
%       Acceleration - Current acceleration reading: X, Y, Z in m/s^2
%       AngularVelocity - Current angular velocity reading: X, Y, Z in radians per second
%       Orientation - Current orientation reading: Azimuth, Pitch and Roll in degrees
%       MagneticField - Current magnetic field reading:  X, Y, Z in microtesla
%
%       Latitude - Current latitude reading in degrees
%       Longitude - Current longitude reading in degrees
%       Speed - Current speed reading in meters per second
%       Course - Current course reading in degrees relative to true north
%       Altitude - Current altitude reading in meters
%       HorizontalAccuracy - Current horizontal accuracy reading in meters
%
%       AccelerationSensorEnabled - Turns on/off accelerometer
%       AngularVelocitySensorEnabled - Turns on/off gyroscope
%       MagneticSensorEnabled - Turns on/off magnetometer
%       OrientationSensorEnabled - Turns on/off orientation sensor
%       PositionSensorEnabled - Turns on/off position sensor
%
%   Usage
%
%   Before starting, connect your device to the same network as
%   the host computer where you are running MATLAB. You may use Wi-Fi
%   or the cellular network. For information on how to connect your
%   device to computer, please, refer to MATLAB Mobile documentation.
%
%   1. Start MATLAB Mobile.
%   2. Connect MATLAB Mobile to your computer. Refer to MATLAB
%      Mobile documentation for help. You need to do this step only
%      once.
%   3. In MATLAB, enter:  m = mobiledev() to create mobiledev object.
%
%   Access Data
%
%   You can get the latest value of a specific measurement by
%   querying the corresponding property. For example:
%
%       m.Acceleration
%
%   You can use mobiledev methods to access the logged measurement values.
%   For example, to get logged acceleration values:
%
%       [a, t] = accellog(m)
%  

% Copyright 2014 The MathWorks, Inc.
    
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
