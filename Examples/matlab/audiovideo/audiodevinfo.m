function devInfo = audiodevinfo(varargin)
%AUDIODEVINFO Audio device information.
%   DEVINFO = AUDIODEVINFO returns a structure DEVINFO containing two fields,
%   input and output.  Each of these fields is an array of structures, each
%   structure containing information about one of the audio input or output
%   devices on the system.  The individual device structure fields are Name
%   (name of the device, string), DriverVersion (version of the installed
%   device driver, string), and ID (the device's ID).
%
%   AUDIODEVINFO(IO) returns the number of input or output audio devices on
%   the system.  Set IO = 1 for input, IO = 0 for output.
%
%   AUDIODEVINFO(IO, ID) returns the name of the input or output audio device
%   with the given device ID.
%
%   AUDIODEVINFO(IO, NAME) returns the device ID of the input or output audio
%   device with the given name (partial matching, case sensitive).  If no
%   audio device is found with the given name, an error is generated.
%
%   AUDIODEVINFO(IO, ID, 'DriverVersion') returns the driver version string of
%   the specified audio input or output device.
%
%   AUDIODEVINFO(IO, RATE, BITS, CHANS) returns the device ID of the first
%   input or output device that supports the sample rate, number of bits,
%   and number of channels specified in RATE, BITS, and CHANS, respectively.
%   If no supportive device is found, -1 is returned.
%
%   AUDIODEVINFO(IO, ID, RATE, BITS, CHANS) returns 1 or 0 for whether or not
%   the input or output audio device specified in ID can support the given
%   sample rate, number of bits, and number of channels.
%
%
%   See also AUDIOPLAYER, AUDIORECORDER.

%   Author(s): Brian Wherry, nch
%   Copyright 1984-2014 The MathWorks, Inc.

narginchk(0,5);

% Local Constants
INPUT = 1;
OUTPUT = 0;

switch nargin
    case 0
        devInfo = localGetAllDevices();
    case 1
        devInfo = localGetDeviceCount(varargin{:});
    case 2
        if ischar(varargin{2})
            devInfo = localGetDeviceID(varargin{:});
        else
            devInfo = localGetDeviceName(varargin{:});
        end
    case 3
        devInfo = localGetDriverVersion(varargin{1}, varargin{2});
    case 4
        devInfo = localFindDeviceWith(varargin{:});
    case 5
        devInfo = localDoesDeviceSupport(varargin{:});
end


    function devices = localGetAllDevices()
        import multimedia.internal.audio.device.DeviceInfo;

        % Return a structure of all input and output devices on the current system
        deviceList = DeviceInfo.getDevicesForDefaultHostApi();
        
        inputDevices = [];
        outputDevices = [];
        for ii=1:length(deviceList) % devices IDs are zero based
            inputDevices = localAddDeviceInfo(deviceList(ii), INPUT, inputDevices);
            outputDevices = localAddDeviceInfo(deviceList(ii), OUTPUT, outputDevices);
        end
        
        devices.input = inputDevices;
        devices.output = outputDevices;
    end

    function devices = localAddDeviceInfo( deviceInfo, IO, devices )
        localValidateDeviceType(IO); 
        
        if ~localHasType(deviceInfo, IO);
            return;
        end
        
        devices(end+1).Name = deviceInfo.Name;
        devices(end).DriverVersion = deviceInfo.HostApiName;
        devices(end).ID = deviceInfo.ID;
    end

    function numDevices = localGetDeviceCount(IO)
        devices = localGetAllDevices();
        
        localValidateDeviceType(IO); 
        switch(IO)
            case INPUT
                numDevices = length(devices.input);
            case OUTPUT
                numDevices = length(devices.output);   
        end
    end

    function deviceName = localGetDeviceName(IO, ID)
        import multimedia.internal.audio.device.DeviceInfo;

        localValidateDeviceType(IO); 
        
        deviceInfo = DeviceInfo.getDeviceInfo(ID);
        if ~localHasType(deviceInfo, IO)
            error(message('MATLAB:audiovideo:audiodevinfo:invalidID'));
        end
        
        deviceName = deviceInfo.Name;
    end

    function deviceID = localGetDeviceID(IO, name)
        localValidateDeviceType(IO);
    
        devices = localGetDevicesByType(IO);
        if isempty(devices)
            error (message('MATLAB:audiovideo:audiodevinfo:invalidDeviceName'));
        end
        
        idx = strfind({devices.Name}, name);
        deviceIndex = find( cellfun( @(x) ~isempty(x), idx, 'UniformOutput', true) );
        
        if isempty(deviceIndex)
            error (message('MATLAB:audiovideo:audiodevinfo:invalidDeviceName'));
        end
        
        if ~isscalar(find(deviceIndex))
            error(message('MATLAB:audiovideo:audiodevinfo:multipleDevicesWithSameName', name));
        end
        
        deviceID = devices(deviceIndex).ID;        
    end

    function driverVersion = localGetDriverVersion(IO, ID)
        import multimedia.internal.audio.device.DeviceInfo;

        localValidateDeviceType(IO);
  
        deviceInfo = DeviceInfo.getDeviceInfo(ID);

        if ~localHasType(deviceInfo, IO)
            error(message('MATLAB:audiovideo:audiodevinfo:invalidID'));
        end
        
        driverVersion = deviceInfo.HostApiName;
        
    end

    function deviceID = localFindDeviceWith(IO, rate, bits, chans)
        localValidateDeviceType(IO);
        
        devices = localGetDevicesByType(IO);

        for ii = 1:length(devices)
            if (localDoesDeviceSupport(IO, devices(ii).ID, rate, bits, chans))
                deviceID = devices(ii).ID;
                return;
            end
        end
        
        % No Device found
        deviceID = -1;
    end

    
    function supported = localDoesDeviceSupport(IO, ID, rate, bits, chans)
        supported = true;
        try
            switch(IO)
                case INPUT
                    a = audiorecorder(rate, bits, chans, ID);
                    record(a);
                    stop(a);
                case OUTPUT
                    y = zeros(int32(rate),chans);
                    a = audioplayer(y, rate, bits, ID );
                    play(a);
                    stop(a);
            end
        catch exception %#ok<NASGU>
            supported = false;
        end
    end

    function devices = localGetDevicesByType(IO)
        devices = localGetAllDevices();
        switch(IO)
            case INPUT
                devices = devices.input;
            case OUTPUT
                devices = devices.output;
        end
    end

    function hasType = localHasType(deviceInfo, IO)
        if isempty(deviceInfo)
            hasType = false;
            return;
        end
        
        if IO == INPUT
            hasType = deviceInfo.NumberOfInputs > 0;
        elseif IO == OUTPUT
            hasType = deviceInfo.NumberOfOutputs > 0;
        end
    end

    function localValidateDeviceType(IO)
         if ~isempty(IO) && isnumeric(IO) && (IO == INPUT || IO == OUTPUT) 
             return; % Valid value
         end
         
         error(message('MATLAB:audiovideo:audiodevinfo:invalidDeviceType'));
    end
end
