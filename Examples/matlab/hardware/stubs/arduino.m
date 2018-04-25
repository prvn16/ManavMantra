function out = arduino(varargin)
%	Connect to an Arduino.
%
%   Syntax:
%       a = arduino
%       a = arduino(port)
%       a = arduino(port,board,Name,Value)
%       a = arduino(ip,board)
%       a = arduino(ip,board,tcpipport)
%       a = arduino(btaddress,board)
%
%   Description:
%       a = arduino                        Creates a serial connection to an Arduino® hardware.
%       a = arduino(port)                  Creates a serial connection to an Arduino hardware on the specified port.
%       a = arduino(port,board,Name,Value) Creates a serial connection to the Arduino hardware on the specified port and board with additional Name-Value options.
%       a = arduino(ip,board)              Creates a WiFi connection to the Arduino hardware at the specified IP address.
%       a = arduino(ip,board,tcpipport)    Creates a WiFi connection to the Arduino hardware at the specified IP address and TCP/IP remote port.
%       a = arduino(btaddress,board)       Creates a Bluetooth connection to the Arduino hardware at the specified device address.
%
%   Example: 
%   Connect to an Arduino Uno board on COM port 3 on Windows:
%       a = arduino('com3','uno');
% 
%   Connect to an Arduino Uno board on a serial port on Mac:
%       a = arduino('/dev/tty.usbmodem1421');
%
%   Example:
%   Include only I2C library instead of default libraries set (I2C, SPI and Servo)
%       a = arduino('com3','uno','libraries','I2C');
%
%   Example:
%   Connect to an Arduino MKR1000 board at IP address 172.32.45.121:
%       a = arduino('172.32.45.121','mkr1000');
%
%   Connect to an Arduino MKR1000 board at IP address 172.32.45.121 and TCP/IP remote port 8000:
%       a = arduino('172.32.45.121','mkr1000',8000);
%
%   Connect to an Arduino Uno board at device address btspp://98d331fc3af3:
%       a = arduino('btspp://98d331fc3af3','uno');
%
%
%   Input Arguments:
%   port - Device port (character vector or string, e.g. 'com3' or '/dev/tty.usbmodem1421')
%   board - Arduino Board type (character vector or string, e.g. 'Uno', 'Mega2560', ...)
%   ip - Arduino WiFi device address (character vector or string, e.g. '172.32.45.121')
%   tcpipport - Arduino TCP/IP remote port (numeric, e.g. 8000)
%   btaddress - Arduino Bluetooth address (character vector or string, e.g 'btspp://98d331fc3af3')
%
%   Name-Value Pair Input Arguments:
%   Specify optional comma-separated pairs of Name,Value arguments. Name is the argument name and Value is the corresponding value. 
%   Name must appear inside single quotes (' '). You can specify several name and value pair arguments in any order as Name1,Value1,...,NameN,ValueN.
%
%   NV Pair:
%   'libraries' - Name of Arduino library (character vector or string)
%              Default libraries downloaded to Arduino: I2C, SPI, Servo.
%
%   Name of the Arduino library specified as a character vector or string.
%   Example: a = arduino('com9','uno','libraries','spi')
%
%   Output Arguments:
%   a - Arduino hardware connection
%
%   See also arduinosetup, listArduinoLibraries, writeDigitalPin, readDigitalPin, i2cdev, spidev

%   Copyright 2014-2017 The MathWorks, Inc.

out = [];
        
% Check if the support package is installed.
try
    fullpathToUtility = which('arduinoio.internal.Utility');
    if isempty(fullpathToUtility) 
        % Support package not installed - Error.
        error(getString(message('MATLAB:hwstubs:general:spkgNotInstalled', 'MATLAB Arduino', 'ML_ARDUINO')));
    end
catch e
    throwAsCaller(e);
end
% LocalWords:  arduino tripline
