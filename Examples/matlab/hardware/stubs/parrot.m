function out = parrot(varargin)
    
    %	Connect to a Parrot minidrone.
    %
    %   Syntax:
    %       p = parrot()
    %       p = parrot(DroneName)
    %       p = parrot(DroneName,Name,Value)
    %
    %   Description:
    %       p = parrot()                                    Creates a TCP connection to a PARROT minidrone
    %       p = parrot(DroneName)                           Creates a TCP connection to the specified PARROT minidrone at the default IP address of the drone
    %       p = parrot(DroneName/ipaddress,Name,Value)      Creates a TCP connection to the PARROT minidrone or at the specified device address with additional Name-Value options
    %
    %   Example:
    %   Connect to a PARROT Rolling Spider minidrone :
    %       p = parrot('Rolling Spider')
    %       p = parrot('192.168.5.1')
    %       p = parrot('Rolling Spider','PowerGain',1)
    %       p = parrot('Rolling Spider','UseDefaultServer',true)
    %
    %
    %   Input Arguments:
    %   DroneName - Name of the PARROT minidrone (character vector or string, e.g 'Rolling Spider')
    %   ipaddress - Bluetooth IPV4 Address of the drone. Refer MATLAB documentation to get the default IP Address of your drone.
    %
    %   Name-Value Pair Input Arguments:
    %   Specify optional comma-separated pairs of Name,Value arguments. Name is the argument name and Value is the corresponding value.
    %   Name must appear inside single quotes (' '). You can specify several name and value pair arguments in any order as Name1,Value1,...,NameN,ValueN.
    %
    %   NV Pair:
    %   'PowerGain' - Gain factor for the drone motor speed. Default value is 1
    %   'UseDefaultServer' - To use the default server shipped with the support package. This will overwrite any existing server in the drone. Default value is false.
    %
    %   Output Arguments:
    %   p - PARROT hardware connection
    
    %   Copyright 2017 The MathWorks, Inc.

out = [];
        
% Check if the support package is installed.
try
    fullpathToUtility = which('parrot.internal.Utility');
    if isempty(fullpathToUtility) 
        % Support package not installed - Error.
        error(getString(message('MATLAB:hwstubs:general:spkgNotInstalled', 'MATLAB PARROT minidrone', 'MINIDRONES')));
    end
catch e
    throwAsCaller(e);
end
