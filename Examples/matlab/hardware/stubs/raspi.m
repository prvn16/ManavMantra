function varargout = raspi(varargin)
    %RASPI Access Raspberry Pi hardware peripherals.
    %
    % obj = RASPI(DEVICEADDRESS, USERNAME, PASSWORD) creates a RASPI object
    % connected to the Raspberry Pi hardware at DEVICEADDRESS with login
    % credentials USERNAME and PASSWORD. The DEVICEADDRESS can be an 
    % IP address such as '192.168.0.10' or a hostname such as
    % 'raspberrypi-MJONES.foo.com'. 
    %
    % obj = RASPI creates a RASPI object connected to Raspberry Pi hardware
    % using saved values for DEVICEADDRESS, USERNAME and PASSWORD.
    % 
    % Type <a href="matlab:methods('raspi')">methods('raspi')</a> for a list of methods of the raspi object.
    %
    % Type <a href="matlab:properties('raspi')">properties('raspi')</a> for a list of properties of the raspi object.
    
    % Copyright 2016 The MathWorks, Inc.
    
    varargout = {[]};

    % Check if the support package is installed.
    try
        fullpathToUtility = which('raspi.internal.getRaspiRoot');
        if isempty(fullpathToUtility) 
            % Support package not installed - Error.
            error(getString(message('MATLAB:hwstubs:general:spkgNotInstalled', 'MATLAB Raspberry Pi', 'RASPPIIO')));
        end
    catch e
        throwAsCaller(e);
    end
end